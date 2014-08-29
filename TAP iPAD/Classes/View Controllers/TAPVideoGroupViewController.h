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

@interface TAPVideoGroupViewController : TAPBaseViewController<UICollectionViewDataSource>
- (id)initWithStopTitle:(NSString *)stopTitle keycode:(NSString *)keycode trackedViewName:(NSString *)trackedViewName;
@end
