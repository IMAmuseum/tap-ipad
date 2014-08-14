//
//  TAPHelper.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/21/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "TAPHelper.h"
#import "ISO8601DateFormatter.h"

@implementation TAPHelper
/**
 * Converts a given date string of yyyy-MM-dd'T'HH:mm:ss and converts
 * it to a NSDate.
 */
+ (NSDate *)convertStringToDate:(NSString *)dateString
{
    if (dateString == nil) return nil;
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *date = [formatter dateFromString:dateString];
    formatter = nil;
    return date;
}
@end
