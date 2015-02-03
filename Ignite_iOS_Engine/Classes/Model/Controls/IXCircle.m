//
//  IXCircle.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/16/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
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
 
 Not much to say about this one. It's round. Use it as a button, loading indicator, or..?
 

 <div id="container">
<a href="../images/IXCircle.png" data-imagelightbox="c"><img src="../images/IXCircle.png" alt=""></a>

</div>
 
*/

/*
 *      /Docs
 *
*/


#import "IXCircle.h"

static NSString* const kIXSize = @"size";
static NSString* const kIXColor = @"color";

@implementation IXCircle : IXBaseControl

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
 
    @param size Circle size<br>*(integer)*
    @param color Circle color<br>*(color)*
 
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

/**  Usage:
 
 Example:
 
 <pre class="brush: js; toolbar: false;">
{
  "_id": "circleTest",
  "_type": "Circle",
  "attributes": {
    "size": 50,
    "color": "#fa4c06",
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

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [self.circleView sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [self.circleView setFrame:rect];
}

-(void)buildView
{
    [super buildView];
    self.circleView = [[UIView alloc] init];
    [self.contentView addSubview:self.circleView];
}

-(void)applySettings
{
    [super applySettings];
    
    NSInteger size = [self.propertyContainer getIntPropertyValue:kIXSize defaultValue:100];
    UIColor *color = [self.propertyContainer getColorPropertyValue:kIXColor defaultValue:[UIColor blackColor]];
    
    self.circleView.frame = CGRectMake(0,0,size,size);
    self.circleView.layer.cornerRadius = size / 2;
    self.circleView.backgroundColor = color;
    
}

@end
