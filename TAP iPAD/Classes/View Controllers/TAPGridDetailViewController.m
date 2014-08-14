//
//  ThemeStopViewController.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "TAPGridDetailViewController.h"
#import "TAPImageStopViewController.h"
#import "AppDelegate.h"
#import "UnderlineLabel.h"
#import "MultiCell.h"

// vendor
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "TAPAsset.h"
#import "TAPConnection.h"
#import "TAPContent.h"
#import "TAPSource.h"
#import "TAPStop.h"
#import "TAPTour.h"
#import "VSTheme.h"


@interface TAPGridDetailViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) TAPStop *stop;
@property (nonatomic, strong) NSMutableArray *childStops;
@property (nonatomic, strong) NSArray *zoomStops;
@property (nonatomic) BOOL hideBackButton;
@property (nonatomic, weak) IBOutlet UILabel *themeName;
@property (nonatomic, weak) IBOutlet UIWebView *themeContent;
@property (nonatomic, weak) IBOutlet UICollectionView *artworkCollectionView;
@property (nonatomic, weak) IBOutlet UIPageControl *pager;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UILabel *instructionLabel;
@property (nonatomic, strong) VSTheme *theme;
- (IBAction)back:(id)sender;
@end

@implementation TAPGridDetailViewController

- (id)initWithConfigDictionary:(NSDictionary *)config {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self = [self initWithStop:[self.appDelegate.currentTour stopFromKeycode:[config objectForKey:@"keycode"]]];
    self.title = self.screenName = [config objectForKey:@"title"];
    self.hideBackButton = TRUE;
    return self;
}

- (id)initWithStop:(TAPStop *)stop
{
    self = [super init];
    if (self) {
        [self setStop:stop];
        
        // organize stops according to category
        self.childStops = [[NSMutableArray alloc] init];
        
        self.theme = self.appDelegate.theme;
        
        NSSortDescriptor *prioritySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority"
                                                                               ascending:YES];
        NSArray *prioritySortDescriptors = [NSArray arrayWithObject:prioritySortDescriptor];
        NSArray *connectionsSortedByPriority = [NSArray arrayWithArray:[[self.stop.sourceConnection allObjects] sortedArrayUsingDescriptors:prioritySortDescriptors]];
        for (TAPConnection *connection in connectionsSortedByPriority) {
            [self.childStops addObject:connection.destinationStop];
        }
        self.title = self.screenName = (NSString *)self.stop.title;
        self.hideBackButton = FALSE;
        
        _zoomStops = @[@"stop-584", @"stop-585", @"stop-586", @"stop-587"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.instructionLabel setHidden:YES];
    [self.instructionLabel setFont:[self.theme fontForKey:@"bodyFont"]];
    
    NSMutableString *tempName = [[NSMutableString alloc] initWithString:(NSString *)self.stop.title];
    if ([[tempName lowercaseString] rangeOfString:@"van"].location != NSNotFound) {
        [tempName replaceOccurrencesOfString:@"(" withString:@"\n(" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempName length])];
    }
    
    NSMutableAttributedString *themeName = [[NSMutableAttributedString alloc] initWithString:tempName];
    NSMutableParagraphStyle *themeNameParagraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    NSRange wholeStringRange = NSMakeRange(0, [themeName length]);
    themeNameParagraphStyle.minimumLineHeight = 20.0f;
    themeNameParagraphStyle.maximumLineHeight = 20.0f;
    [themeName addAttributes:@{ NSParagraphStyleAttributeName: themeNameParagraphStyle,
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSBackgroundColorAttributeName: [UIColor clearColor],
                                 NSFontAttributeName:[self.theme fontForKey:@"headingFont"]} range:wholeStringRange];
    [self.themeName setAttributedText:themeName];
    
    // set description
    NSString *htmlFileName = ([_zoomStops containsObject:[self.stop id]]) ? @"Content_with_image" : @"Content";

    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:htmlFileName ofType:@"html"];
    NSString *htmlContainer = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];

    NSMutableString *htmlString = [[NSMutableString alloc] init];
    if (([_zoomStops containsObject:[self.stop id]])) {
        [self.instructionLabel setHidden:NO];
        TAPStop *stopWithImage = [self.childStops objectAtIndex:0];
        TAPAsset *theImage = [[stopWithImage getAssetsByUsage:@"image_asset"] objectAtIndex:0];
        NSString *imageUri = [[[theImage getSourcesByPart:@"1150x1100"] objectAtIndex:0] uri];
        htmlString = [NSMutableString stringWithFormat:htmlContainer, imageUri, (NSString *)self.stop.desc];
    } else {
        UIFont *bodyFont = [self.theme fontForKey:@"bodyFont"];
        UIFont *bodyFontItalic = [self.theme fontForKey:@"bodyFontItalic"];
        htmlString = [NSMutableString stringWithFormat:htmlContainer,
                      [bodyFont fontName],
                      bodyFont.pointSize,
                      [bodyFontItalic fontName],
                      (NSString *)self.stop.desc];
    }
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.themeContent loadHTMLString:htmlString baseURL:baseURL];
    [self.themeContent.scrollView setBounces:NO];
    
    // register nib for uicollectionview
    [self.artworkCollectionView registerNib:[UINib nibWithNibName:@"MultiCell" bundle:nil] forCellWithReuseIdentifier:@"MultiCell"];
    
    // set up flowlayout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setItemSize:self.artworkCollectionView.bounds.size];
    [self.artworkCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.artworkCollectionView setCollectionViewLayout:flowLayout];
    if ([self.childStops count] == 1) {
        [self.artworkCollectionView setBounces:NO];
    }
    
    // set pager
    float pages = (float)[self.childStops count];
    self.pager.hidesForSinglePage = true;
    [self.pager setNumberOfPages:ceil(pages)];

    self.navigationController.navigationBarHidden = TRUE;
    
    if (self.hideBackButton) {
        [self.backButton removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.childStops count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // okay, let's grab that stop so we can find out what kind of stop the stop is. stop.
    TAPStop *contextStop = [self.childStops objectAtIndex:indexPath.row];
    NSString *stopView = contextStop.view;
    MultiCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MultiCell" forIndexPath:indexPath];

    // is this an image stop?
    if ([stopView isEqualToString:@"image_stop"]) {
        
        // set image, no video
        TAPAsset *imageAsset = [[contextStop getAssetsByUsage:@"image_asset"] objectAtIndex:0];
        if (([_zoomStops containsObject:[self.stop id]])) {
            // do instructions stuff here?
            [cell setupImageStopWithZoomImage:imageAsset stop:contextStop];
        } else {
            NSString *eventImage = [[[imageAsset getSourcesByPart:@"1150x1100"] objectAtIndex:0] uri];
            [cell setupImageStopWithImage:[UIImage imageWithContentsOfFile:eventImage] stop:contextStop];
        }
        
        // set description
        TAPContent *caption = [[imageAsset getContentsByPart:@"caption"] objectAtIndex:0];
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Caption" ofType:@"html"];
        NSString *htmlContainer = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        UIFont *bodyFont = [self.theme fontForKey:@"bodyFont"];
        UIFont *bodyFontItalic = [self.theme fontForKey:@"bodyFontItalic"];
        NSString *htmlString = [[NSString alloc] initWithFormat:htmlContainer,
                                [bodyFont fontName],
                                bodyFont.pointSize,
                                [bodyFontItalic fontName],
                                (NSString *)caption.data];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        [cell.caption setOpaque:NO];
        [cell.caption loadHTMLString:htmlString baseURL:baseURL];
    
    // no? video stop?
    } else if ([stopView isEqualToString:@"video_stop"]) {
        
        // grab assets to pass to cell, do not set a caption
        TAPAsset *imageAsset = [[contextStop getAssetsByUsage:@"image"] objectAtIndex:0];
        UIImage *placeholderImage = [UIImage imageWithContentsOfFile:[[[imageAsset source] anyObject] uri]];
        UIImage *playButtonImage = [UIImage imageNamed:@"play"];
        TAPAsset *videoAsset = [[contextStop getAssetsByUsage:@"video"] objectAtIndex:0];
        NSString *videoPath = [[[videoAsset source] anyObject] uri];
        NSURL *videoUrl = [NSURL fileURLWithPath:videoPath];
        [cell setupVideoStopWithVideoUrl:videoUrl stop:contextStop placeholderImage:placeholderImage playButtonImage:playButtonImage];
        
    }// for the future, deal with other stop type / views here
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // reset timer
    [(KioskApplication *)[[UIApplication sharedApplication] delegate] resetIdleTimer];
    
    CGFloat pageWidth = scrollView.frame.size.width;
    int index = floor((scrollView.contentOffset.x - pageWidth) / pageWidth) + 1;
    [self.pager setCurrentPage:index];
}

#pragma mark - Actions
- (IBAction)back:(id)sender
{
    // reset timer
    [(KioskApplication *)[[UIApplication sharedApplication] delegate] resetIdleTimer];
    
    // create fade transition
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
    
    // register event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction" action:@"Back" label:(NSString *)self.stop.title value:[NSNumber numberWithBool:TRUE]] build]];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}


@end
