//
//  IXCircle.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/16/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###
 ###    A round bit.
 
 ####
 #### Attributes
 
 |  Name                            |   Type                        |   Description                                         |   Default
 |:---------------------------------|:-----------------------------:|:------------------------------------------------------|:-------------:|
 | *size*                           |   *(integer)*                 |   Circle size                                         |
 | *color*                          |   *(color)*                   |   Circle color                                        |

 ####
 #### Inherits
 >  IXBaseControl
 
 ####
 #### Events
 >  None
 
 ####
 #### Functions
 >  None
 
 #### Example JSON
 
    {
      "_id": "circleTest",
      "_type": "Circle",
      "attributes": {
        "size": 50,
        "color": "#ff00ff",
        "layout_type": "absolute",
        "horizontal_alignment": "center",
        "vertical_alignment": "middle"
      }
    }
 
*/
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXCircle.h"

static NSString* const kIXSize = @"size";
static NSString* const kIXColor = @"color";

@implementation IXCircle : IXBaseControl


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
