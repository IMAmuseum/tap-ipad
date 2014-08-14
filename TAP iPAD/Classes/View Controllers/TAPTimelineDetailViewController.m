//
//  EventStopDetailViewController.m
//  TAP iPAD
//
//  Created by David D'Amico on 9/27/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "TAPTimelineDetailViewController.h"
#import "AppDelegate.h"
#import "TAPStop.h"
#import "TAPConnection.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPContent.h"
#import "UIImage+Resize.h"
#import "MultiCell.h"

// vendor
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "VSTheme.h"

@interface TAPTimelineDetailViewController ()
@property (nonatomic, strong) VSTheme *theme;
@end

@implementation TAPTimelineDetailViewController

- (id)initWithEventStop:(TAPStop *)eventStop {
    self = [super init];
    if (self) {
        [self setEventStop:eventStop];
        self.title = self.screenName = (NSString *)self.eventStop.title;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.theme = appDelegate.theme;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.artworkCollection.delegate = self;
    self.artworkCollection.dataSource = self;
    [self.artworkCollection setBackgroundColor:[UIColor clearColor]];
    
    [self setArtworkAssets:[self.eventStop getAssetsByUsageOrderByParseIndex:@"image_asset"]];
    
    NSMutableAttributedString *eventTitle = [[NSMutableAttributedString alloc] initWithString:(NSString *)self.eventStop.title];
    NSMutableParagraphStyle *eventTitleParagraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    eventTitleParagraphStyle.minimumLineHeight = 20.0f;
    eventTitleParagraphStyle.maximumLineHeight = 20.0f;
    [eventTitle addAttributes:@{ NSParagraphStyleAttributeName: eventTitleParagraphStyle,
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSBackgroundColorAttributeName: [UIColor clearColor],
                                 NSFontAttributeName:[self.theme fontForKey:@"headingFont"]} range:NSMakeRange(0, [eventTitle length])];
    [self.stopTitle setAttributedText:eventTitle];
    
    UIFont *bodyFont = [self.theme fontForKey:@"bodyFont"];
    UIFont *bodyFontItalic = [self.theme fontForKey:@"bodyFontItalic"];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Content" ofType:@"html"];
    NSString *htmlContainer = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    NSString *htmlString = [[NSString alloc] initWithFormat:htmlContainer,
                            [bodyFont fontName],
                            bodyFont.pointSize,
                            [bodyFontItalic fontName],
                            (NSString *)self.eventStop.desc];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.content loadHTMLString:htmlString baseURL:baseURL];
    [self.content.scrollView setBounces:NO];
    [self.content setBackgroundColor:[UIColor clearColor]];
    
    // register nib for uicollectionview
    [self.artworkCollection registerNib:[UINib nibWithNibName:@"MultiCell" bundle:nil] forCellWithReuseIdentifier:@"MultiCell"];

    // set up flowlayout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setItemSize:self.artworkCollection.bounds.size];
    [self.artworkCollection setShowsHorizontalScrollIndicator:NO];
    [self.artworkCollection setCollectionViewLayout:flowLayout];

    // set pager
    float pages = (float)[self.artworkAssets count];
    self.pager.hidesForSinglePage = true;
    [self.pager setNumberOfPages:ceil(pages)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.artworkAssets count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MultiCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MultiCell" forIndexPath:indexPath];
    TAPAsset *eventAsset = [self.artworkAssets objectAtIndex:indexPath.row];
    NSString *eventImage = [[[eventAsset getSourcesByPart:@"1150x1100"] objectAtIndex:0] uri];
    [cell setupImageStopWithImage:[UIImage imageWithContentsOfFile:eventImage] stop:self.eventStop];
    
    UIFont *bodyFont = [self.theme fontForKey:@"bodyFont"];
    UIFont *bodyFontItalic = [self.theme fontForKey:@"bodyFontItalic"];
    TAPContent *caption = [[eventAsset getContentsByPart:@"caption"] objectAtIndex:0];
    NSString *htmlCaptionFile = [[NSBundle mainBundle] pathForResource:@"Caption" ofType:@"html"];
    NSString *htmlCaptionContainer = [NSString stringWithContentsOfFile:htmlCaptionFile encoding:NSUTF8StringEncoding error:nil];
    NSString *htmlCaptionString = [[NSString alloc] initWithFormat:htmlCaptionContainer,
                                   [bodyFont fontName],
                                   bodyFont.pointSize,
                                   [bodyFontItalic fontName],
                                   caption.data];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [cell.caption loadHTMLString:htmlCaptionString baseURL:baseURL];
    [cell.caption.scrollView setBounces:NO];
    
    return cell;
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
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction" action:@"Back" label:(NSString *)self.eventStop.title value:[NSNumber numberWithBool:TRUE]] build]];
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

@end
