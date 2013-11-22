//
//  APIGetShortCode.m
//  Apigee_iOS_Engine
//
//  Created by Robert Walsh on 11/21/13.
//  Copyright (c) 2013 Apigee Inc. All rights reserved.
//

#import "APIGetShortCode.h"

#import "APIBaseObject.h"
#import "APIProperty.h"
#import "APIPropertyContainer.h"
#import "APISandbox.h"
#import "APIAppManager.h"

@implementation APIGetShortCode

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    NSString* propertyName = [[[self parameters] firstObject] getPropertyValue];
    if( [[self objectID] isEqualToString:@"app"] )
    {
        returnValue = [[[APIAppManager sharedInstance] appProperties] getStringPropertyValue:propertyName defaultValue:nil];
    }
    else if( [[self objectID] isEqualToString:@"session"] )
    {
        returnValue = [[[APIAppManager sharedInstance] sessionProperties] getStringPropertyValue:propertyName defaultValue:nil];
    }
    else if( [[self objectID] isEqualToString:@"form"] )
    {
        returnValue = nil;
    }
    else
    {
        APISandbox* sandbox = [[[self property] propertyContainer] sandbox];
        NSArray* objectWithIDArray = [sandbox getAllWidgetAndDataProvidersWithID:[self objectID]];
        APIBaseObject* baseObject = [objectWithIDArray firstObject];
        if( baseObject != nil )
        {
            returnValue = [[baseObject propertyContainer] getStringPropertyValue:propertyName defaultValue:nil];
        }
    }
    return returnValue;
}

@end
