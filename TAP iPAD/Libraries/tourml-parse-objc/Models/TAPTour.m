//
//  TAPTour.m
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "TAPTour.h"
#import "TAPAssetRef.h"
#import "TAPProperty.h"
#import "TAPStop.h"
#import "AppDelegate.h"

@implementation TAPTour

@dynamic author;
@dynamic id;
@dynamic tourRefUrl;
@dynamic bundlePath;
@dynamic lastModified;
@dynamic publishDate;
@dynamic title;
@dynamic desc;
@dynamic appResource;
@dynamic propertySet;
@dynamic rootStopRef;
@dynamic stop;

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

- (NSSet *)stopsFromArtworkId:(NSString *)artworkId
{
    // surely there is a better way to do this
    NSMutableArray *stopsContainingAssetsWithId = [[NSMutableArray alloc] init];
    for (TAPStop *stop in self.stop) {
        NSArray *filteredAssets = [[stop getAssetsByUsage:@"artwork"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id = %@", artworkId]];
        if ([filteredAssets count] > 0) {
            [stopsContainingAssetsWithId addObject:stop];
        }
    }
    return [[NSSet alloc] initWithArray:stopsContainingAssetsWithId];
}

- (NSSet *)stopsFromView:(NSString *)view
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"view = %@", view];
    NSSet *result = [self.stop filteredSetUsingPredicate:predicate];
    return result;
}

/**
 * Retrieves the stop for a given keycode
 */
- (TAPStop *)stopFromKeycode:(NSString *)keycode
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(propertySet, $ps, $ps.name = 'code' AND $ps.value = %@ AND ($ps.language == %@ OR $ps.language == nil)).@count > 0", 
                              keycode, appDelegate.language];
    TAPStop *stop = [[self.stop filteredSetUsingPredicate:predicate] anyObject];
    return stop;
}

/**
 * Retrieves the stop for a given id
 */
- (TAPStop *)stopFromId:(NSString *)id
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", id];
    TAPStop *stop = [[self.stop filteredSetUsingPredicate:predicate] anyObject];
    return stop;
}

/**
 * Convenience method for retrieving all assets with a particular usage
 */
- (NSArray *)getAppResourcesByUsage:(NSString *)usage
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (TAPAssetRef *assetRef in [self.appResource allObjects]) {
        if ([assetRef.usage isEqualToString:usage]) {
            [assets addObject:assetRef.asset];
        }
    }

    return assets;
}

/**
 * Convenience method for retrieving all resources with a particular usage by parseIndex
 */
- (NSArray *)getAppResourcesByUsageOrderByParseIndex:(NSString *)usage
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (TAPAssetRef *assetRef in [self.appResource allObjects]) {
        if ([assetRef.usage isEqualToString:usage]) {
            [assets addObject:assetRef.asset];
        }
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"parseIndex" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [assets sortedArrayUsingDescriptors:sortDescriptors];
}

/**
 * Override the getter so that we can get the proper path (storing full path in db was breaking in simulator)
 */
- (NSString *)bundlePath
{
    [self willAccessValueForKey:@"bundlePath"];
    NSString *dbValue = [self primitiveValueForKey:@"bundlePath"];
    [self didAccessValueForKey:@"bundlePath"];
    
    NSString *bundleDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Bundles"];
    NSString *tourBundlePath = [bundleDir stringByAppendingPathComponent:dbValue];
    
    return tourBundlePath;
}

@end
