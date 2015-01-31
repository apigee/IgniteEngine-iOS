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
 
 ###
 ###    A round bit.
 ###
 ###    Looks like:
 
<a href="../../images/IXCircle.png" data-imagelightbox="b"><img src="../../images/IXCircle.png" alt="" width="160" height="284"></a>

 ###    Here's how you use it:
 
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

/** Configuration Atributes
 
    @param size Circle size<br>*(integer)*
    @param color Circle color<br>*(color)*
 
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
