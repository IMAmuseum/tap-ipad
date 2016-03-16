//
//  TAPInterviewsViewController.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "TAPBaseViewController.h"
#import "TAPStop.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TAPVideoGroupViewController : TAPBaseViewController<UICollectionViewDataSource>

@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;

- (id)initWithStopTitle:(NSString *)stopTitle stop:(TAPStop *)stop trackedViewName:(NSString *)trackedViewName;
- (void)playVideoWithUrl:(NSURL *)url;

@end
