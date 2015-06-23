//
//  IXActivityIndicator.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/14/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
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
    NSString* spinnerStyleString = [[self attributeContainer] getStringValueForAttribute:kIXActivityIndicatorStyle defaultValue:kIXDefaultActivityIndicatorStyle];
    if( [spinnerStyleString isEqualToString:kIXActivityIndicatorStyleGray] ) {
        activityIndicatorColor = [UIColor grayColor];
        activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    } else if( [spinnerStyleString isEqualToString:kIXActivityIndicatorStyleLarge] ) {
        activityIndicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    
    [[self activityIndicator] setActivityIndicatorViewStyle:activityIndicatorStyle];
    [[self activityIndicator] setColor:[[self attributeContainer] getColorValueForAttribute:kIXActivityIndicatorColor defaultValue:activityIndicatorColor]];
    [self centerActivityIndicator];
}

-(void)centerActivityIndicator
{
    CGRect contentViewFrame = [[self contentView] frame];
    CGPoint center = CGPointMake(CGRectGetWidth(contentViewFrame)/2,CGRectGetHeight(contentViewFrame)/2);
    [[self activityIndicator] setCenter:center];
}

@end
