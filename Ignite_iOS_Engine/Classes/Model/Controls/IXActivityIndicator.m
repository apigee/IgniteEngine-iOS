//
//  IXActivityIndicator.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/14/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:       01/28/2015
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/** Simple native iOS spinners. They spin.
*/

#import "IXActivityIndicator.h"

// IXActivityIndicator Attributes
IX_STATIC_CONST_STRING kIXActivityIndicatorStyle = @"size";
IX_STATIC_CONST_STRING kIXActivityIndicatorColor = @"color"; // Note: Setting this overrides the color set by kIXActivityIndicatorStyle

// kIXActivityIndicatorStyle Accepted Values
IX_STATIC_CONST_STRING kIXActivityIndicatorStyleWhite = @"small";
IX_STATIC_CONST_STRING kIXActivityIndicatorStyleLarge = @"large";
IX_STATIC_CONST_STRING kIXActivityIndicatorStyleGray = @"gray";

@interface IXActivityIndicator ()

@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;

@end

@implementation IXActivityIndicator

/*
* Docs
*
*/

/***************************************************************/

/** This control has the following attributes:

    @param style The spinner style *(default: large)*<br>*whitelargegray*
    @param color The spinner color *(default: #ffffff)*<br>*(color)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:
*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:
*/

-(void)Events
{
}


/***************************************************************/
/***************************************************************/

/** This control supports the following functions:

*/

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!

<pre class="brush: js; toolbar: false;">
{
  "_id": "spinner",
  "_type": "ActivityIndicator",
  "attributes": {
    "color": "#fa4c06",
    "layout_type": "float",
    "horizontal_alignment": "center",
    "vertical_alignment": "middle",
    "style": "gray"
  }
}
</pre>
*/

-(void)Example
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
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_activityIndicator setHidesWhenStopped:NO];
    [_activityIndicator startAnimating];
    
    [[self contentView] addSubview:_activityIndicator];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [[self activityIndicator] frame].size;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self activityIndicator] setFrame:rect];
    [self centerActivityIndicator];
}


-(void)applySettings
{
    [super applySettings];
  
    UIColor* activityIndicatorColor = [UIColor whiteColor];
    UIActivityIndicatorViewStyle activityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    NSString* spinnerStyleString = [[self propertyContainer] getStringPropertyValue:kIXActivityIndicatorStyle defaultValue:kIXActivityIndicatorStyleLarge];
    if( [spinnerStyleString isEqualToString:kIXActivityIndicatorStyleGray] ) {
        activityIndicatorColor = [UIColor grayColor];
        activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    } else if( [spinnerStyleString isEqualToString:kIXActivityIndicatorStyleLarge] ) {
        activityIndicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    
    [[self activityIndicator] setActivityIndicatorViewStyle:activityIndicatorStyle];
    [[self activityIndicator] setColor:[[self propertyContainer] getColorPropertyValue:kIXActivityIndicatorColor defaultValue:activityIndicatorColor]];
    [self centerActivityIndicator];
}

-(void)centerActivityIndicator
{
    CGRect contentViewFrame = [[self contentView] frame];
    CGPoint center = CGPointMake(CGRectGetWidth(contentViewFrame)/2,CGRectGetHeight(contentViewFrame)/2);
    [[self activityIndicator] setCenter:center];
}

@end
