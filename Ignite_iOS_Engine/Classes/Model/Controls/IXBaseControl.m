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

//
// IXBaseControl Properties :
//      Note: See IXControlLayoutInfo.h for layout properties.
//
static NSString* const kIXAlpha = @"alpha";
static NSString* const kIXBorderWidth = @"border_width";
static NSString* const kIXBorderColor = @"border_color";
static NSString* const kIXBorderRadius = @"border_radius";
static NSString* const kIXBackgroundColor = @"color.background";
static NSString* const kIXEnabled = @"enabled";
static NSString* const kIXEnableTap = @"enable_tap";
static NSString* const kIXEnableSwipe = @"enable_swipe";
static NSString* const kIXEnableShadow = @"enable_shadow";
static NSString* const kIXShadowBlur = @"shadow_blur";
static NSString* const kIXShadowAlpha = @"shadow_alpha";
static NSString* const kIXShadowColor = @"shadow_color";
static NSString* const kIXShadowOffsetRight = @"shadow_offset_right";
static NSString* const kIXShadowOffsetDown = @"shadow_offset_down";
static NSString* const kIXVisible = @"visible";

//
// IXBaseControl Events
//
static NSString* const kIXTouch = @"touch";
static NSString* const kIXTouchUp = @"touch_up";
static NSString* const kIXTouchCancelled = @"touch_cancelled";
static NSString* const kIXTap = @"tap";
static NSString* const kIXTapCount = @"tap_count";
static NSString* const kIXSwipe = @"swipe";
static NSString* const kIXSwipeDirection = @"swipe_direction";
static NSString* const kIXDown = @"down";
static NSString* const kIXUp = @"up";
static NSString* const kIXRight = @"right";
static NSString* const kIXLeft = @"left";

@interface IXBaseControl ()

@property (nonatomic,strong) NSArray* tapGestureRecognizers;
@property (nonatomic,strong) NSArray* swipeGestureRecognizers;

@end

@implementation IXBaseControl

-(void)dealloc
{
    [self removeTapGestureRecognizers];
    [self removeSwipeGestureRecognizers];
}

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
    return baseControl;
}

-(void)setPropertyContainer:(IXPropertyContainer *)propertyContainer
{
    [super setPropertyContainer:propertyContainer];
    [[self layoutInfo] setPropertyContainer:propertyContainer];
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
        [self applyGestureRecognizerSettings];
    }
    
    for( IXBaseControl* baseControl in [self childObjects] )
    {
        [baseControl applySettings];
    }
}

-(void)applyContentViewSettings
{
    [[self contentView] setBackgroundColor:[[self propertyContainer] getColorPropertyValue:kIXBackgroundColor defaultValue:[UIColor clearColor]]];
    [[self contentView] setEnabled:[[self propertyContainer] getBoolPropertyValue:kIXEnabled defaultValue:YES]];
    [[self contentView] setHidden:![[self propertyContainer] getBoolPropertyValue:kIXVisible defaultValue:YES]];
    [[self contentView] setAlpha:[[self propertyContainer] getFloatPropertyValue:kIXAlpha defaultValue:1.0f]];
    
    float borderWidth = [[self propertyContainer] getFloatPropertyValue:kIXBorderWidth defaultValue:0.0f];
    UIColor* borderColor = [[self propertyContainer] getColorPropertyValue:kIXBorderColor defaultValue:[UIColor blackColor]];
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
    [[[self contentView] layer] setCornerRadius:[[self propertyContainer] getFloatPropertyValue:kIXBorderRadius defaultValue:0.0f]];
    
    BOOL enableShadow = [[self propertyContainer] getBoolPropertyValue:kIXEnableShadow defaultValue:NO];
    if( enableShadow )
    {
        [[[self contentView] layer] setShouldRasterize:YES];
        [[[self contentView] layer] setRasterizationScale:[[UIScreen mainScreen] scale]];
        [[[self contentView] layer] setShadowRadius:[[self propertyContainer] getFloatPropertyValue:kIXShadowBlur defaultValue:1.0f]];
        [[[self contentView] layer] setShadowOpacity:[[self propertyContainer] getFloatPropertyValue:kIXShadowAlpha defaultValue:1.0f]];
        
        UIColor* shadowColor = [[self propertyContainer] getColorPropertyValue:kIXShadowColor defaultValue:[UIColor blackColor]];
        [[[self contentView] layer] setShadowColor:shadowColor.CGColor];
        
        float shadowOffsetRight = [[self propertyContainer] getFloatPropertyValue:kIXShadowOffsetRight defaultValue:2.0f];
        float shadowOffsetDown = [[self propertyContainer] getFloatPropertyValue:kIXShadowOffsetDown defaultValue:2.0f];
        [[[self contentView] layer] setShadowOffset:CGSizeMake(shadowOffsetRight, shadowOffsetDown)];
    }
    else
    {
        [[[self contentView] layer] setShouldRasterize:NO];
        [[[self contentView] layer] setShadowOpacity:0.0f];
    }
}

-(void)addTapGestureRecognizers
{
    if( ![[self tapGestureRecognizers] count] )
    {
        NSMutableArray* tapRecognizers = [NSMutableArray array];
        UITapGestureRecognizer* previousTapRecognizer = nil;
        for( int i = 5; i > 0; i-- )
        {
            UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
            [tapRecognizer setNumberOfTapsRequired:i];
            [tapRecognizer setDelaysTouchesEnded:NO];
            [tapRecognizer setCancelsTouchesInView:NO];
            if( previousTapRecognizer )
            {
                [tapRecognizer requireGestureRecognizerToFail:previousTapRecognizer];
            }
            [[self contentView] addGestureRecognizer:tapRecognizer];
            [tapRecognizers addObject:tapRecognizer];
            previousTapRecognizer = tapRecognizer;
        }
        [self setTapGestureRecognizers:tapRecognizers];
    }
}

-(void)removeTapGestureRecognizers
{
    if( [[self tapGestureRecognizers] count] )
    {
        for( UITapGestureRecognizer* tapRecognizer in [self tapGestureRecognizers] )
        {
            [tapRecognizer removeTarget:self action:@selector(tapGestureRecognized:)];
            [[self contentView] removeGestureRecognizer:tapRecognizer];
        }
        [self setTapGestureRecognizers:nil];
    }
}

-(void)addSwipeGestureRecognizers
{
    if( ![[self swipeGestureRecognizers] count] )
    {
        NSMutableArray* swipeRecognizers = [NSMutableArray array];
        for( int i = 0; i < 4; i++ )
        {
            UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)];
            [swipeRecognizer setDelaysTouchesEnded:NO];
            [swipeRecognizer setCancelsTouchesInView:NO];
            
            UISwipeGestureRecognizerDirection swipeDirection = 1 << i;
            [swipeRecognizer setDirection:swipeDirection];
            
            [[self contentView] addGestureRecognizer:swipeRecognizer];
            [swipeRecognizers addObject:swipeRecognizer];
        }
        [self setSwipeGestureRecognizers:swipeRecognizers];
    }
}

-(void)removeSwipeGestureRecognizers
{
    if([[self swipeGestureRecognizers] count])
    {
        for( UISwipeGestureRecognizer* swipeRecognizer in [self swipeGestureRecognizers] )
        {
            [swipeRecognizer removeTarget:self action:@selector(swipeGestureRecognized:)];
            [[self contentView] removeGestureRecognizer:swipeRecognizer];
        }
        [self setSwipeGestureRecognizers:nil];
    }
}

-(void)applyGestureRecognizerSettings
{
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnableTap defaultValue:NO] )
    {
        [self addTapGestureRecognizers];
    }
    else
    {
        [self removeTapGestureRecognizers];
    }
    
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnableSwipe defaultValue:NO] )
    {
        [self addSwipeGestureRecognizers];
    }
    else
    {
        [self removeSwipeGestureRecognizers];
    }
}

-(void)tapGestureRecognized:(UITapGestureRecognizer*)tapRecognizer
{
    NSString* tapCount = [NSString stringWithFormat:@"%lu",[tapRecognizer numberOfTapsRequired]];
    [[self actionContainer] executeActionsForEventNamed:kIXTap propertyWithName:kIXTapCount mustHaveValue:tapCount];
}

-(void)swipeGestureRecognized:(UISwipeGestureRecognizer*)swipeRecognizer
{
    NSString* swipeDirection = nil;
    switch ([swipeRecognizer direction]) {
        case UISwipeGestureRecognizerDirectionDown:{
            swipeDirection = kIXDown;
            break;
        }
        case UISwipeGestureRecognizerDirectionLeft:{
            swipeDirection = kIXLeft;
            break;
        }
        case UISwipeGestureRecognizerDirectionRight:{
            swipeDirection = kIXRight;
            break;
        }
        case UISwipeGestureRecognizerDirectionUp:{
            swipeDirection = kIXUp;
            break;
        }
        default:{
            break;
        }
    }
    if( swipeDirection )
    {
        [[self actionContainer] executeActionsForEventNamed:kIXSwipe propertyWithName:kIXSwipeDirection mustHaveValue:swipeDirection];
    }
}

-(IXBaseControl*)getTouchedControl:(UITouch*)touch
{
    if( touch == nil )
        return nil;
    
    IXBaseControl* returnControl = self;
    for( IXBaseControl* baseControl in [self childObjects] )
    {
        IXControlContentView* baseControlView = [baseControl contentView];
        if( baseControlView )
        {
            if( ![[baseControl contentView] isHidden] && [baseControlView alpha] > 0.0f )
            {
                if( CGRectContainsPoint([baseControlView bounds], [touch locationInView:baseControlView]) )
                {
                    returnControl = [baseControl getTouchedControl:touch];
                }
            }
        }
    }
    return returnControl;
}

-(void)processBeginTouch:(BOOL)fireTouchActions
{
    if( fireTouchActions )
    {
        if( [[self actionContainer] hasActionsWithEventNamePrefix:kIXTouch] )
        {
            [[self actionContainer] executeActionsForEventNamed:kIXTouch];
        }
        else if( [[self parentObject] isKindOfClass:[IXBaseControl class]] )
        {
            IXBaseControl* parentControl = (IXBaseControl*)[self parentObject];
            if( [parentControl contentView] )
            {
                [parentControl processBeginTouch:fireTouchActions];
            }
        }
    }
}

-(void)processCancelTouch:(BOOL)fireTouchActions
{
    if( fireTouchActions )
    {
        IXBaseControl* parentControl = (IXBaseControl*)[self parentObject];
        if( [parentControl contentView] )
        {
            [parentControl processCancelTouch:fireTouchActions];
        }
        [[self actionContainer] executeActionsForEventNamed:kIXTouchCancelled];
    }
}

-(void)processEndTouch:(BOOL)fireTouchActions
{
    if( fireTouchActions )
    {
        IXBaseControl* parentControl = (IXBaseControl*)[self parentObject];
        if( [parentControl contentView] )
        {
            [parentControl processEndTouch:fireTouchActions];
        }
        [[self actionContainer] executeActionsForEventNamed:kIXTouchUp];
    }
}

-(void)controlViewTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    IXBaseControl* touchedControl = [self getTouchedControl:touch];
    
    [touchedControl processBeginTouch:YES];
}

-(void)controlViewTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)controlViewTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processCancelTouch:YES];
}

-(void)controlViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch* touch = [touches anyObject];
//    BOOL shouldFireTouchActions = ( [touch view] == [self contentView] && [touch tapCount] >= 1 );
    
    [self processEndTouch:YES];
}

-(void)executeControlSpecificFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameters
{
    
}

-(void)conserveMemory
{
    for( IXBaseControl* control in [self childObjects] )
    {
        [control conserveMemory];
    }
}

@end
