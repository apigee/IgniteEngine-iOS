//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/14/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 
 CONTROL
 
 - TYPE : "Spinner"
 
 - PROPERTIES
 
 * name="style"                     default="white"               type="String"
  
 */

#import "IXActivityIndicator.h"

@interface IXActivityIndicator ()

@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;

@end

@implementation IXActivityIndicator

-(void)buildView
{
    [super buildView];
}

-(void)configureActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style
{
    UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    [activityIndicatorView setHidesWhenStopped:NO];
    [activityIndicatorView setCenter:CGPointMake([self activityIndicator].frame.size.height/2, [self activityIndicator].frame.size.width/2)];
    [activityIndicatorView startAnimating];
    
    [[self activityIndicator] stopAnimating];
    [[self activityIndicator] removeFromSuperview];
    
    [self setActivityIndicator:activityIndicatorView];
    [[self contentView] addSubview:[self activityIndicator]];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeMake([self activityIndicator].frame.size.width, [self activityIndicator].frame.size.height);
}

-(void)applySettings
{
    [super applySettings];
    
    UIActivityIndicatorViewStyle activityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    NSString* spinnerStyleString = [[self propertyContainer] getStringPropertyValue:@"style" defaultValue:@"white"];
    if( [spinnerStyleString isEqualToString:@"gray"] )
    {
        activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    }
    else if( [spinnerStyleString isEqualToString:@"large"] )
    {
        activityIndicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    [self configureActivityIndicatorWithStyle:activityIndicatorStyle];
}

@end
