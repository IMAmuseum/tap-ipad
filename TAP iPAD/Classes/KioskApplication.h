//
//  KioskApplication.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/24/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kApplicationTimeoutInMinutes 3
#define kApplicationDidTimeoutNotification @"AppTimeOut"

@interface KioskApplication : UIResponder {
    NSTimer *_idleTimer;
    BOOL _hasSession;
}

- (void)resetIdleTimer;
- (void)startSession;
- (void)endSession;

@end
