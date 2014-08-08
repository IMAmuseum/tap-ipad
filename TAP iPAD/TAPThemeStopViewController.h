//
//  ThemeStopViewController.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TAPBaseViewController.h"

@class TAPStop;

@interface TAPThemeStopViewController : TAPBaseViewController <UICollectionViewDataSource, UIWebViewDelegate>
- (id)initWithConfigDictionary:(NSDictionary *)config;
- (id)initWithStop:(TAPStop *)stop;
@end
