//
//  IxJSONParser.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/10.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class IxProperty;
@class IxBaseAction;
@class IxBaseControl;
@class IxViewController;
@class IxActionContainer;
@class IxPropertyContainer;

@interface IxJSONParser : NSObject

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue;
+(IxProperty*)conditionalPropertyForConditionalValue:(id)conditionalValue;

+(IxPropertyContainer*)propertyContainerWithPropertyDictionary:(NSDictionary*)propertDictionary;
+(NSArray*)propertiesWithPropertyName:(NSString*)propertyName propertyValueArray:(NSArray*)propertyValueArray;
+(IxProperty*)propertyWithPropertyName:(NSString*)propertyName propertyValueDict:(NSDictionary*)propertyValueDict;

+(IxActionContainer*)actionContainerWithJSONActionsArray:(NSArray*)actionsArray;
+(IxBaseAction*)actionWithValueDictionary:(NSDictionary*)actionValueDict;

+(NSArray*)controlsWithJSONControlArray:(NSArray*)controlsValueArray;
+(IxBaseControl*)controlWithValueDictionary:(NSDictionary*)controlValueDict;

+(IxViewController*)viewControllerWithViewDictionary:(NSDictionary*)viewDictionary;

@end
