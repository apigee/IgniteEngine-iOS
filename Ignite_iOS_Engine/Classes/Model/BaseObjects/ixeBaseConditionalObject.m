//
//  ixeBaseConditionalObject.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeBaseConditionalObject.h"

#import "ixeAppManager.h"
#import "ixeProperty.h"

@implementation ixeBaseConditionalObject

-(id)init
{
    self = [super init];
    if( self )
    {
        _conditionalProperty = nil;
        _interfaceOrientationMask = UIInterfaceOrientationMaskAll;
    }
    return self;
}

-(BOOL)isOrientationMaskValidForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL orientationIsValid = YES;
    if( [self interfaceOrientationMask] != UIInterfaceOrientationMaskAll )
    {
        if( UIInterfaceOrientationIsPortrait(interfaceOrientation) )
        {
            // If the current orientation is Portrait check to see if this property is for portrait orientation
            orientationIsValid = ([self interfaceOrientationMask] == UIInterfaceOrientationMaskPortrait);
        }
        else
        {
            // If the current orientation is not Portrait check to see if this property is for landscape orientation
            orientationIsValid = ([self interfaceOrientationMask] == UIInterfaceOrientationMaskLandscape);
        }
    }
    return orientationIsValid;
}

-(BOOL)isConditionalValid
{
    BOOL conditionalPropertyIsValid = YES;
    if( [self conditionalProperty] != nil )
    {
        NSString* conditionalPropertyValue = [[self conditionalProperty] getPropertyValue];
        if( conditionalPropertyValue && [conditionalPropertyValue length] > 0 )
        {
            NSString* conditionalPropertyValueReturned = [[ixeAppManager sharedInstance] evaluateJavascript:conditionalPropertyValue];
            
            conditionalPropertyIsValid = !( conditionalPropertyValueReturned == nil || [conditionalPropertyValueReturned length] <= 0 || [conditionalPropertyValueReturned isEqualToString:@"0"] || [conditionalPropertyValueReturned isEqualToString:@"false"] );
        }
    }
    return conditionalPropertyIsValid;
}

-(BOOL)areConditionalAndOrientationMaskValid:(UIInterfaceOrientation)interfaceOrientation
{
    return [self isConditionalValid] && [self isOrientationMaskValidForOrientation:interfaceOrientation];
}


@end
