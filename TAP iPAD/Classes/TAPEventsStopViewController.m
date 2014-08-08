//
//  EventStopViewController.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "TAPEventsStopViewController.h"
#import "AppDelegate.h"
#import "EventStopCell.h"
#import "TAPStop.h"
#import "TAPConnection.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPContent.h"
#import "UIImage+Resize.h"

// vendor
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "VSTheme.h"

@interface TAPEventsStopViewController () {
    int _initialIndex;
}
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) TAPStop *eventStop;
@property (nonatomic, strong) VSTheme *theme;
- (IBAction)back:(id)sender;
@end

@implementation TAPEventsStopViewController

- (id)initWithEvents:(NSArray *)events withStartingIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _initialIndex = (int)index;
        [self setEvents:events];
        TAPStop *eventStop = [self.events objectAtIndex:_initialIndex];
        self.title = self.screenName = (NSString *)eventStop.title;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.theme = appDelegate.theme;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEventStop:[self.events objectAtIndex:_initialIndex]];
    [self.collectionView setScrollEnabled:FALSE];
    [self.collectionView setContentOffset:CGPointMake(_initialIndex * self.view.frame.size.width, 0) animated:NO];
    [self.collectionView registerNib:[UINib nibWithNibName:@"EventStopCell" bundle:nil] forCellWithReuseIdentifier:@"EventStopCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.events count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TAPStop *eventStop = [self.events objectAtIndex:indexPath.row];

    EventStopCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"EventStopCell" forIndexPath:indexPath];
    
    NSMutableAttributedString *eventTitle = [[NSMutableAttributedString alloc] initWithString:(NSString *)eventStop.title];
    NSMutableParagraphStyle *eventTitleParagraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    NSRange wholeStringRange = NSMakeRange(0, [eventTitle length]);
    eventTitleParagraphStyle.minimumLineHeight = 20.0f;
    eventTitleParagraphStyle.maximumLineHeight = 20.0f;
    [eventTitle addAttributes:@{ NSParagraphStyleAttributeName: eventTitleParagraphStyle,
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSBackgroundColorAttributeName: [UIColor clearColor],
                                 NSFontAttributeName:[self.theme fontForKey:@"headingFont"]} range:wholeStringRange];
    [cell.imageTitle setAttributedText:eventTitle];
    
    UIFont *bodyFont = [self.theme fontForKey:@"bodyFont"];
    UIFont *bodyFontItalic = [self.theme fontForKey:@"bodyFontItalic"];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Content" ofType:@"html"];
    NSString *htmlContainer = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    NSString *htmlString = [[NSString alloc] initWithFormat:htmlContainer,
                            [bodyFont fontName],
                            bodyFont.pointSize,
                            [bodyFontItalic fontName],
                            (NSString *)eventStop.desc];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [cell.content loadHTMLString:htmlString baseURL:baseURL];
    [cell.content.scrollView setBounces:NO];
    [cell.content.scrollView setDelegate:self];
    
    // set event image
    TAPAsset *eventAsset = [[eventStop getAssetsByUsage:@"image_asset"] objectAtIndex:0];
    NSString *eventImage = [[[eventAsset getSourcesByPart:@"1150x1100"] objectAtIndex:0] uri];
    [cell.image setImage:[UIImage imageWithContentsOfFile:eventImage]];
    
    // calculate position of caption label based on the positioning of the image inside of the uiimageview
    CGSize imageInViewSize = [cell.image.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:cell.image.frame.size interpolationQuality:kCGInterpolationNone].size;
    CGRect overlayRect = CGRectMake((cell.image.frame.size.width - imageInViewSize.width) / 2,
                                    (cell.image.frame.size.height - imageInViewSize.height) / 2,
                                    imageInViewSize.width,
                                    imageInViewSize.height);
    float imageCaptionY = overlayRect.origin.y + cell.image.frame.origin.y + overlayRect.size.height + 10.0f;
        
    // set image caption
    TAPContent *caption = [[eventAsset getContentsByPart:@"caption"] objectAtIndex:0];
    NSString *htmlCaptionFile = [[NSBundle mainBundle] pathForResource:@"Caption" ofType:@"html"];
    NSString *htmlCaptionContainer = [NSString stringWithContentsOfFile:htmlCaptionFile encoding:NSUTF8StringEncoding error:nil];
    NSString *htmlCaptionString = [[NSString alloc] initWithFormat:htmlCaptionContainer,
                                   [bodyFont fontName],
                                   bodyFont.pointSize,
                                   [bodyFontItalic fontName],
                                   caption.data];
    [cell.imageCaption loadHTMLString:htmlCaptionString baseURL:nil];
    [cell.imageCaption.scrollView setBounces:NO];
    
    // set label frame
    CGSize maximumLabelSize = CGSizeMake(575.0f, 999.0f);

    // deprecated
//    CGSize expectedLabelSize = [caption.data sizeWithFont:[self.theme fontForKey:@"bodyFont"] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    NSAttributedString *captionAttributedString = [[NSAttributedString alloc] initWithString:caption.data attributes:@{
                                                                                                                       NSFontAttributeName:[self.theme fontForKey:@"bodyFont"]
                                                                                                                       }];
    CGRect rect = [captionAttributedString boundingRectWithSize:maximumLabelSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil];
    CGSize expectedLabelSize = rect.size;
    [cell.imageCaption setFrame:CGRectMake(cell.imageCaption.frame.origin.x, imageCaptionY, 575.0f, expectedLabelSize.height + 15.0f)];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // reset timer
    [(KioskApplication *)[[UIApplication sharedApplication] delegate] resetIdleTimer];
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

@end
