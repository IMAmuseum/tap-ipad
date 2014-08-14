//
//  AppDelegate.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KioskApplication.h"

@class TAPTour;
@class VSTheme;

@interface AppDelegate : KioskApplication <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSArray *tours;
@property (nonatomic, strong) NSArray *tourSets;

@property (nonatomic, strong) VSTheme *theme;
@property (nonatomic, strong) TAPTour *currentTour;
@property (nonatomic, strong) NSDictionary *tapConfig;
@property (nonatomic, strong) NSString *language;
@property CGFloat timelineScrollPosition;

@property BOOL loadingComplete;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
