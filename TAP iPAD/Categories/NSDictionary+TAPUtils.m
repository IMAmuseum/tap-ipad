//
//  NSDictionary+TAPUtils.m
//  TAP iPAD
//
//  Created by David D'Amico on 6/3/14.
//  Copyright (c) 2014 IMA Lab. All rights reserved.
//

#import "NSDictionary+TAPUtils.h"

@implementation NSDictionary (TAPUtils)
- (NSArray *)containsKeysIn:(NSArray *)targetKeys {
    NSMutableArray *containedKeys = [[NSMutableArray alloc] init];
    NSArray *keys = [self allKeys];
    for (NSString* key in targetKeys) {
        if ([keys containsObject:key]) {
            [containedKeys addObject:key];
        }
    }
    return [NSArray arrayWithArray:containedKeys];
}
- (BOOL)containsAllKeysIn:(NSArray *)targetKeys {
    return ([[NSSet setWithArray:targetKeys] isEqualToSet:[NSSet setWithArray:[self allKeys]]] ||
            [[NSSet setWithArray:targetKeys] isSubsetOfSet:[NSSet setWithArray:[self allKeys]]]);
}
@end
