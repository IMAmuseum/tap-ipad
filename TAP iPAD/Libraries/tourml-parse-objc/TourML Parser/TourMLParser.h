//
//  TourMLParser.h
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
@class TAPTour;

@interface TourMLParser : NSObject

+ (void)loadTours;
+ (void)loadTours:(NSArray *)additionalEndpoints;

@end

@interface TourMLParser ()

+ (TAPTour *)getExternalTourMLDoc:(NSString *)tourMLRef;
+ (TAPTour *)parseTourMLDoc:(GDataXMLDocument *)doc fromUrl:(NSURL *)tourRefUrl;
+ (NSSet *)processStops:(GDataXMLElement *)element fromRoot:(GDataXMLElement *)root withContext:(NSManagedObjectContext *)context;
+ (NSSet *)processAssets:(NSArray *)elements fromRoot:(GDataXMLElement *)root withContext:(NSManagedObjectContext *)context;
+ (NSDictionary *)processTitle:(NSArray *)elements withContext:(NSManagedObjectContext *)context;
+ (NSDictionary *)processDescription:(NSArray *)elements withContext:(NSManagedObjectContext *)context;
+ (NSSet *)processPropertySet:(GDataXMLElement *)element withContext:(NSManagedObjectContext *)context;
+ (NSDate *)convertStringToDate:(NSString *)dateString;

@end
