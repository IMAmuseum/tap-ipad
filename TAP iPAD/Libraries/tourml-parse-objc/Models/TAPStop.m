//
//  TAPStop.m
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "TAPStop.h"
#import "TAPAssetRef.h"
#import "TAPConnection.h"
#import "TAPProperty.h"
#import "TAPTour.h"
#import "AppDelegate.h"
#import "ISO8601DateFormatter.h"

@implementation TAPStop

@dynamic desc;
@dynamic id;
@dynamic title;
@dynamic view;
@dynamic assetRef;
@dynamic destinationConnection;
@dynamic parseIndex;
@dynamic propertySet;
@dynamic sourceConnection;
@dynamic tour;
@dynamic tourRootStop;

/**
 * Overriden getter that returns the localized title
 */
- (NSString *)title 
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self willAccessValueForKey:@"title"];
    NSDictionary *title = [self primitiveValueForKey:@"title"];
    [self didAccessValueForKey:@"title"];
    
    if ([title objectForKey:[appDelegate language]]) {
        return [title objectForKey:[appDelegate language]];
    } else if ([title objectForKey:@"en"]) {
        return [title objectForKey:@"en"];
    } else {
        return [title objectForKey:@""];
    }
}

/**
 * Overriden getter that returns the localized description
 */
- (NSString *)desc 
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self willAccessValueForKey:@"desc"];
    NSDictionary *description = [self primitiveValueForKey:@"desc"];
    [self didAccessValueForKey:@"desc"];
    
    if ([description objectForKey:[appDelegate language]]) {
        return [description objectForKey:[appDelegate language]];
    } else if ([description objectForKey:@"en"]) {
        return [description objectForKey:@"en"];
    } else {
        return [description objectForKey:@""];
    }
}

/**
 * Retrieve the stops icon path
 */
- (NSString *)getIconPath
{
    // look for icon named like [view]-icon-image
    NSString *icon = [NSString stringWithFormat:@"icon-%@", self.view];
    NSString *path = [[NSBundle mainBundle] pathForResource:icon ofType:@"png"];
    
    // default case
    if (path == nil) {
        return [[NSBundle mainBundle] pathForResource:@"icon-webpage" ofType:@"png"];
    }
    return path;
}

/**
 * Convenience method for retrieving all assets for a stop
 */
- (NSArray *)getAssets
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (TAPAssetRef *assetRef in [self.assetRef allObjects]) {
        [assets addObject:assetRef.asset];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [assets sortedArrayUsingDescriptors:sortDescriptors];
}

/**
 * Convenience method for retrieving all assets with a particular usage
 */
- (NSArray *)getAssetsByUsage:(NSString *)usage
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (TAPAssetRef *assetRef in [self.assetRef allObjects]) {
        if ([assetRef.usage isEqualToString:usage]) {
            [assets addObject:assetRef.asset];
        }
    }
    
    NSMutableArray *sortedAssets = [[NSMutableArray alloc] init];
    NSSortDescriptor *parseSort = [[NSSortDescriptor alloc] initWithKey:@"parseIndex" ascending:YES];
    for (TAPAsset *asset in [assets sortedArrayUsingDescriptors:@[parseSort]]) {
        [sortedAssets addObject:asset];
    }
    
    return sortedAssets;
}

/**
 * Convenience method for retrieving all assets with a particular usage
 */
- (NSArray *)getAssetsByUsageOrderByParseIndex:(NSString *)usage
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (TAPAssetRef *assetRef in [self.assetRef allObjects]) {
        if ([assetRef.usage isEqualToString:usage]) {
            [assets addObject:assetRef.asset];
        }
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"parseIndex" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [assets sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSString *)getPropertyValueByName:(NSString *)name
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ AND value != nil AND (language == %@ OR language == nil)", name, appDelegate.language];
    TAPProperty *property = [[self.propertySet filteredSetUsingPredicate:predicate] anyObject];
    return property.value;
}

- (NSArray *)getSourceConnectionsByPriority
{
    NSArray *sourceConnecitons = [self.sourceConnection allObjects];
    
    return sourceConnecitons;
}

- (NSComparisonResult)compareByKeycode:(TAPStop *)otherObject
{
    TAPStop *stop = (TAPStop *)self;
    int code = [[stop getPropertyValueByName:@"code"] intValue];
    int otherCode = [[otherObject getPropertyValueByName:@"code"] intValue];
    
    if (code > otherCode) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if (code < otherCode) {
        return (NSComparisonResult)NSOrderedAscending;
    } else {
        return (NSComparisonResult)NSOrderedSame;
    }
}

- (NSComparisonResult)compareByTitle:(TAPStop *)otherObject
{
    TAPStop *stop = (TAPStop *)self;
    int code = [[stop getPropertyValueByName:@"code"] intValue];
    int otherCode = [[otherObject getPropertyValueByName:@"code"] intValue];
    
    if (code > otherCode) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if (code < otherCode) {
        return (NSComparisonResult)NSOrderedAscending;
    } else {
        return (NSComparisonResult)NSOrderedSame;
    }
}

- (NSComparisonResult)compareByDate:(TAPStop *)otherObject
{
    TAPStop *stop = (TAPStop *)self;
    
    NSDate *startDate1 = [self convertStringToDate:[stop getPropertyValueByName:@"date_start_0"]];
    NSDate *startDate2 = [self convertStringToDate:[otherObject getPropertyValueByName:@"date_start_0"]];
    
    if ([startDate1 compare:startDate2] == NSOrderedDescending) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if ([startDate1 compare:startDate2] == NSOrderedAscending) {
        return (NSComparisonResult)NSOrderedAscending;
    } else {
        return (NSComparisonResult)NSOrderedSame;
    }
}

/**
 * Converts a given date string of yyyy-MM-dd'T'HH:mm:ss and converts
 * it to a NSDate.
 */
- (NSDate *)convertStringToDate:(NSString *)dateString
{
    if (dateString == nil) return nil;
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *date = [formatter dateFromString:dateString];
    formatter = nil;
    return date;
}

@end
