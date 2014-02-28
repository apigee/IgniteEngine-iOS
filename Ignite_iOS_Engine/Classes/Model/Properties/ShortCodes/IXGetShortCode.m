//
//  IXGetShortCode.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 11/21/13.
//  Copyright (c) 2013 Apigee Inc. All rights reserved.
//

#import "IXGetShortCode.h"

#import "IXBaseObject.h"
#import "IXProperty.h"
#import "IXPropertyContainer.h"
#import "IXSandbox.h"
#import "IXViewController.h"
#import "IXAppManager.h"
#import "IXDeviceHardware.h"

// IXGetShortCode Read-Only Properties
static NSString* const kIXScreenWidth = @"screen.width";
static NSString* const kIXScreenHeight = @"screen.height";
static NSString* const kIXScaleFactor = @"screen.scale";
static NSString* const kIXModel = @"model"; //See IXDeviceHardware.m for complete list
static NSString* const kIXType = @"type";
static NSString* const kIXOSVersion = @"os.version";
static NSString* const kIXOSVersionInteger = @"os.version.integer";
static NSString* const kIXOSVersionMajor = @"os.version.major";
static NSString* const kIXOrientation = @"orientation";

@implementation IXGetShortCode

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    NSString* propertyName = [self methodName];
    if( !propertyName )
    {
        IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
        propertyName = [parameterProperty getPropertyValue];
    }
    
    if( [[self objectID] isEqualToString:@"device"] )
    {
        if ([propertyName isEqualToString:kIXScreenWidth])
            returnValue = [NSString stringWithFormat:@"%.0f", [[UIScreen mainScreen] bounds].size.width];
        else if ([propertyName isEqualToString:kIXScreenHeight])
            returnValue = [NSString stringWithFormat:@"%.0f", [[UIScreen mainScreen] bounds].size.height];
        else if ([propertyName isEqualToString:kIXScaleFactor])
            returnValue = [NSString stringWithFormat:@"%.1f", [[UIScreen mainScreen] scale]];
        else if ([propertyName isEqualToString:kIXModel])
        {
            IXDeviceHardware *hw = [[IXDeviceHardware alloc] init];
            returnValue = [hw modelString];
        }
        else if ([propertyName isEqualToString:kIXType])
        {
            //potential return values: iPod touch, iPhone, iPhone Simulator, iPad, iPad Simulator
            returnValue = [[UIDevice currentDevice] model];
        }
        else if ([propertyName isEqualToString:kIXOSVersion])
        {
            returnValue = [[UIDevice currentDevice] systemVersion];
        }
        else if ([propertyName isEqualToString:kIXOSVersionInteger])
        {
            NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"."];
            returnValue = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
        }
        else if ([propertyName isEqualToString:kIXOSVersionMajor])
        {
            returnValue = [[[UIDevice currentDevice] systemVersion] substringToIndex:1];
        }
        else if ([propertyName isEqualToString:kIXOrientation])
        {
            int type = [[UIApplication sharedApplication] statusBarOrientation];
            if (type == 1) {
                returnValue = @"Portrait";
            } else if (type == 2) {
                returnValue = @"Portrait-UpsideDown";
            } else if (type == 3) {
                returnValue = @"Landscape-Right";
            } else if (type == 4) {
                returnValue = @"Landscape-Left";
            } else
                returnValue = nil;
        }
        else
        {
            returnValue = nil;
        }
        

        
    }
    else if( [[self objectID] isEqualToString:@"app"] )
    {
        returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringPropertyValue:propertyName defaultValue:nil];
    }
    else if( [[self objectID] isEqualToString:@"session"] )
    {
        returnValue = [[[IXAppManager sharedAppManager] sessionProperties] getStringPropertyValue:propertyName defaultValue:nil];
    }
    else if( [[self objectID] isEqualToString:@"form"] )
    {
        returnValue = nil;
    }
    else if( [[self objectID] isEqualToString:@"view"] )
    {
        IXSandbox* sandbox = [[[[self property] propertyContainer] ownerObject] sandbox];
        IXViewController* viewController = [sandbox viewController];
        returnValue = [[viewController propertyContainer] getStringPropertyValue:propertyName defaultValue:nil];
    }
    else
    {
        IXBaseObject* baseObject = [[[self property] propertyContainer] ownerObject];
        NSArray* objectWithIDArray = [[baseObject sandbox] getAllControlAndDataProvidersWithID:[self objectID] withSelfObject:baseObject];
        baseObject = [objectWithIDArray firstObject];
        
        if( baseObject )
        {
            returnValue = [baseObject getReadOnlyPropertyValue:propertyName];
            if( returnValue == nil )
            {
                returnValue = [[baseObject propertyContainer] getStringPropertyValue:propertyName defaultValue:nil];
            }
        }
    }
    return returnValue;
}

@end
