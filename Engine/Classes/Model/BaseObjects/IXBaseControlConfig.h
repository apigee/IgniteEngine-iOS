//
//  IXBaseControlConfig.h
//  Ignite Engine
//
//  Created by Robert Walsh on 2/21/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXBaseControl;
@class IXActionContainer;
@class IXAttributeContainer;

@interface IXBaseControlConfig : NSObject <NSCopying>

@property (nonatomic,assign) Class controlClass;
@property (nonatomic,copy)   NSString* styleClass;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXAttributeContainer* propertyContainer;
@property (nonatomic,strong) NSDictionary* controlConfigDictionary;

-(instancetype)initWithControlClass:(Class)controlClass
                         styleClass:(NSString*)styleClass
                  propertyContainer:(IXAttributeContainer*)propertyContainer
                    actionContainer:(IXActionContainer*)actionContainer
            controlConfigDictionary:(NSDictionary*)controlConfigDictionary;

+(instancetype)controlConfigWithJSONDictionary:(NSDictionary*)controlJSONDict;
+(NSArray*)controlConfigsWithJSONControlArray:(NSArray*)controlsValueArray;

-(IXBaseControl*)createControl;

@end
