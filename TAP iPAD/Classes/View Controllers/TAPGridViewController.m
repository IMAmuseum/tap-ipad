//
//  ThemesViewController.m
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
#import "TAPTour.h"
#import "TAPStop.h"
#import "TAPConnection.h"
#import "TAPAsset.h"
#import "TAPSource.h"

// vendor
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

- (id)initWithStopTitle:(NSString *)stopTitle keycode:(NSString *)keycode trackedViewName:(NSString *)trackedViewName itemsPerRow:(NSInteger)itemsPerRow columnWidth:(CGFloat)columnWidth rowHeight:(CGFloat)rowHeight verticalSpacing:(CGFloat)verticalSpacing scrollDirection:(UICollectionViewScrollDirection)scrollDirection
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
        
        //hack for face2face
        if ([[self.stop getPropertyValueByName:@"code"] isEqualToString:@"400"]) {
            UIImage *tapImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post-impressionism" ofType:@"png"]];
            [self.themeStopImages addObject:tapImage];
        }
        
        NSSortDescriptor *prioritySort = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
        for (TAPConnection *connection in [self.stop.sourceConnection sortedArrayUsingDescriptors:[NSArray arrayWithObject:prioritySort]]) {
            [self.themeStops addObject:connection.destinationStop];
            
            TAPAsset *themeAsset = [[connection.destinationStop getAssetsByUsage:@"header_image"] objectAtIndex:0];
            NSString *themeImage = [[[themeAsset source] anyObject] uri];
            UIImage *tapImage = [UIImage imageWithContentsOfFile:themeImage];
            [self.themeStopImages addObject:tapImage];
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
    
    //hack for face2face
    if ([[self.stop getPropertyValueByName:@"code"] isEqualToString:@"400"] && indexPath.row == 0) {
        return;
    }
    
    // get selected stop and initialize theme stop controller
    //hack for face2face (row - 1)
    NSInteger useIndex = indexPath.row;
    if ([[self.stop getPropertyValueByName:@"code"] isEqualToString:@"400"]) {
        useIndex -= 1;
    }
    
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

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
