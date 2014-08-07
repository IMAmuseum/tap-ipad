//
//  NSDictionary+TAPUtils.h
//  TAP iPAD
//
//  Created by David D'Amico on 6/3/14.
//  Copyright (c) 2014 IMA Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (TAPUtils)
- (NSArray *)containsKeysIn:(NSArray *)targetKeys;
- (BOOL)containsAllKeysIn:(NSArray *)targetKeys;
@end
