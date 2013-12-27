//
//  IXBaseControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseControl.h"

#import "IXAppManager.h"
#import "IXPropertyContainer.h"
#import "ColorUtils.h"
#import "IXLayoutEngine.h"
#import "IXControlLayoutInfo.h"

@interface IXBaseControl ()

@end

@implementation IXBaseControl

-(id)init
{
    self = [super init];
    if( self )
    {
        _contentView = nil;
        _layoutInfo = nil;
        _notifyParentOfLayoutUpdates = YES;
        
        [self buildView];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXBaseControl* baseControl = [super copyWithZone:zone];
    if( baseControl )
    {
        [baseControl buildView];        
    }
    return baseControl;
}

//
// If you override and need to add subviews to the control you need to call super first then add the subviews to the controls contentView.
// If you don't need a view for the control simply override this and do not call super.
//
-(void)buildView
{
    _contentView = [[IXControlContentView alloc] initWithFrame:CGRectZero viewTouchDelegate:self];
    [_contentView setClipsToBounds:NO];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeZero;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    
}

-(void)layoutControl
{
    CGRect internalLayoutRect = [IXLayoutEngine getInternalLayoutRectForControl:self forOuterLayoutRect:[[self contentView] bounds]];
    [self layoutControlContentsInRect:internalLayoutRect];
}

-(void)applyContentViewSettings
{
    [[self contentView] setBackgroundColor:[[self propertyContainer] getColorPropertyValue:@"color.background" defaultValue:[UIColor clearColor]]];
    [[self contentView] setEnabled:[[self propertyContainer] getBoolPropertyValue:@"enabled" defaultValue:YES]];
    [[self contentView] setHidden:![[self propertyContainer] getBoolPropertyValue:@"visible" defaultValue:YES]];
    [[self contentView] setAlpha:[[self propertyContainer] getFloatPropertyValue:@"alpha" defaultValue:1.0f]];
    
    float borderWidth = [[self propertyContainer] getFloatPropertyValue:@"border_width" defaultValue:0.0f];
    UIColor* borderColor = [[self propertyContainer] getColorPropertyValue:@"border_color" defaultValue:[UIColor blackColor]];
    if( [[IXAppManager sharedAppManager] isLayoutDebuggingEnabled] )
    {
        if( borderWidth == 0.0f )
        {
            borderWidth = 1.0f;
            CGFloat hue = ( arc4random() % 256 / 256.0f );
            CGFloat saturation = ( arc4random() % 128 / 256.0f ) + 0.5f;
            CGFloat brightness = ( arc4random() % 128 / 256.0f ) + 0.5f;
            borderColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0f];
        }
    }
    [[[self contentView] layer] setBorderWidth:borderWidth];
    [[[self contentView] layer] setBorderColor:borderColor.CGColor];
    [[[self contentView] layer] setCornerRadius:[[self propertyContainer] getFloatPropertyValue:@"border_radius" defaultValue:0.0f]];
    
    BOOL enableShadow = [[self propertyContainer] getBoolPropertyValue:@"enable_shadow" defaultValue:NO];
    if( enableShadow )
    {
        [[[self contentView] layer] setShouldRasterize:YES];
        [[[self contentView] layer] setRasterizationScale:[[UIScreen mainScreen] scale]];
        [[[self contentView] layer] setShadowRadius:[[self propertyContainer] getFloatPropertyValue:@"shadow_blur" defaultValue:1.0f]];
        [[[self contentView] layer] setShadowOpacity:[[self propertyContainer] getFloatPropertyValue:@"shadow_alpha" defaultValue:1.0f]];
        
        UIColor* shadowColor = [[self propertyContainer] getColorPropertyValue:@"shadow_color" defaultValue:[UIColor blackColor]];
        [[[self contentView] layer] setShadowColor:shadowColor.CGColor];
        
        float shadowOffsetRight = [[self propertyContainer] getFloatPropertyValue:@"shadow_offset_right" defaultValue:2.0f];
        float shadowOffsetDown = [[self propertyContainer] getFloatPropertyValue:@"shadow_offset_down" defaultValue:2.0f];
        [[[self contentView] layer] setShadowOffset:CGSizeMake(shadowOffsetRight, shadowOffsetDown)];
    }
    else
    {
        [[[self contentView] layer] setShouldRasterize:NO];
        [[[self contentView] layer] setShadowOpacity:0.0f];
    }
    
    // TODO: Add gesture recognizers.
}

-(void)applySettings
{
    [super applySettings];
    
    if( [self contentView] != nil )
    {
        if( _layoutInfo == nil )
        {
            _layoutInfo = [[IXControlLayoutInfo alloc] initWithPropertyContainer:[self propertyContainer]];
        }
        else
        {
            [_layoutInfo refreshLayoutInfo];
        }
        
        [self applyContentViewSettings];
    }
    
    for( IXBaseControl* baseControl in [self childObjects] )
    {
        [baseControl applySettings];
    }
}

-(void)controlViewTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self actionContainer] executeActionsForEventNamed:@"touch"];
}

-(void)controlViewTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)controlViewTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)controlViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self actionContainer] executeActionsForEventNamed:@"touch_up"];
}


-(void)executeControlSpecificFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameters
{
    
}

@end
