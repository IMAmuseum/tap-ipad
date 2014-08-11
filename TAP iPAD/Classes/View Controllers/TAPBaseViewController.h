//
//  TAPBaseViewController.h
//  TAP iPAD
//
//  Created by David D'Amico on 6/3/14.
//  Copyright (c) 2014 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface TAPBaseViewController : GAITrackedViewController
- (id)initWithConfigDictionary:(NSDictionary *)config;
@end
