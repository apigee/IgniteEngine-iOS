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
 *      Date:     	1/28/2015
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/** Not much to say about this one. It's round. Use it as a button, loading indicator, or..?
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

/** This control has the following attributes:
 
    @param size Circle size<br>*(integer)*
    @param color Circle color<br>*(color)*
 
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

-(void)Example
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
