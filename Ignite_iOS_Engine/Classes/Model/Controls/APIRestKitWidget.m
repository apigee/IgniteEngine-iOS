//
//  APIImageWidget.m
//  ApigeeModules
//
//  Created by Jeremy Anticouni on 11/14/13.
//  Copyright (c) 2013 Apigee Inc. All rights reserved.
//

/*
 
 WIDGET
 
 - TYPE : "Spinner"
 
 - PROPERTIES
 
 * name="style"                     default="white"               type="String"
  
 */

#import "APIRestKitWidget.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>


@interface APIRestKitWidget ()


@end

@implementation APIRestKitWidget

-(void)buildView
{
    [super buildView];
}

//-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
//{
////    return CGSizeMake(_Spinner.frame.size.width, _Spinner.frame.size.height);
//}

-(void)applySettings
{
    
   

    // Initialize RestKit
    NSURL *baseURL = [NSURL URLWithString:@"https://api.usergrid.com"];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    
    // HACK: Set User-Agent to Mac OS X so that Twitter will let us access the Timeline
    [objectManager.HTTPClient setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]]];
    
    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    // Setup our object mappings
    /**
     Mapping by entity. Here we are configuring a mapping by targetting a Core Data entity with a specific
     name. This allows us to map back Twitter user objects directly onto NSManagedObject instances --
     there is no backing model class!
     */
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    userMapping.identificationAttributes = @[ @"userID" ];
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"id": @"userID",
                                                      @"screen_name": @"screenName",
                                                      }];
    // If source and destination key path are the same, we can simply add a string to the array
    [userMapping addAttributeMappingsFromArray:@[ @"name" ]];
    
    RKEntityMapping *tweetMapping = [RKEntityMapping mappingForEntityForName:@"Tweet" inManagedObjectStore:managedObjectStore];
    tweetMapping.identificationAttributes = @[ @"statusID" ];
    [tweetMapping addAttributeMappingsFromDictionary:@{
                                                       @"id": @"statusID",
                                                       @"created_at": @"createdAt",
                                                       @"text": @"text",
                                                       @"url": @"urlString",
                                                       @"in_reply_to_screen_name": @"inReplyToScreenName",
                                                       @"favorited": @"isFavorited",
                                                       }];
    [tweetMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userMapping]];
    
    // Update date format so that we can parse Twitter dates properly
    // Wed Sep 29 15:31:08 +0000 2010
    [RKObjectMapping addDefaultDateFormatterForString:@"E MMM d HH:mm:ss Z y" inTimeZone:nil];
    
    // Register our mappings with the provider
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tweetMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"/guidesmob/spartanapp/menu_items"
                                                                                           keyPath:nil
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    
    
    // HACK: Set User-Agent to Mac OS X so that Twitter will let us access the Timeline
//    [objectManager.HTTPClient setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]]];
//    
//    
    
//    [[self contentView] addSubview:_Spinner];
}

#ifdef RESTKIT_GENERATE_SEED_DB
RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);
RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);

NSError *error = nil;
BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
if (! success) {
    RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
}
NSString *seedStorePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"RKSeedDatabase.sqlite"];
RKManagedObjectImporter *importer = [[RKManagedObjectImporter alloc] initWithManagedObjectModel:managedObjectModel storePath:seedStorePath];
[importer importObjectsFromItemAtPath:[[NSBundle mainBundle] pathForResource:@"restkit" ofType:@"json"]
                          withMapping:tweetMapping
                              keyPath:nil
                                error:&error];
[importer importObjectsFromItemAtPath:[[NSBundle mainBundle] pathForResource:@"users" ofType:@"json"]
                          withMapping:userMapping
                              keyPath:@"user"
                                error:&error];
BOOL success = [importer finishImporting:&error];
if (success) {
    [importer logSeedingInfo];
} else {
    RKLogError(@"Failed to finish import and save seed database due to error: %@", error);
}

// Clear out the root view controller
[self.window setRootViewController:[UIViewController new]];
#else
/**
 Complete Core Data stack initialization
 */
[managedObjectStore createPersistentStoreCoordinator];
NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"RKTwitter.sqlite"];
NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
NSError *error;
NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:seedPath withConfiguration:nil options:nil error:&error];
NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);

// Create the managed object contexts
[managedObjectStore createManagedObjectContexts];

// Configure a managed object cache to ensure we do not create duplicate objects
managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
#endif

return YES;
}



@end
