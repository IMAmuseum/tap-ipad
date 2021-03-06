//
//  TAPWebViewContainerViewController.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPBaseViewController.h"
#import "GAITrackedViewController.h"

@interface TAPWebViewContainerViewController : TAPBaseViewController <UIScrollViewDelegate>
- (id)initWithConfigDictionary:(NSDictionary *)config;
@end
