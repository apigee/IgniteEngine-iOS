//
//  IxBaseDataprovider.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxBaseDataprovider.h"

#import "IxPropertyContainer.h"
#import "IxTableView.h"
#import "IxEntityContainer.h"

#import <RestKit/RestKit.h>

@interface IxBaseDataprovider () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) RKObjectManager* objectManager;
@property (nonatomic,assign) BOOL sortAscending;

@property (nonatomic,copy) NSString* dataLocation;

@property (nonatomic,copy) NSString* sortDescriptorKey;
@property (nonatomic,copy) NSString* keyPath;
@property (nonatomic,copy) NSString* pathPattern;
@property (nonatomic,copy) NSString* objectsPath;
@property (nonatomic,strong) RKEntityMapping* entityMapping;

@property (nonatomic,copy) NSString* fetchFromEntity;

@end

@implementation IxBaseDataprovider

+(void)initialize
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

-(void)dealloc
{
    [_fetchedResultsController setDelegate:nil];
}

-(id)init
{
    self = [super init];
    if( self )
    {
        _requestParameterProperties = [[IxPropertyContainer alloc] init];
        _requestHeaderProperties = [[IxPropertyContainer alloc] init];
        _fileAttachmentProperties = [[IxPropertyContainer alloc] init];
    }
    return self;
}

-(void)setSandbox:(IxSandbox *)sandbox
{
    [super setSandbox:sandbox];
    
    [_requestHeaderProperties setSandbox:sandbox];
    [_requestParameterProperties setSandbox:sandbox];
    [_fileAttachmentProperties setSandbox:sandbox];
    [[_entityContainer entityProperties] setSandbox:sandbox];
}

-(void)applySettings
{
    [super applySettings];
    
    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:@"auto_load" defaultValue:YES]];
    [self setFetchFromEntity:[[self propertyContainer] getStringPropertyValue:@"fetch_from_entity_name" defaultValue:nil]];
    
    NSString* dataLocation = [[self propertyContainer] getStringPropertyValue:@"data_location" defaultValue:nil];
    NSString* pathPattern = [[self propertyContainer] getStringPropertyValue:@"path_pattern" defaultValue:nil];
    NSString* objectsPath = [[self propertyContainer] getStringPropertyValue:@"objects_path" defaultValue:nil];
    NSString* sortDescriptorKey = [[self propertyContainer] getStringPropertyValue:@"sort_descriptor_key" defaultValue:nil];
    BOOL sortAscending = [[self propertyContainer] getBoolPropertyValue:@"sort_ascending" defaultValue:YES];

    BOOL needsToRecreateEverything = NO;
    if( ![[self dataLocation] isEqualToString:dataLocation] )
    {
        needsToRecreateEverything = YES;
        [self setDataLocation:dataLocation];
    }
    if( ![[self pathPattern] isEqualToString:pathPattern] )
    {
        needsToRecreateEverything = YES;
        [self setPathPattern:pathPattern];
    }
    if( ![[self objectsPath] isEqualToString:objectsPath] )
    {
        needsToRecreateEverything = YES;
        [self setObjectsPath:objectsPath];
    }
    
    if( needsToRecreateEverything )
    {
        [self createObjectManager];
        
        if( [self objectManager] != nil )
        {
            [self configureObjectMapping];
            [self configureDatabaseStorage];
        }
    }
    
    BOOL needsToRecreateFetchResultsController = needsToRecreateEverything;
    if( ![[self sortDescriptorKey] isEqualToString:sortDescriptorKey] )
    {
        needsToRecreateFetchResultsController = YES;
        [self setSortDescriptorKey:sortDescriptorKey];
    }
    if( [self sortAscending] == sortAscending )
    {
        needsToRecreateFetchResultsController = YES;
        [self setSortAscending:sortAscending];
    }
    
    if( needsToRecreateFetchResultsController )
    {
        [self configureFetchedResultsController];
    }
}

-(void)createObjectManager
{
    [self setObjectManager:[RKObjectManager managerWithBaseURL:[NSURL URLWithString:[self dataLocation]]]];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    [[self objectManager] setManagedObjectStore:managedObjectStore];
}

-(NSEntityDescription*)createEntityFromIxEntityContainer:(IxEntityContainer*)entityContainer addToMapping:(RKEntityMapping*)entityMapping
{
    NSEntityDescription* entity = nil;
    @try
    {
        RKManagedObjectStore *managedObjectStore = [[self objectManager] managedObjectStore];
        NSManagedObjectModel *managedObjectModel = [managedObjectStore managedObjectModel];
        
        entity = [[[managedObjectModel entitiesByName] objectForKey:kIx_DUMMY_DATA_MODEL_ENTITY_NAME] copy];
        [entity setName:[[entityContainer entityProperties] getStringPropertyValue:@"entity_name" defaultValue:nil]];
        
        NSString* entityAttributesString = [[entityContainer entityProperties] getStringPropertyValue:@"entity_attributes" defaultValue:nil];
        NSArray* entityAttributesCommaSeperatedArray = [entityAttributesString componentsSeparatedByString:@","];
        NSString* entityIdentificationAttributesString = [[entityContainer entityProperties] getStringPropertyValue:@"entity_identification_attributes" defaultValue:nil];
        NSArray* entityIdentificationAttributesCommaSeperatedArray = [entityIdentificationAttributesString componentsSeparatedByString:@","];
        
        NSMutableArray* entityProperties = [[NSMutableArray alloc] initWithCapacity:[entityAttributesCommaSeperatedArray count]];
        for( NSString* attributeName in entityAttributesCommaSeperatedArray )
        {
            NSAttributeDescription *attributeDescription = [[NSAttributeDescription alloc] init];
            [attributeDescription setName:attributeName];
            [attributeDescription setAttributeType:NSStringAttributeType];
            [attributeDescription setOptional:YES];
            [entityProperties addObject:attributeDescription];
        }
        [entity setProperties:entityProperties];

        RKEntityMapping *mapping = [[RKEntityMapping alloc] initWithEntity:entity];
        [mapping setIdentificationAttributes:entityIdentificationAttributesCommaSeperatedArray];
        [mapping addAttributeMappingsFromArray:entityAttributesCommaSeperatedArray];
        
        // If entityMapping is nil then this is the first entity
        if( entityMapping == nil )
        {
            entityMapping = mapping;
            _entityMapping = mapping;
        }
        else
        {
            [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:[entity name]
                                                                                          toKeyPath:[entity name]
                                                                                        withMapping:mapping]];
        }
        
        for( IxEntityContainer* subEntityContainer in [entityContainer subEntities] )
        {
            NSEntityDescription* subEntity = [self createEntityFromIxEntityContainer:subEntityContainer addToMapping:mapping];
            if( subEntity != nil )
            {
                NSInteger parentMinCount = 0;
                NSInteger parentMaxCount = 0;
                NSInteger childMinCount = 0;
                NSInteger childMaxCount = 1;
                
                NSArray* parentToChildRelationshipCounts = [[subEntityContainer entityProperties] getCommaSeperatedArrayListValue:@"parent_relationship_count" defaultValue:nil];
                NSArray* childToParentRelationshipCounts = [[entityContainer entityProperties] getCommaSeperatedArrayListValue:@"child_relationship_count" defaultValue:nil];
                
                if( [parentToChildRelationshipCounts count] == 2 )
                {
                    parentMinCount = [[parentToChildRelationshipCounts firstObject] integerValue];
                    parentMaxCount = [[parentToChildRelationshipCounts lastObject] integerValue];
                }
                if( [childToParentRelationshipCounts count] == 2 )
                {
                    childMinCount = [[childToParentRelationshipCounts firstObject] integerValue];
                    childMaxCount = [[childToParentRelationshipCounts lastObject] integerValue];
                }
                
                NSRelationshipDescription* relationshipDescription = [[NSRelationshipDescription alloc] init];
                [relationshipDescription setOptional:YES];
                [relationshipDescription setName:[entity name]];
                [relationshipDescription setMinCount:parentMinCount];
                [relationshipDescription setMaxCount:parentMaxCount];
                [relationshipDescription setDestinationEntity:entity];
                
                NSRelationshipDescription* subRelationshipDescription = [[NSRelationshipDescription alloc] init];
                [subRelationshipDescription setOptional:YES];
                [subRelationshipDescription setName:[subEntity name]];
                [subRelationshipDescription setMinCount:childMinCount];
                [subRelationshipDescription setMaxCount:childMaxCount];
                [subRelationshipDescription setDestinationEntity:subEntity];
                
                [relationshipDescription setInverseRelationship:subRelationshipDescription];
                [subRelationshipDescription setInverseRelationship:relationshipDescription];
            
                [entity setProperties:[[entity properties] arrayByAddingObject:subRelationshipDescription]];
                [subEntity setProperties:[[subEntity properties] arrayByAddingObject:relationshipDescription]];
            }
        }
        
        [managedObjectModel setEntities:[[managedObjectModel entities] arrayByAddingObject:entity]];
    }
    @catch (NSException * e)
    {
        NSLog(@"WARNING : DataProvider Exception: %@", e);
        entity = nil;
    }
    return entity;
}

-(void)configureObjectMapping
{
    @try
    {
        [self createEntityFromIxEntityContainer:[self entityContainer] addToMapping:nil];
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_entityMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:[self pathPattern]
                                                                                               keyPath:[self keyPath]
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        [[self objectManager] addResponseDescriptor:responseDescriptor];
        [[[self objectManager] managedObjectStore] createPersistentStoreCoordinator];
    }
    @catch (NSException * e)
    {
        NSLog(@"WARNING : DataProvider Exception: %@", e);
    }
}

-(void)configureDatabaseStorage
{
    @try
    {
        RKManagedObjectStore *managedObjectStore = [[self objectManager] managedObjectStore];
        NSString *storePathName = [NSString stringWithFormat:@"%@.sqlite",[self ID]];
        NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:storePathName];
        
        NSError *error;
        NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    
        if ( persistentStore == nil || error != nil )
        {
            // If there was an error in creating the persistant store reset them and try to recover.
            BOOL didSucceed = NO;
            @try {
                didSucceed = [managedObjectStore resetPersistentStores:&error];
                if( didSucceed )
                {
                    persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
                    didSucceed = (persistentStore == nil || error != nil);
                }
            } @catch (NSException *e) {
                
            } @finally {
                if( !didSucceed )
                {
                    //TODO: might need to remove this.
                    [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
                    persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
                }
            }
        }
    
        // Create the managed object contexts
        [managedObjectStore createManagedObjectContexts];
    
        // Configure a managed object cache to ensure we do not create duplicate objects
        [managedObjectStore setManagedObjectCache:[[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext]];
    }
    @catch (NSException * e)
    {
        NSLog(@"WARNING : DataProvider Exception: %@", e);
    }
}

-(void)configureFetchedResultsController
{
    @try
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self fetchFromEntity]];
        
        if( [self sortDescriptorKey] != nil && ![[self sortDescriptorKey] isEqualToString:@""] )
        {
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:[self sortDescriptorKey] ascending:[self sortAscending]];
            fetchRequest.sortDescriptors = @[descriptor];
        }
        
        [[self fetchedResultsController] setDelegate:nil];
        [self setFetchedResultsController:nil];
        
        [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                              managedObjectContext:[[self objectManager] managedObjectStore].persistentStoreManagedObjectContext
                                                                                sectionNameKeyPath:nil
                                                                                         cacheName:nil]];
        [[self fetchedResultsController] setDelegate:self];
    }
    @catch (NSException * e)
    {
        NSLog(@"WARNING : DataProvider Exception: %@", e);
    }
}

-(void)loadData
{
    @try
    {
        NSError* error = nil;
        BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
        if (! fetchSuccessful) {
            NSLog(@"WARNING: ERROR PERFORMING FETCH");
        }
        
        NSArray* fetchedObjects = [[self fetchedResultsController] fetchedObjects];
        if( fetchedObjects != nil && [fetchedObjects count] > 0 )
        {
            [[self controlListener] reloadTableView];
        }
        
        [[self objectManager] getObjectsAtPath:[self objectsPath]
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    NSLog(@"success");
                                    [self.fetchedResultsController performFetch:nil];
                                }
                                failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    NSLog(@"failed");
                                }];
    }
    @catch (NSException * e)
    {
        NSLog(@"WARNING : DataProvider Exception: %@", e);
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self controlListener] reloadTableView];
}


@end
