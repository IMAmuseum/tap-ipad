//
//  EventStopViewController.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GAITrackedViewController.h"

@class TAPStop;

@interface EventsStopViewController : GAITrackedViewController <UIScrollViewDelegate, UICollectionViewDataSource>

- (id)initWithEvents:(NSArray *)events withStartingIndex:(NSInteger)index;
@end
