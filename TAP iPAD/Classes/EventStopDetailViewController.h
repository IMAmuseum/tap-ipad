//
//  EventStopDetailViewController.h
//  TAP iPAD
//
//  Created by David D'Amico on 9/27/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GAITrackedViewController.h"
#import "TAPStop.h"

@interface EventStopDetailViewController : GAITrackedViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) TAPStop *eventStop;
@property (nonatomic, strong) NSArray *artworkAssets;
@property (nonatomic, weak) IBOutlet UILabel *stopTitle;
@property (nonatomic, weak) IBOutlet UIWebView *content;
@property (nonatomic, weak) IBOutlet UICollectionView *artworkCollection;
@property (nonatomic, weak) IBOutlet UIPageControl *pager;

- (id)initWithEventStop:(TAPStop *)eventStop;
- (IBAction)back:(id)sender;
@end
