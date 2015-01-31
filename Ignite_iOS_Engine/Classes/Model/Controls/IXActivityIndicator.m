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
 *      Date:     42034
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
 */

/**
 
 ###
 ###    Simple native iOS spinners. They spin.
 ###
 ###    Looks like:
 
 <a href="../../images/IXActivityIndicator.png" data-imagelightbox="b"><img src="../../images/IXActivityIndicator.png" alt="" width="160" height="284"></a>
 
 ###    Here's how you use it:
 
 */

/*
 *      /Docs
 *
*/

#import "IXActivityIndicator.h"

// IXActivityIndicator Attributes
IX_STATIC_CONST_STRING kIXActivityIndicatorStyle = @"style";
IX_STATIC_CONST_STRING kIXActivityIndicatorColor = @"color"; // Note: Setting this overrides the color set by kIXActivityIndicatorStyle

// kIXActivityIndicatorStyle Accepted Values
IX_STATIC_CONST_STRING kIXActivityIndicatorStyleWhite = @"white";
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

/** Configuration Atributes

    @param style The spinner style *(default: large)*<br>*whitelargegray*
    @param color The spinner color *(default: #ffffff)*<br>*(color)*








*/

-(void)config
{
}
/***************************************************************/
/***************************************************************/

/**  This control has the following read-only properties:





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
