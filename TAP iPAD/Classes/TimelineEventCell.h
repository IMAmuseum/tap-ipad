//
//  EventCell.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/18/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "TimelineViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface TimelineEventCell : TimelineViewCell
@property (nonatomic, assign) BOOL flipCell;
@property (nonatomic, strong) UIImageView *eventTitle;
@property (nonatomic, strong) UIImageView *eventImage;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
- (void)setupLayout;
@end
