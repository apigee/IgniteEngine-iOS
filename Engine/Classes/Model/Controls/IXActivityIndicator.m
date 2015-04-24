//
//  IXActivityIndicator.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/14/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXActivityIndicator.h"

// Attributes
IX_STATIC_CONST_STRING kIXActivityIndicatorStyle = @"size";
IX_STATIC_CONST_STRING kIXActivityIndicatorColor = @"color"; // Note: Setting this overrides the color set by kIXActivityIndicatorStyle

// Attribute Accepted Values
//TODO: TO BE DEPRECATED kIXActivityIndicatorStyleGray
IX_STATIC_CONST_STRING kIXActivityIndicatorStyleGray = @"gray";
#pragma end

IX_STATIC_CONST_STRING kIXActivityIndicatorStyleWhite = @"small";
IX_STATIC_CONST_STRING kIXActivityIndicatorStyleLarge = @"large";

// Attribute Defaults

IX_STATIC_CONST_STRING kIXDefaultActivityIndicatorStyle = @"large";

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
    NSString* spinnerStyleString = [[self propertyContainer] getStringPropertyValue:kIXActivityIndicatorStyle defaultValue:kIXDefaultActivityIndicatorStyle];
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
