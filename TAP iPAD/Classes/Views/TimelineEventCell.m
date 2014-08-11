//
//  EventCell.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/18/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "AppDelegate.h"
#import "TimelineEventCell.h"
#import "VSTheme.h"

#define MAX_LABEL_WIDTH 225.0f

@interface TimelineEventCell ()
@property (nonatomic, strong) VSTheme *theme;
@end

@implementation TimelineEventCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if(self) {
        // add image view
        self.eventImage = [[UIImageView alloc] init];
        [self addSubview:self.eventImage];
        
        // add event title
        self.eventTitle = [[UIImageView alloc] init];
        [self addSubview:self.eventTitle];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.theme = appDelegate.theme;
    }
    return self;
}

- (void)setupLayout
{
    CGSize imageTitleSize = [self.eventTitle.image size];
    
    UIView *lineView;
    
    // calculate image width assuming fixed height
    CGFloat imageHeight = 200.0f;
    CGFloat imageWidth = self.eventImage.image.size.width / 2;
    
    // set the position of the title depending on the cell direction
    if (self.flipCell) {
        [self.eventImage setFrame:CGRectMake((self.frame.size.width / 2) - 100, self.center.y + 100.0f, imageWidth, imageHeight)];
        [self.eventTitle setFrame:CGRectMake((self.frame.size.width / 2) - imageTitleSize.width/2/2, self.center.y - 28.0f - imageTitleSize.height/2,
                                             imageTitleSize.width/2, imageTitleSize.height/2)];
        self.eventTitle.center = CGPointMake(self.eventImage.center.x, self.eventTitle.center.y);// reset the center, just to be sure (yeah, I know)
        lineView = [[UIView alloc] initWithFrame:CGRectMake(self.eventImage.center.x, self.center.y, 2, 118.0f)];
    } else {
        [self.eventImage setFrame:CGRectMake((self.frame.size.width / 2) - 100, 30.0f, imageWidth, imageHeight)];
        [self.eventTitle setFrame:CGRectMake((self.frame.size.width / 2) - imageTitleSize.width/2/2, self.center.y + 48.0f,
                                             imageTitleSize.width/2, imageTitleSize.height/2)];
        self.eventTitle.center = CGPointMake(self.eventImage.center.x, self.eventTitle.center.y);// reset the center, just to be sure (yeah, I know)
        lineView = [[UIView alloc] initWithFrame:CGRectMake(self.eventImage.center.x, self.eventImage.center.y + 100.0f, 2, 118.0f)];
    }

    // set image layer properties
    [self.eventImage.layer setMasksToBounds:YES];
    [self.eventImage.layer setBorderWidth:2.0f];
    [self.eventImage.layer setBorderColor:[[self.theme colorForKey:@"accentColor"] CGColor]];
    
    // set line color
    [lineView setBackgroundColor:[self.theme colorForKey:@"accentColor"]];
    
    // add subviews
    [self addSubview:lineView];
    [self sendSubviewToBack:lineView];
}

/**
 * Override (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event to allow objects in the cell to be clickable that weren't clickable
 * previously due to the view being to small
 */
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}

@end
