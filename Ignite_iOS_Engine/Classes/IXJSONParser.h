//
//  IXJSONParser.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/10/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXProperty;
@class IXBaseAction;
@class IXBaseControl;
@class IXViewController;
@class IXActionContainer;
@class IXPropertyContainer;

@interface IXJSONParser : NSObject

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue;
+(IXProperty*)conditionalPropertyForConditionalValue:(id)conditionalValue;

+(IXPropertyContainer*)propertyContainerWithPropertyDictionary:(NSDictionary*)propertDictionary;
+(NSArray*)propertiesWithPropertyName:(NSString*)propertyName propertyValueArray:(NSArray*)propertyValueArray;
+(IXProperty*)propertyWithPropertyName:(NSString*)propertyName propertyValueDict:(NSDictionary*)propertyValueDict;

+(IXActionContainer*)actionContainerWithJSONActionsArray:(NSArray*)actionsArray;
+(IXBaseAction*)actionWithValueDictionary:(NSDictionary*)actionValueDict;

+(NSArray*)controlsWithJSONControlArray:(NSArray*)controlsValueArray;
+(IXBaseControl*)controlWithValueDictionary:(NSDictionary*)controlValueDict;

+(IXViewController*)viewControllerWithViewDictionary:(NSDictionary*)viewDictionary pathToJSON:(NSString*)pathToJSON;

@end
