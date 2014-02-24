//
//  IXBaseControlConfig.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/21/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXBaseControl;
@class IXActionContainer;
@class IXPropertyContainer;

@interface IXBaseControlConfig : NSObject

@property (nonatomic,assign) Class controlClass;
@property (nonatomic,strong) NSArray* childControlConfigs;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXPropertyContainer* propertyContainer;

-(instancetype)initWithControlClass:(Class)controlClass propertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer andChildControlConfigs:(NSArray*)childControlConfigs;
+(instancetype)baseControlConfigWithControlClass:(Class)controlClass propertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer andChildControlConfigs:(NSArray*)childControlConfigs;

-(IXBaseControl*)createControl;

@end
