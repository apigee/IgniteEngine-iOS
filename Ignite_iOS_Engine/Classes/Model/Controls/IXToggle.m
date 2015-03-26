//
//  IXImageControl.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/15/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXToggle.h"

#import "NSString+IXAdditions.h"

// IXToggle Functions
IX_STATIC_CONST_STRING kIXToggle = @"toggle";
IX_STATIC_CONST_STRING kIXToggleOn = @"toggleOn";
IX_STATIC_CONST_STRING kIXToggleOff = @"toggleOff";

// IXToggle Attributes
IX_STATIC_CONST_STRING kIDefaultOn = @"defaultOn.enabled"; //default: false

// IXToggle Returns
IX_STATIC_CONST_STRING kIIsOn = @"isOn";


@interface  IXToggle ()

@property (nonatomic,assign) BOOL hasAppliedSettings;
@property (nonatomic,strong) UISwitch *toggleSwitch;

@end

@implementation IXToggle


-(void)buildView
{
    [super buildView];
    
    _hasAppliedSettings = NO;
    
    _toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    
    [[self contentView] addSubview:_toggleSwitch];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeMake([self toggleSwitch].frame.size.width, [self toggleSwitch].frame.size.height);
}

-(void)applySettings
{
    [super applySettings];
    
    if( ![self hasAppliedSettings] )
    {
        [self setHasAppliedSettings:YES];
        [[self toggleSwitch] setOn:[[self propertyContainer] getBoolPropertyValue:kIDefaultOn defaultValue:NO] animated:NO];
    }
}

-(void)switchToggled:(UISwitch*)sender
{
    if( [[self toggleSwitch] isOn] )
    {
        [[self actionContainer] executeActionsForEventNamed:kIXToggle];
        [[self actionContainer] executeActionsForEventNamed:kIXToggleOn];
    }
    else
    {        
        [[self actionContainer] executeActionsForEventNamed:kIXToggle];
        [[self actionContainer] executeActionsForEventNamed:kIXToggleOff];
    }
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXToggle] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [[self toggleSwitch] setOn:![[self toggleSwitch] isOn] animated:animated];
        [[self actionContainer] executeActionsForEventNamed:kIXToggle];

    }
    else if( [functionName isEqualToString:kIXToggleOn] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [[self toggleSwitch] setOn:YES animated:animated];
        [[self actionContainer] executeActionsForEventNamed:kIXToggleOn];

    }
    else if( [functionName isEqualToString:kIXToggleOff] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [[self toggleSwitch] setOn:NO animated:animated];
        [[self actionContainer] executeActionsForEventNamed:kIXToggleOff];
        
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIIsOn] )
    {
        returnValue = [NSString ix_stringFromBOOL:[[self toggleSwitch] isOn]];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

@end
