//
//  EventsProgramsViewController.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "TAPWebViewContainerViewController.h"
#import "AppDelegate.h"
#import "ArrowView.h"

// vendor
#import "VSTheme.h"

@interface TAPWebViewContainerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *contentContainer;// @TODO refactor, rename stuff in here to express intent
@property (nonatomic, strong) ArrowView *arrowIndicator;
@property (nonatomic, strong) VSTheme *theme;
@end

@implementation TAPWebViewContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Events & Programs"];
        self.screenName = @"Events & Programs";
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.theme = appDelegate.theme;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIFont *bodyFont = [self.theme fontForKey:@"bodyFont"];
    UIFont *bodyFontItalic = [self.theme fontForKey:@"bodyFontItalic"];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"EventsPrograms" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.contentContainer loadHTMLString:[NSString stringWithFormat:htmlString,
                                              [bodyFont fontName],
                                              bodyFont.pointSize,
                                              [bodyFont fontName],
                                              bodyFont.pointSize,
                                              [bodyFont fontName],
                                              bodyFont.pointSize,
                                              [bodyFontItalic fontName]]
                                     baseURL:nil];
    [self.contentContainer.scrollView setBounces:NO];
    [self.contentContainer.scrollView setDelegate:self];
    
    // add arrow indicator animation
    self.arrowIndicator = [[ArrowView alloc] initWithFrame:CGRectMake(929.0f, 641.0f, 75.0f, 35.0f)];
    [self.view addSubview:self.arrowIndicator];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.contentContainer.scrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UIScrollViewDelegate

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

@end
