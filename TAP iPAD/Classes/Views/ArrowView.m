//
//  ArrowView.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/11/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "ArrowView.h"

@interface ArrowView()
- (void)initializeAnimation;
@end

@implementation ArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeAnimation];
    }
    return self;
}

- (void)initializeAnimation
{
    NSArray * imageArray  = [[NSArray alloc] initWithObjects:
                             [UIImage imageNamed:@"arrow-blank.png"],
                             [UIImage imageNamed:@"arrow-3.png"],
                             [UIImage imageNamed:@"arrow-2.png"],
                             [UIImage imageNamed:@"arrow-1.png"],
                             nil];
    [self setAnimationImages:imageArray];
    [self setAnimationDuration:3.5];
    [self setAnimationRepeatCount:0];
    [self startAnimating];
}

@end
