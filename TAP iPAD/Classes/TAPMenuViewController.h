//
//  MenuViewController.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/5/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TAPMenuViewController : UIViewController

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *currentViewController;
@property (nonatomic, assign) NSUInteger currentIndex;

- (void)setViewControllers:(NSArray *)newViewControllers;
- (void)resetViewController;

@end
