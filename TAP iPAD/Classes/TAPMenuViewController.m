//
//  MenuViewController.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/5/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "TAPMenuViewController.h"
#import "AppDelegate.h"

// vendor
#import "VSTheme.h"

#define TAG_OFFSET 1000
#define MENU_SPACING 20

@interface TAPMenuViewController ()
@property (retain, nonatomic)  UIView *activeMenuIndicator;
@property (weak, nonatomic) IBOutlet UIView *menuContainerView;
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (weak, nonatomic) IBOutlet UIView *menuDropShow;
@property (weak, nonatomic) IBOutlet UIImageView *headerBgImageView;
@property (nonatomic, strong) VSTheme *theme;


- (void)setNavigation;
- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated;
- (void)navigationItemPressed:(UIButton *)sender;
- (IBAction)navigateToHome:(id)sender;
@end

@implementation TAPMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.theme = appDelegate.theme;
    
    [self.menuDropShow.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.menuDropShow.layer setMasksToBounds:NO];
    [self.menuDropShow.layer setShadowOffset:CGSizeMake(0, 2)];
    [self.menuDropShow.layer setShadowRadius:0.0f];
    [self.menuDropShow.layer setShadowOpacity:0.05f];
    [self.menuDropShow setBackgroundColor:[UIColor whiteColor]];

    // setup navigation
    [self setNavigation];
    
    // add active menu indicator
    self.activeMenuIndicator = [[UIView alloc] init];
    [self.activeMenuIndicator setBackgroundColor:[UIColor colorWithRed:192.0/255.0 green:62.0/255.0 blue:25.0/255.0 alpha:1.0]];
    [self.menuContainerView addSubview:self.activeMenuIndicator];
    
    // set the current view controller
    [self setSelectedViewController:[self.viewControllers objectAtIndex:self.currentIndex] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
        self.contentContainerView = nil;
        self.menuContainerView = nil;
    }
}

- (void)setViewControllers:(NSArray *)newViewControllers
{
    NSAssert([newViewControllers count] >= 1, @"MenuViewController requires at least one view controller");
    
	// Remove the old child view controllers.
	for (UIViewController *viewController in self.viewControllers) {
		[viewController willMoveToParentViewController:nil];
		[viewController removeFromParentViewController];
	}
    
	_viewControllers = [newViewControllers copy];
    
    // Add the new child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
	}
    
    [self setNavigation];
}

- (void)setNavigation
{
    // initialize current index
    self.currentIndex = 0;
    
    // remove existing menu items
    while ([self.menuContainerView.subviews count] > 0) {
		[[self.menuContainerView.subviews lastObject] removeFromSuperview];
	}
    
    NSUInteger index = 0;
    float previousWidth = 0;

	for (UIViewController *viewController in self.viewControllers) {
        if ([viewController.title isEqualToString:@"Home"]) {
            ++index;
            continue;
        }
        
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button setTag:TAG_OFFSET + index];
        [button.titleLabel setFont:[self.theme fontForKey:@"headingFont"]];
		[button setTitle:[viewController.title uppercaseString] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(navigationItemPressed:) forControlEvents:UIControlEventTouchDown];
        [button.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        CGSize fontSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
        //CGSize fontSize = [button.titleLabel.text sizeWithFont:button.titleLabel.font];
        CGRect buttonFrame = CGRectMake(previousWidth, 10.0f, fontSize.width + 20.0f, 65.0f);
        [button setFrame:buttonFrame];
        
		[self.menuContainerView addSubview:button];
        
        previousWidth += fontSize.width + 20.0f + MENU_SPACING;

		++index;
	}
}

- (void)resetViewController
{
    if ([self.viewControllers count] == 0) return;
    
    self.currentIndex = 0;
    [self setSelectedViewController:[self.viewControllers objectAtIndex:0] animated:YES];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated
{
    // reset navigation stack
    if ([newSelectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)newSelectedViewController;
        [navigationController popToRootViewControllerAnimated:NO];
    }
    
    // force the issue re: new view sizing for ios7
    [newSelectedViewController.view setFrame:CGRectMake(0, 0, 1024, 693)];

    // do nothing if we're already at the stop
    if (newSelectedViewController == self.currentViewController) return;
    
    [self.menuContainerView setUserInteractionEnabled:NO];
    if (self.currentViewController == nil) {
        newSelectedViewController.view.frame = self.contentContainerView.bounds;
        [self.contentContainerView addSubview:newSelectedViewController.view];
        [self.menuContainerView setUserInteractionEnabled:YES];
    } else {
        if (animated) {         
            [self transitionFromViewController:self.currentViewController
                              toViewController:newSelectedViewController
                                    duration:0.5
                                    options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:nil
                                    completion:^(BOOL finished) {
                                        [self.menuContainerView setUserInteractionEnabled:YES];
                                    }];
        } else {
            [self.currentViewController.view removeFromSuperview];
            [self.contentContainerView addSubview:newSelectedViewController.view];
        }
    }
    
    UIButton *selectedButton = (UIButton *)[self.menuContainerView viewWithTag:TAG_OFFSET + self.currentIndex];
    [self setNavigationActiveIndicator:selectedButton animated:animated];
    
    self.currentViewController = newSelectedViewController;
}

- (void)navigationItemPressed:(UIButton *)sender
{
    // reset timer
    [(KioskApplication *)[[UIApplication sharedApplication] delegate] resetIdleTimer];
    
    self.currentIndex = sender.tag - TAG_OFFSET;
    UIViewController *selectedViewController = [self.viewControllers objectAtIndex:self.currentIndex];
    [self setSelectedViewController:selectedViewController animated:YES];
}

- (void)setNavigationActiveIndicator:(UIButton *)button animated:(BOOL)animated
{
    CGRect rect = self.activeMenuIndicator.frame;
	rect.origin.x = button.center.x - ((button.frame.size.width - 10) / 2);
	rect.origin.y = self.menuContainerView.frame.size.height - 15 - self.activeMenuIndicator.frame.size.height;
    
    // @TODO got a bug here, the initial y origin of rect is off
//    NSLog(@"origin.y: %f, which is %f - 15 - %f", rect.origin.y, self.menuContainerView.frame.size.height, self.activeMenuIndicator.frame.size.height);
    
    rect.size.height = 2.5f;
    
    if (button == nil) {
        rect.size.width = 0;
        animated = NO;
    } else {
        rect.size.width = button.frame.size.width - 10;
    }
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.activeMenuIndicator.frame = rect;
        
        [UIView commitAnimations];
    } else {
        self.activeMenuIndicator.frame = rect;
    }
}

#pragma mark - Actions

- (IBAction)navigateToHome:(id)sender
{
    if ([self.viewControllers count] == 0) return;
    
    self.currentIndex = 0;
    [self setSelectedViewController:[self.viewControllers objectAtIndex:0] animated:YES];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}


@end
