//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     42034
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
 */

/**
 
 ###
 ###    Toggle switch to toggle on and to toggle off.
 ###
 ###    Looks like:
 
 <a href="../../images/IXToggle.png" data-imagelightbox="b"><img src="../../images/IXToggle.png" alt="" width="160" height="284"></a>
 
 ###    Here's how you use it:
 
 */

/*
 *      /Docs
 *
 */

#import "IXToggle.h"

#import "NSString+IXAdditions.h"

@interface  IXToggle ()

@property (nonatomic,assign) BOOL hasAppliedSettings;
@property (nonatomic,strong) UISwitch *toggleSwitch;

@end

@implementation IXToggle

/*
* Docs
*
*/

/***************************************************************/

/** Configuration Atributes

    @param initally_selected Should the toggle be selected by default? *(default: FALSE)*<br>*bool*

*/

-(void)config
{
}
/***************************************************************/
/***************************************************************/

/**  This control has the following read-only properties:

 @param is_on Is the toggle on?<br>*(bool)*

*/

-(void)readOnly
{
}

/***************************************************************/
/***************************************************************/

/**  This control has the following events:
*/

-(void)events
{
}

/***************************************************************/
/***************************************************************/

/**  This control has the following functions:

    @param toggle 
 
 <pre class="brush: js; toolbar: false;">
 
 </pre>

    @param toggle_on 
 
 <pre class="brush: js; toolbar: false;">
 
 </pre>
 
    @param toggle_off 
 
 <pre class="brush: js; toolbar: false;">
 
 </pre>

*/

-(void)functions
{
}

/***************************************************************/
/***************************************************************/

/**  Sample Code:

 Example:

 <pre class="brush: js; toolbar: false;">
 
 </pre>
 
*/

-(void)sampleCode
{
}

/***************************************************************/

/*
* /Docs
*
*/

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
        [[self toggleSwitch] setOn:[[self propertyContainer] getBoolPropertyValue:@"initally_selected" defaultValue:NO] animated:NO];
    }
}

-(void)switchToggled:(UISwitch*)sender
{
    if( [[self toggleSwitch] isOn] )
    {
        [[self actionContainer] executeActionsForEventNamed:@"toggle"];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_on"];
    }
    else
    {        
        [[self actionContainer] executeActionsForEventNamed:@"toggle"];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_off"];
    }
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:@"toggle"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [[self toggleSwitch] setOn:![[self toggleSwitch] isOn] animated:animated];
        [[self actionContainer] executeActionsForEventNamed:@"toggle"];

    }
    else if( [functionName isEqualToString:@"toggle_on"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [[self toggleSwitch] setOn:YES animated:animated];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_on"];

    }
    else if( [functionName isEqualToString:@"toggle_off"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [[self toggleSwitch] setOn:NO animated:animated];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_off"];
        
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:@"is_on"] )
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
