//
//  AppDelegate.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "AppDelegate.h"
#import "KioskApplication.h"
#import "TAPBaseViewController.h"
#import "TAPWebViewContainerViewController.h"
#import "TAPHomeViewController.h"
#import "TAPInterviewsStopViewController.h"
#import "TAPMenuViewController.h"
#import "TAPTimelineViewController.h"
#import "TAPGridViewController.h"

// vendor
#import "GAI.h"
#import "GAIFields.h"
#import "TAPTour.h"
#import "TourMLParser.h"
#import "VSThemeLoader.h"
#import "VSTheme.h"


@interface AppDelegate ()
@property (nonatomic, strong) VSThemeLoader *themeLoader;
@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //Don't let screen go to sleep
    application.idleTimerDisabled = YES;
    
    // set the application defaults
    // Here we're getting the device identifier, which is SET BY
    // THE USER in the app settings on the device. This is used to
    // identify particular devices when they show up in analytics
    // data.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"" forKey:@"analytics_identifier"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    
    // db5 theme setup
    self.themeLoader = [VSThemeLoader new];
    self.theme = self.themeLoader.defaultTheme;
    
    // add timeout observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:kApplicationDidTimeoutNotification object:nil];
    
    // get tap configurations
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"TapConfig" ofType:@"plist"];
    self.tapConfig = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // set default language
    [self setLanguage: [[NSLocale preferredLanguages] objectAtIndex:0]];
    
    // load tour data
    [TourMLParser loadTours];
    
    // setup fetch request for tour entity
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tour" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // retrieve tours
    NSError *error;
    NSArray *tours = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([tours count] == 0) {
        return NO;
    }
    
    [self setCurrentTour:[tours objectAtIndex:0]];

    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    //For debugging
    // [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    // Create tracker instance.
    // [[GAI sharedInstance] trackerWithTrackingId:[self.tapConfig objectForKey:@"GATrackerId"]];
    
    // first pull in the navigation items from config file
    TAPHomeViewController *homeViewController = [[TAPHomeViewController alloc] init];
    NSArray *navigationItems = [self.tapConfig objectForKey:@"NavigationItems"];
    NSMutableArray *navigationItemsViewControllers = [[NSMutableArray alloc] init];
    
    // then initialize view controllers using those
    [navigationItemsViewControllers addObject:homeViewController];
    for (NSDictionary *navigationItem in navigationItems) {
        [navigationItemsViewControllers addObject:[[UINavigationController alloc] initWithRootViewController:[(TAPBaseViewController *)[NSClassFromString([navigationItem objectForKey:@"view"]) alloc] initWithConfigDictionary:navigationItem]]];
    }
    
    // setup menu view container
    TAPMenuViewController *menuViewController = [[TAPMenuViewController alloc] init];
    
    // set view controllers
    [menuViewController setViewControllers:navigationItemsViewControllers];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:menuViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tap" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tap.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Notification handler

-(void)applicationDidTimeout:(NSNotification *)notification
{
//    [self setTimelineScrollPosition:0];
//    
//    TAPMenuViewController *viewController = (TAPMenuViewController *)self.window.rootViewController;
//    [viewController resetViewController];
    
}

#pragma mark - Exception handling

-(void)startSession
{
    [super startSession];
    
    TAPTour *tour = self.currentTour;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    NSString *dimensionValue = (NSString *)tour.title;
    [tracker set:[GAIFields customDimensionForIndex:1] value:dimensionValue];
    
    // add analytics identifier as a custom dimension
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *analyticsIdentifier = [defaults stringForKey:@"analytics_identifier"];
    [tracker set:[GAIFields customDimensionForIndex:2] value:analyticsIdentifier];
    
}

@end
