//
//  ixeJSONParser.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/10.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class ixeProperty;
@class ixeBaseAction;
@class ixeBaseControl;
@class ixeViewController;
@class ixeActionContainer;
@class ixePropertyContainer;

@interface ixeJSONParser : NSObject

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue;
+(ixeProperty*)conditionalPropertyForConditionalValue:(id)conditionalValue;

+(ixePropertyContainer*)propertyContainerWithPropertyDictionary:(NSDictionary*)propertDictionary;
+(NSArray*)propertiesWithPropertyName:(NSString*)propertyName propertyValueArray:(NSArray*)propertyValueArray;
+(ixeProperty*)propertyWithPropertyName:(NSString*)propertyName propertyValueDict:(NSDictionary*)propertyValueDict;

+(ixeActionContainer*)actionContainerWithJSONActionsArray:(NSArray*)actionsArray;
+(ixeBaseAction*)actionWithValueDictionary:(NSDictionary*)actionValueDict;

+(NSArray*)controlsWithJSONControlArray:(NSArray*)controlsValueArray;
+(ixeBaseControl*)controlWithValueDictionary:(NSDictionary*)controlValueDict;

+(ixeViewController*)viewControllerWithViewDictionary:(NSDictionary*)viewDictionary;

@end
