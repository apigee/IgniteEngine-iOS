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

/**
 
 Simple native iOS spinners. They spin.
 
 <div id="container">   <ul>
         <li><a href="../images/IXActivityIndicator_0.png" data-imagelightbox="c"><img src="../images/IXActivityIndicator_0.png"></a></li>
         <li><a href="../images/IXActivityIndicator_1.png" data-imagelightbox="c"><img src="../images/IXActivityIndicator_1.png"></a></li>
         <li><a href="../images/IXActivityIndicator_2.png" data-imagelightbox="c"><img src="../images/IXActivityIndicator_2.png"></a></li>
     </ul>
 </div>
 
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

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

    @param style The spinner style *(default: large)*<br>*whitelargegray*
    @param color The spinner color *(default: #ffffff)*<br>*(color)*

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
