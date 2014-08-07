//
//  ImageStopViewController.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "ImageStopViewController.h"
#import "AppDelegate.h"
#import "UnderlineLabel.h"
#import "TAPStop.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPContent.h"

// categories
#import "UIImage+Resize.h"

// vendor
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "VSTheme.h"


@interface ImageStopViewController ()
@property (nonatomic, strong) TAPStop *stop;
@property (nonatomic, weak) IBOutlet UILabel *imageTitle;
@property (nonatomic, weak) IBOutlet UIWebView *imageCaption;
@property (nonatomic, weak) IBOutlet UIWebView *content;
@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, strong) VSTheme *theme;

- (IBAction)back:(id)sender;
@end

@implementation ImageStopViewController

- (id)initWithStop:(TAPStop *)stop
{
    self = [super init];
    if (self) {
        [self setStop:stop];
        self.title = self.screenName = (NSString *)self.stop.title;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.theme = appDelegate.theme;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set title
    [self.imageTitle setText:(NSString *)self.stop.title];
    [self.imageTitle setFont:[self.theme fontForKey:@"headingFont"]];
    
    // set description
    NSString *htmlContentFile = [[NSBundle mainBundle] pathForResource:@"Content" ofType:@"html"];// alter here, pass in font face name I guess?
    NSString *htmlContentContainer = [NSString stringWithContentsOfFile:htmlContentFile encoding:NSUTF8StringEncoding error:nil];
    
    UIFont *bodyFont = [self.theme fontForKey:@"bodyFont"];
    UIFont *bodyFontItalic = [self.theme fontForKey:@"bodyFontItalic"];
    
    NSString *htmlContentString = [[NSString alloc] initWithFormat:htmlContentContainer,
                                   [bodyFont fontName],
                                   bodyFont.pointSize,
                                   [bodyFontItalic fontName],
                                   (NSString *)self.stop.desc];
    [self.content loadHTMLString:htmlContentString baseURL:nil];
    [self.content.scrollView setBounces:NO];
    
    // set image
    TAPAsset *imageAsset = [[self.stop getAssetsByUsage:@"image_asset"] objectAtIndex:0];
    NSString *image = [[[imageAsset getSourcesByPart:@"1150x1100"] objectAtIndex:0] uri];
    [self.image setImage:[UIImage imageWithContentsOfFile:image]];
    
    // set image caption
    TAPContent *caption = [[imageAsset getContentsByPart:@"caption"] objectAtIndex:0];
    NSString *htmlCaptionFile = [[NSBundle mainBundle] pathForResource:@"Caption" ofType:@"html"];
    NSString *htmlCaptionContainer = [NSString stringWithContentsOfFile:htmlCaptionFile encoding:NSUTF8StringEncoding error:nil];
    NSString *htmlCaptionString = [[NSString alloc] initWithFormat:htmlCaptionContainer,
                                   [bodyFont fontName],
                                   bodyFont.pointSize,
                                   [bodyFontItalic fontName],
                                   caption.data];
    [self.imageCaption loadHTMLString:htmlCaptionString baseURL:nil];
    [self.imageCaption.scrollView setBounces:NO];

    // calculate position of caption label based on the positioning of the image inside of the uiimageview
    CGSize imageInViewSize = [self.image.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:self.image.frame.size interpolationQuality:kCGInterpolationNone].size;
    CGRect overlayRect = CGRectMake((self.image.frame.size.width - imageInViewSize.width) / 2,
                                    (self.image.frame.size.height - imageInViewSize.height) / 2,
                                    imageInViewSize.width,
                                    imageInViewSize.height);
    float imageCaptionY = overlayRect.origin.y + self.image.frame.origin.y + overlayRect.size.height + 10.0f;
        
    // set label frame
    CGSize maximumLabelSize = CGSizeMake(575.0f, 999.0f);
    
// deprecated, replaced with below, but is this equivalent? doesn't take line break mode into account afaict
//    CGSize expectedLabelSize = [caption.data sizeWithFont:[self.theme fontForKey:@"bodyFont"]
//                                        constrainedToSize:maximumLabelSize
//                                            lineBreakMode:NSLineBreakByWordWrapping];
    NSAttributedString *captionAttributedString = [[NSAttributedString alloc] initWithString:caption.data attributes:@{
                                                                                                                       NSFontAttributeName:[self.theme fontForKey:@"bodyFont"]
                                                                                                                       }];
    CGRect rect = [captionAttributedString boundingRectWithSize:maximumLabelSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil];
    CGSize expectedLabelSize = rect.size;
    
    [self.imageCaption setFrame:CGRectMake(self.imageCaption.frame.origin.x, imageCaptionY, 575.0f, expectedLabelSize.height + 15.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction" action:@"Back" label:(NSString *)self.stop.title value:[NSNumber numberWithBool:TRUE]] build]];
}

@end
