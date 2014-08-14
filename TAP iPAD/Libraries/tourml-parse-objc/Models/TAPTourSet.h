//
//  TAPTourSet.h
//  launchpad-iphone
//
//  Created by David D'Amico on 2/12/14.
//  Copyright (c) 2014 IMALab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TAPTour;

@interface TAPTourSet : NSManagedObject

@property (nonatomic, retain) NSString * tourRefUrl;
@property (nonatomic, retain) NSSet *tours;
@end

@interface TAPTourSet (CoreDataGeneratedAccessors)

- (void)addToursObject:(TAPTour *)value;
- (void)removeToursObject:(TAPTour *)value;
- (void)addTours:(NSSet *)values;
- (void)removeTours:(NSSet *)values;

@end
