//
//  TAPGridViewController.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "AppDelegate.h"
#import "ArrowView.h"
#import "TAPGridViewController.h"
#import "TAPGridDetailViewController.h"
#import "ThemeCell.h"
#import "NSDictionary+TAPUtils.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"

// vendor
#import "TAPAsset.h"
#import "TAPConnection.h"
#import "TAPSource.h"
#import "TAPStop.h"
#import "TAPTour.h"
#import "VSTheme.h"


@interface TAPGridViewController ()
@property (nonatomic, strong) TAPStop *stop;
@property (nonatomic, strong) NSMutableArray *themeStops;
@property (nonatomic, strong) NSMutableArray *themeStopImages;
@property (nonatomic, weak) IBOutlet UILabel *helpText;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property const CGSize cellSize;
@property const NSInteger maxRowCount;
@property const NSInteger itemsPerRow;
@property const CGFloat minInteritemSpacing;
@property const CGFloat minLineSpacing;
@property const CGFloat horizontalSectionInset;
@property const CGFloat verticalSectionInset;
@property const CGFloat columnWidth;
@property const CGFloat rowHeight;
@property const NSInteger totalItems;
@property (nonatomic, strong) ArrowView *arrowIndicator;
@property const UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, strong) VSTheme *theme;
@property TAPStop *selectedStop;
@property NSURL *selectedVideoUrl;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
@end

@implementation TAPGridViewController

- (id)initWithConfigDictionary:(NSDictionary *)config {
    
    // validate incoming config values
    NSArray *requiredKeys = @[@"title", @"keycode", @"trackedViewName", @"itemsPerRow", @"columnWidth", @"rowHeight", @"verticalSpacing", @"scrollDirection"];
    if ([config containsAllKeysIn:requiredKeys]) {
        
        // default to vertical scroll direction
        NSInteger scrollDirection = UICollectionViewScrollDirectionVertical;
        if ([[config objectForKey:@"scrollDirection"] isEqual: @"horizontal"]) {
            // if horizontal is set, reset scrollDirection
            scrollDirection = UICollectionViewScrollDirectionHorizontal;
        }
        // implement others here if needed
        
        self = [self initWithStopTitle:[config objectForKey:@"title"]
                               keycode:[config objectForKey:@"keycode"]
                       trackedViewName:[config objectForKey:@"trackedViewName"]
                           itemsPerRow:[(NSNumber *)[config objectForKey:@"itemsPerRow"] floatValue]
                           columnWidth:[(NSNumber *)[config objectForKey:@"columnWidth"] floatValue]
                             rowHeight:[(NSNumber *)[config objectForKey:@"rowHeight"] floatValue]
                       verticalSpacing:[(NSNumber *)[config objectForKey:@"verticalSpacing"] floatValue]
                       scrollDirection:scrollDirection];
    } else {
        NSLog(@"Tried to instantiate ThemesStopViewController without all required config items, please check TAPConfig");
        self = nil;
    }

    return self;
    
}

- (id)initWithStopTitle:(NSString *)stopTitle
                keycode:(NSString *)keycode
        trackedViewName:(NSString *)trackedViewName
            itemsPerRow:(NSInteger)itemsPerRow
            columnWidth:(CGFloat)columnWidth
              rowHeight:(CGFloat)rowHeight
        verticalSpacing:(CGFloat)verticalSpacing
        scrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    
    self = [self init];
    if (self) {
        
        [self setTitle:stopTitle];
        self.screenName = trackedViewName;
        [self setItemsPerRow:itemsPerRow];
        [self setColumnWidth:columnWidth];
        [self setRowHeight:rowHeight];
        [self setMinLineSpacing:verticalSpacing];
        [self setScrollDirection:scrollDirection];

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.stop = [appDelegate.currentTour stopFromKeycode:keycode];
        
        self.theme = appDelegate.theme;
        
        // organize stops according to category
        self.themeStops = [[NSMutableArray alloc] init];
        self.themeStopImages = [[NSMutableArray alloc] init];
        
        NSSortDescriptor *prioritySort = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
        for (TAPConnection *connection in [self.stop.sourceConnection sortedArrayUsingDescriptors:[NSArray arrayWithObject:prioritySort]]) {
            [self.themeStops addObject:connection.destinationStop];
            
            if ([[connection.destinationStop getAssetsByUsage:@"image"] count] > 0) {
                TAPAsset *themeAsset = [[connection.destinationStop getAssetsByUsage:@"image"] objectAtIndex:0];
                NSString *themeImage = [[[themeAsset source] anyObject] uri];
                if (themeImage != nil) {
                    UIImage *tapImage = [UIImage imageWithContentsOfFile:themeImage];
                    [self.themeStopImages addObject:tapImage];
                }
            } else {
                NSLog(@"No asset found on grid item stop, my friend.");
            }
        }
        
        self.totalItems = [self.themeStopImages count];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // hide navigation controller
    [self.navigationController setNavigationBarHidden:YES];
    // register custom cells;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ThemeCell" bundle:nil] forCellWithReuseIdentifier:@"ThemeCell"];
    // set help text font
    [self.helpText setFont:[self.theme fontForKey:@"bodyFont"]];
    
    //[self setCellSize:CGSizeMake(self.columnWidth, self.rowHeight)];
    CGFloat horizontalSpacing = 40.0f;
    CGFloat insetTop = self.minLineSpacing;
    CGFloat insetRight = 20.0f;
    CGFloat insetBottom = self.minLineSpacing;
    CGFloat insetLeft = 20.0f;
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical:
            horizontalSpacing = floorf((self.collectionView.frame.size.width - (self.columnWidth * self.itemsPerRow)) / (self.itemsPerRow + 1));
            insetRight = horizontalSpacing;
            insetLeft = horizontalSpacing;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            insetTop = 300.0f;
            // add arrow indicator animation
            self.arrowIndicator = [[ArrowView alloc] initWithFrame:CGRectMake(929.0f, 650.0f, 75.0f, 35.0f)];
            [self.view addSubview:self.arrowIndicator];
            break;
    }
    
    // set up cv layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setMinimumInteritemSpacing:horizontalSpacing];
    [flowLayout setMinimumLineSpacing:self.minLineSpacing];
    [flowLayout setSectionInset:UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight)];
    [flowLayout setItemSize:self.cellSize];
    [flowLayout setScrollDirection: self.scrollDirection];
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.totalItems;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ThemeCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ThemeCell" forIndexPath:indexPath];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [cell setAutoresizesSubviews:YES];
    
    UIImage *themeImage = [self.themeStopImages objectAtIndex:indexPath.row];
    
    [cell.themeImage setImage:themeImage];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // reset timer
    [(KioskApplication *)[[UIApplication sharedApplication] delegate] resetIdleTimer];
    
    // ensure we are not out of bounds
    if (indexPath.row >= [self.themeStops count]) {
        return;
    }
    
    // get selected stop and initialize theme stop controller
    self.selectedStop = [self.themeStops objectAtIndex:indexPath.row];
    
    if ([self.selectedStop.view  isEqual: @"video_stop"]) {
        TAPAsset *videoAsset = [[self.selectedStop getAssetsByUsage:@"video"] objectAtIndex:0];
        NSString *videoPath = [[[videoAsset source] anyObject] uri];
        self.selectedVideoUrl = [NSURL fileURLWithPath:videoPath];
        
        [self initializeVideo];
    } else {
        // get selected stop and initialize theme stop controller
        NSInteger useIndex = indexPath.row;
        TAPStop *themeStop = [self.themeStops objectAtIndex:useIndex];
        TAPGridDetailViewController *themeStopViewController = [[TAPGridDetailViewController alloc] initWithStop:themeStop];
        
        // create fade transition
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromTop;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        // push view theme view controller onto the stack
        [self.navigationController pushViewController:themeStopViewController animated:NO];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *tapImage = [self.themeStopImages objectAtIndex:indexPath.row];
    
    CGFloat imgWidth = tapImage.size.width;
    CGFloat imgHeight = tapImage.size.height;
    CGFloat imgRatio = imgWidth / imgHeight;
    CGFloat imgScaleWidth = floorf(self.rowHeight * imgRatio);
    
    return CGSizeMake(imgScaleWidth, self.rowHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // reset timer
    [(KioskApplication *)[[UIApplication sharedApplication] delegate] resetIdleTimer];
    
    if (scrollView.contentOffset.x == 0) {
        [self.arrowIndicator setHidden:NO];
    } else {
        [self.arrowIndicator setHidden:YES];
    }
}

#pragma mark - video playback methods, repurposed from interviewquestioncell. thanks Dan!
- (void)initializeVideo
{
    self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:self.selectedVideoUrl];
    self.moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [self presentMoviePlayerViewControllerAnimated:self.moviePlayer];
    // Add finished observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.moviePlayer.moviePlayer];
}

-(void)moviePlayBackDidFinish:(NSNotification *)notification
{
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    NSString *gaReason = @"";
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        //movie finished playin
        gaReason = @"video_complete";
    }else if (reason == MPMovieFinishReasonUserExited) {
        //user hit the done button
        gaReason = @"video_done_button";
    }else if (reason == MPMovieFinishReasonPlaybackError) {
        //error
        gaReason = @"video_error";
    }
    
    // register event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:gaReason label:(NSString *)self.selectedStop.title value:nil] build]];
    
    self.selectedStop = NULL;
    self.selectedVideoUrl = NULL;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)moviePlayerStateChanged:(NSNotification *)notification
{
    MPMoviePlaybackState playbackState = [[notification object] playbackState];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    if (playbackState == MPMoviePlaybackStatePaused) {
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_pause" label:(NSString *)self.selectedStop.title value:nil] build]];
    } else if (playbackState == MPMoviePlaybackStatePlaying) {
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_play" label:(NSString *)self.selectedStop.title value:nil] build]];
    } else if (playbackState == MPMoviePlaybackStateSeekingForward) {
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_forward" label:(NSString *)self.selectedStop.title value:nil] build]];
    } else if (playbackState == MPMoviePlaybackStateSeekingBackward) {
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_reverse" label:(NSString *)self.selectedStop.title value:nil] build]];
    } else if (playbackState == MPMoviePlaybackStateStopped) {
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_stopped" label:(NSString *)self.selectedStop.title value:nil] build]];
        
    }
    
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
