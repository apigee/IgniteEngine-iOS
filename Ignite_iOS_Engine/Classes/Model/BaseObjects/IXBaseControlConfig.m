//
//  IXBaseControlConfig.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/21/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseControlConfig.h"

#import "IXBaseControl.h"
#import "IXActionContainer.h"
#import "IXPropertyContainer.h"

@implementation IXBaseControlConfig

-(instancetype)initWithControlClass:(Class)controlClass propertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer andChildControlConfigs:(NSArray*)childControlConfigs
{
    self = [super init];
    if( self )
    {
        _controlClass = controlClass;
        _propertyContainer = propertyContainer;
        _actionContainer = actionContainer;
        _childControlConfigs = childControlConfigs;
    }
    return self;
}

+(instancetype)baseControlConfigWithControlClass:(Class)controlClass propertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer andChildControlConfigs:(NSArray*)childControlConfigs
{
    return [[[self class] alloc] initWithControlClass:controlClass propertyContainer:propertyContainer actionContainer:actionContainer andChildControlConfigs:childControlConfigs];
}

-(IXBaseControl*)createControl
{
    IXBaseControl* control = [[[self controlClass] alloc] init];
    if( control )
    {
        [control setPropertyContainer:[[self propertyContainer] copy]];
        [control setActionContainer:[[self actionContainer] copy]];
        if( [self childControlConfigs] )
        {
            for( IXBaseControlConfig* childControlConfig in [self childControlConfigs] )
            {
                IXBaseControl* childControl = [childControlConfig createControl];
                if( childControl )
                {
                    [control addChildObject:childControl];
                }
            }
        }
    }
    return control;
}

@end
