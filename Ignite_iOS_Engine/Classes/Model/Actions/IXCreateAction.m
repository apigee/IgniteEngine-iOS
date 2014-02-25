//
//  IXCreateAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/27/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXCreateAction.h"

#import "IXAppManager.h"

#import "IXJSONParser.h"
#import "IXJSONGrabber.h"

#import "IXPropertyContainer.h"

#import "IXBaseControl.h"

static NSCache* sIXCreateControlCache;
static NSString* const kIXCreateControlCacheName = @"com.ignite.CreateControlCache";

// IXCreateAction Properties
static NSString* const kIXControlLocation = @"control_location";
static NSString* const kIXParentID = @"parent_id";

// IXCreateAction Events
static NSString* const kIXSuccess = @"success";
static NSString* const kIXFailed = @"failed";

@implementation IXCreateAction

+(void)initialize
{
    @autoreleasepool {
        sIXCreateControlCache = [[NSCache alloc] init];
        [sIXCreateControlCache setName:kIXCreateControlCacheName];
    }
}

-(void)addCreatedControl:(IXBaseControl*)control withParentControlID:(NSString*)parentID
{
    IXBaseControl* parentControl = nil;
    IXSandbox* sandbox = [[[self actionContainer] ownerObject] sandbox];
    if( parentID )
    {
        parentControl = [[sandbox getAllControlsWithID:parentID] firstObject];
    }
    else
    {
        parentControl = [sandbox containerControl];
    }
    
    if( parentControl )
    {
        [parentControl addChildObject:control];
        [control applySettings];
        [parentControl layoutControl];
        
        [self actionDidFinishWithEvents:@[kIXSuccess]];
    }
    else
    {
        [self actionDidFinishWithEvents:@[kIXFailed]];
    }
}

-(IXBaseControl*)createdControlFromLocation:(NSString*)location
{
    __block IXBaseControl* createdControl = nil;
    
    if( location )
    {
        createdControl = [[sIXCreateControlCache objectForKey:location] copy];
        if( createdControl == nil )
        {
            [[IXJSONGrabber sharedJSONGrabber] grabJSONFromPath:location
                                                         asynch:NO
                                                completionBlock:^(id jsonObject, NSError *error) {
                                                    
                                                    if( jsonObject )
                                                    {
                                                        if( [jsonObject isKindOfClass:[NSDictionary class]] )
                                                        {
                                                            createdControl = [IXJSONParser controlWithValueDictionary:jsonObject];
                                                            if( createdControl )
                                                            {
                                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                    [sIXCreateControlCache setObject:[createdControl copy] forKey:location cost:0];
                                                                });
                                                            }
                                                        }
                                                    }
                                                }];
        }
    }
    
    return createdControl;
}

-(void)execute
{
    [super execute];
    
    NSString* controlJSONLocation = [[self actionProperties] getPathPropertyValue:kIXControlLocation basePath:nil defaultValue:nil];
    if( controlJSONLocation )
    {
        IXBaseControl* createdControl = [[sIXCreateControlCache objectForKey:controlJSONLocation] copy];
        if( createdControl == nil )
        {
            createdControl = [self createdControlFromLocation:controlJSONLocation];
        }
        
        if( createdControl )
        {
            NSString* parentControlID = [[self actionProperties] getStringPropertyValue:kIXParentID defaultValue:nil];
            [self addCreatedControl:createdControl withParentControlID:parentControlID];
        }
        else
        {
            [self actionDidFinishWithEvents:@[kIXFailed]];
        }
    }
}

@end
