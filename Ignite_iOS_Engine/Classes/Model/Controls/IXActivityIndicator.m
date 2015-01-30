//
//  IXActivityIndicator.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/14/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/28/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###
 ###    UI spinner.
 
 ####
 #### Attributes
 |  Name                            |   Type                        |   Description                                         |   Default
 |:---------------------------------|:-----------------------------:|:------------------------------------------------------|:-------------:|
 | *style*                          |   *white<br>large<br>gray*    |   The spinner style                                   |   large
 | *color*                          |   *(color)*                   |   The spinner color                                   |   #ffffff

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
      "_id": "spinner",
      "_type": "ActivityIndicator",
      "attributes": {
        "color": "ff00ff",
        "layout_type":"float",
        "horizontal_alignment":"center",
        "vertical_alignment":"middle",
        "style": "white"
      }
    }
 
*/
//
//  [/Documentation]
/*  -----------------------------  */

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
