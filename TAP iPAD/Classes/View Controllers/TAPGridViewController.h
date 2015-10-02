//
//  TAPGridViewController.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TAPBaseViewController.h"

@interface TAPGridViewController : TAPBaseViewController <UICollectionViewDataSource>
- (id)initWithConfigDictionary:(NSDictionary *)config;
- (id)initWithStopTitle:(NSString *)stopTitle keycode:(NSString *)keycode trackedViewName:(NSString *)trackedViewName itemsPerRow:(NSInteger)itemsPerRow columnWidth:(CGFloat)columnWidth rowHeight:(CGFloat)rowHeight verticalSpacing:(CGFloat)verticalSpacing scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (void)initializeVideo;
- (void)moviePlayBackDidFinish:(NSNotification *)notification;
@end
