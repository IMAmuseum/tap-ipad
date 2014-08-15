//
//  TAPWebViewContainerViewController.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "AppDelegate.h"
#import "ArrowView.h"
#import "NSDictionary+TAPUtils.h"
#import "TAPWebViewContainerViewController.h"

// vendor
#import "VSTheme.h"

@interface TAPWebViewContainerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *contentContainer;
@property (nonatomic, strong) ArrowView *arrowIndicator;
@property (nonatomic, strong) VSTheme *theme;
@property (nonatomic, strong) NSString *htmlFile;
@end

@implementation TAPWebViewContainerViewController

- (id)initWithConfigDictionary:(NSDictionary *)config {
    
    self = [super init];
    if (self) {
        NSArray *requiredKeys = @[@"title", @"htmlResourceName"];
        if ([config containsAllKeysIn:requiredKeys]) {
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.theme = appDelegate.theme;
            
            [self setTitle:[config objectForKey:@"title"]];
            self.screenName = [config objectForKey:@"title"];
            self.htmlFile = [[NSBundle mainBundle] pathForResource:[config objectForKey:@"htmlResourceName"] ofType:@"html"];
            
        } else {
            self = nil;
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *htmlString = [NSString stringWithContentsOfFile:self.htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.contentContainer loadHTMLString:htmlString baseURL:nil];
    [self.contentContainer.scrollView setBounces:NO];
    [self.contentContainer.scrollView setDelegate:self];
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
