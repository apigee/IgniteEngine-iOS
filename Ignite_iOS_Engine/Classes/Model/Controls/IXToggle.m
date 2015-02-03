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
 
 Toggle switch to toggle on and to toggle off.
 

 <div id="container">
 <ul>
 <li><a href="../images/IXToggle_0.png" data-imagelightbox="c"><img src="../images/IXToggle_0.png"></a></li>
 <li><a href="../images/IXToggle_1.png" data-imagelightbox="c"><img src="../images/IXToggle_1.png"></a></li>
 </ul>
</div>
 
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

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

    @param initally_selected Should the toggle be selected by default? *(default: FALSE)*<br>*bool*

*/

-(void)attributes
{
}
/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-info">
 <i class="ti-loop"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Returns</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

 @param is_on Is the toggle on?<br>*(bool)*

*/

-(void)returns
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-success">
 <i class="ti-pulse"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Events</h3>
 <p>This control fires the following events:</p>
 </div>
 </div>


-(void)events
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-danger">
 <i class="ti-direction"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Functions</h3>
 <p>This control supports the following functions:</p>
 </div>
 </div>


 @param toggle Toggle the toggle
 
 <pre class="brush: js; toolbar: false;">
 
{
  "on": "touch_up",
  "_type": "Function",
  "attributes": {
    "_target": "toggleText"
  }
}
 
 </pre>
 
 @param toggle_on Turn the toggle on
 
 <pre class="brush: js; toolbar: false;">
 
{
  "on": "touch_up",
  "_type": "Function",
  "attributes": {
    "_target": "toggleText",
    "function_name":"toggle_on"
  }
}
 
 </pre>
 
 @param toggle_off Turn the toggle off
 
 <pre class="brush: js; toolbar: false;">
 
{
  "on": "touch_up",
  "_type": "Function",
  "attributes": {
    "_target": "toggleText",
    "function_name":"toggle_off"
  }
}
 
 </pre>
 
*/

-(void)functions
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-primary">
 <i class="ti-shortcode"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Example</h3>
 <p>Go on, try it out!</p>
 </div>
 </div>


 <pre class="brush: js; toolbar: false;">
 
{
  "_id": "toggleTest",
  "_type": "Toggle",
  "attributes": {
    "layout_type": "absolute",
    "horizontal_alignment": "center",
    "vertical_alignment": "middle"
  }
}
 
 </pre>
 
*/

-(void)example
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
