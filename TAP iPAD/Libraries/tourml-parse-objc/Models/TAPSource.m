//
//  TAPSource.m
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "TAPSource.h"
#import "TAPAsset.h"
#import "TAPProperty.h"
#import "TAPTour.h"
#import "AppDelegate.h"

@implementation TAPSource

@dynamic format;
@dynamic language;
@dynamic lastModified;
@dynamic part;
@dynamic uri;
@dynamic originalUri;
@dynamic propertySet;
@dynamic relationship;

- (NSString *)propertyByName:(NSString *)name
{
    NSArray *filteredProperties = [[self.propertySet filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]] allObjects];
    TAPProperty *targetProperty = [filteredProperties objectAtIndex:0];
    return targetProperty.value;
}

- (NSString *)originalUri
{
    [self willAccessValueForKey:@"uri"];
    NSString *originalUri = [self primitiveValueForKey:@"uri"];
    [self didAccessValueForKey:@"uri"];
    return originalUri;
}

- (NSString *)uri 
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error = nil;

    [self willAccessValueForKey:@"uri"];
    NSString *originalUri = [self primitiveValueForKey:@"uri"];
    [self didAccessValueForKey:@"uri"];
    
    NSURL *url = [NSURL URLWithString:originalUri];
    NSString *localPath = nil;
    
    // check if the asset is located remotely
    if ([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"]) {
        // setup request
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        // setup connection and make request for file
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if (data != nil){
            // generate path for tour
            NSString *assetsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", appDelegate.currentTour.id]];
            // get the local path
            localPath = [assetsDirectory stringByAppendingPathComponent:[originalUri lastPathComponent]];
            // write file to local path
            [data writeToFile:localPath atomically:YES];
            // update the model to include the new uri path
            [self setUri:localPath];
        }
    } else { // check if file exists locally
        if ([[NSFileManager defaultManager] fileExistsAtPath:originalUri]) {
            localPath = originalUri;
        } else {
            if (appDelegate.currentTour.bundlePath != nil) {
                NSBundle *bundle = [NSBundle bundleWithPath:appDelegate.currentTour.bundlePath];
                NSString *bundleUri = [bundle pathForResource:[[originalUri lastPathComponent] stringByDeletingPathExtension]
                                                       ofType:[[originalUri lastPathComponent] pathExtension]
                                                  inDirectory:[originalUri stringByDeletingLastPathComponent]];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:bundleUri]) {
                    localPath = bundleUri;
                }
            }
        }
    }
    
    return localPath;
}

@end
