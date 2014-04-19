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
#import "IXLogger.h"

#import "UIImage+ResizeMagick.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

//
// IXBaseControl Properties :
//      Note: See IXControlLayoutInfo.h for layout properties.
//
static NSString* const kIXAlpha = @"alpha";
static NSString* const kIXBorderWidth = @"border.width";
static NSString* const kIXBorderColor = @"border.color";
static NSString* const kIXBorderRadius = @"border.radius";
static NSString* const kIXBackgroundColor = @"background.color";
static NSString* const kIXBackgroundImage = @"background.image";
static NSString* const kIXBackgroundImageScale = @"background.image.scale";
static NSString* const kIXEnabled = @"enabled";
static NSString* const kIXEnableTap = @"enable_tap";
static NSString* const kIXEnableSwipe = @"enable_swipe";
static NSString* const kIXEnablePinch = @"enable_pinch";
static NSString* const kIXEnablePan = @"enable_pan";
static NSString* const kIXEnableShadow = @"enable_shadow";
static NSString* const kIXShadowBlur = @"shadow_blur";
static NSString* const kIXShadowAlpha = @"shadow_alpha";
static NSString* const kIXShadowColor = @"shadow_color";
static NSString* const kIXShadowOffsetRight = @"shadow_offset_right";
static NSString* const kIXShadowOffsetDown = @"shadow_offset_down";
static NSString* const kIXVisible = @"visible";

// kIXBackgroundImageScale Types
static NSString* const kIXBackgroundImageScaleCover = @"cover";
static NSString* const kIXBackgroundImageScaleStretch = @"stretch";
static NSString* const kIXBackgroundImageScaleTile = @"tile";
static NSString* const kIXBackgroundImageScaleContain = @"contain";

//
// IXBaseControl gesture events
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
static NSString* const kIXPan = @"pan";
static NSString* const kIXPanReset = @"pan.reset";
static NSString* const kIXPanSnap = @"pan.snap_to_bounds";
static BOOL kIXDidDetermineOriginalCenter = false;

//
// IXBaseControl pinch events & handlers
//
static NSString* const kIXPinchIn = @"pinch.in";
static NSString* const kIXPinchOut = @"pinch.out";
static NSString* const kIXPinchZoom = @"pinch.zoom"; //both (default), horizontal, or vertical
static NSString* const kIXPinchReset = @"pinch.reset";
static NSString* const kIXPinchMax = @"pinch.max";
static NSString* const kIXPinchMin = @"pinch.min";
static NSString* const kIXPinchElastic = @"pinch.elastic";
static NSString* const kIXPinchHorizontal = @"horizontal";
static NSString* const kIXPinchVertical = @"vertical";
static NSString* const kIXPinchBoth = @"both";

// Read-only properties
static NSString* const kIXLocation = @"location";
static NSString* const kIXLocationX = @"location.x";
static NSString* const kIXLocationY = @"location.y";

// Animations
static BOOL kIXIsAnimating;
static NSInteger kIXAnimationCounter;
static NSString* const kIXSpin = @"spin";

static NSString* const kIXDirection = @"direction";
static NSString* const kIXReverse = @"reverse";

// Animation Functions
static NSString* const kIXStartAnimation = @"start_animation";
static NSString* const kIXStopAnimation = @"stop_animation";

// Functions & Helpers
static NSString* const kIXToggle = @"dev_toggle";

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

-(BOOL)isContentViewVisible
{
    BOOL isVisible = NO;
    if( [self contentView] )
    {
        if( ![[self contentView] isHidden] && [[self contentView] alpha] > 0.0f )
        {
            isVisible = YES;
        }
    }
    return isVisible;
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
    if( [self parentObject] && [self shouldNotifyParentOfLayoutUpdates] )
    {
        [((IXBaseControl*)[self parentObject]) layoutControl];
    }
    else
    {
        CGRect internalLayoutRect = [IXLayoutEngine getInternalLayoutRectForControl:self forOuterLayoutRect:[[self contentView] bounds]];
        [self layoutControlContentsInRect:internalLayoutRect];
    }
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
    NSString* backgroundImage = [[self propertyContainer] getStringPropertyValue:kIXBackgroundImage defaultValue:nil];
    if( backgroundImage )
    {
        NSString* backgroundImageScale = [[self propertyContainer] getStringPropertyValue:kIXBackgroundImageScale
                                                                             defaultValue:kIXBackgroundImageScaleCover];
        
        static NSDictionary *sIXBackgroundImageScaleFormatDictionary = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sIXBackgroundImageScaleFormatDictionary = @{kIXBackgroundImageScaleCover: @"%.0fx%.0f^",
                                                        kIXBackgroundImageScaleStretch: @"%.0fx%.0f!",
                                                        kIXBackgroundImageScaleTile: @"%.0fx%.0f",
                                                        kIXBackgroundImageScaleContain: @"%.0fx%.0f"};
        });
        
        NSString* backgroundImageScaleFormat = sIXBackgroundImageScaleFormatDictionary[backgroundImageScale];
        BOOL isScaleTypeContain = [backgroundImageScale isEqualToString:kIXBackgroundImageScaleContain];
        
        if( backgroundImageScaleFormat != nil )
        {
            __weak typeof(self) weakSelf = self;
            [[self propertyContainer] getImageProperty:kIXBackgroundImage successBlock:^(UIImage *image) {
                
                CGSize size = [[weakSelf contentView] bounds].size;
                
                image = [image resizedImageByMagick:[NSString stringWithFormat:backgroundImageScaleFormat,size.width,size.height]];
                
                if( isScaleTypeContain )
                {
                    UIGraphicsBeginImageContext(size);
                    
                    [[UIColor clearColor] setFill];
                    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
                    
                    CGRect rect = CGRectMake(((size.width - image.size.width) / 2), ((size.height - image.size.height) / 2), image.size.width, image.size.height);
                    [image drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    
                    UIGraphicsEndImageContext();
                }
                
                [[weakSelf contentView] setBackgroundColor:[UIColor colorWithPatternImage:image]];
                
            } failBlock:^(NSError *error) {

                [[weakSelf contentView] setBackgroundColor:[[weakSelf propertyContainer] getColorPropertyValue:kIXBackgroundColor defaultValue:[UIColor clearColor]]];
                
                IX_LOG_DEBUG(@"Background image failed to load at %@", kIXBackgroundImage);
            }];
        }
        else
        {
            [[self contentView] setBackgroundColor:[[self propertyContainer] getColorPropertyValue:kIXBackgroundColor defaultValue:[UIColor clearColor]]];
        }
    }
    else
    {
        [[self contentView] setBackgroundColor:[[self propertyContainer] getColorPropertyValue:kIXBackgroundColor defaultValue:[UIColor clearColor]]];
    }
    
    [[self contentView] setEnabled:[[self propertyContainer] getBoolPropertyValue:kIXEnabled defaultValue:YES]];
    [[self contentView] setHidden:[[self layoutInfo] isHidden]];
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

-(void)applyGestureRecognizerSettings
{
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnableTap defaultValue:NO] )
    {
        [[self contentView] beginListeningForTapGestures];
    }
    else
    {
        [[self contentView] stopListeningForTapGestures];
    }
    
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnableSwipe defaultValue:NO] )
    {
        [[self contentView] beginListeningForSwipeGestures];
    }
    else
    {
        [[self contentView] stopListeningForSwipeGestures];
    }
    
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnablePinch defaultValue:NO] )
    {
        [[self contentView] beginListeningForPinchGestures];
    }
    else
    {
        [[self contentView] stopListeningForPinchGestures];
    }
    
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnablePan defaultValue:NO] )
    {
        [[self contentView] beginListeningForPanGestures];
    }
    else
    {
        [[self contentView] stopListeningForPanGestures];
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

-(void)controlViewTapGestureRecognized:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSString* tapCount = [NSString stringWithFormat:@"%lu",(unsigned long)[tapGestureRecognizer numberOfTapsRequired]];
    [[self actionContainer] executeActionsForEventNamed:kIXTap propertyWithName:kIXTapCount mustHaveValue:tapCount];
}

-(void)controlViewSwipeGestureRecognized:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    NSString* swipeDirection = nil;
    switch ([swipeGestureRecognizer direction]) {
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

-(void)controlViewPinchGestureRecognized:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    NSString* zoomDirection = [[self propertyContainer] getStringPropertyValue:kIXPinchZoom defaultValue:nil];
    
    if( zoomDirection != nil )
    {
        
        BOOL resetSize = [self.propertyContainer getBoolPropertyValue:kIXPinchReset defaultValue:YES];
        const CGFloat kMinScale = [self.propertyContainer getFloatPropertyValue:kIXPinchMin defaultValue:1.0];
        const CGFloat kMaxScale = [self.propertyContainer getFloatPropertyValue:kIXPinchMax defaultValue:2.0];
        const CGFloat kElastic = [self.propertyContainer getFloatPropertyValue:kIXPinchElastic defaultValue:0.5];
        
        CGFloat previousScale = 1;
        
        if(pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            // Reset the last scale, necessary if there are multiple objects with different scales
            previousScale = pinchGestureRecognizer.scale;
        }
        
        if(pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
           pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            CGAffineTransform transform = CGAffineTransformIdentity;
            CGFloat currentScale = [[pinchGestureRecognizer.view.layer valueForKeyPath:@"transform.scale"] floatValue];
            CGFloat newScale = 1 - (previousScale - pinchGestureRecognizer.scale);
            newScale = MIN(newScale, (kMaxScale + kElastic) / currentScale);
            newScale = MAX(newScale, (kMinScale - kElastic) / currentScale);
            if ([zoomDirection isEqualToString:kIXPinchVertical])
            {
                transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, 1, newScale);
            }
            else if ([zoomDirection isEqualToString:kIXPinchHorizontal])
            {
                transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, newScale, 1);
            }
            else if ([zoomDirection isEqualToString:kIXPinchBoth])
            {
                transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, newScale, newScale);
            }
            pinchGestureRecognizer.view.transform = transform;
            previousScale = pinchGestureRecognizer.scale;
            pinchGestureRecognizer.scale = 1;
        }
        
        if(pinchGestureRecognizer.state == UIGestureRecognizerStateEnded ||
           pinchGestureRecognizer.state == UIGestureRecognizerStateCancelled)
        {
            if (resetSize)
            {
                CGAffineTransform resetTransform;
                CGFloat currentScale = [[pinchGestureRecognizer.view.layer valueForKeyPath:@"transform.scale"] floatValue];
                CGFloat resetWidth = currentScale;
                CGFloat resetHeight = currentScale;
                if (currentScale < kMinScale)
                {
                    resetWidth = kMinScale;
                    resetHeight = kMinScale;
                    
                }
                else if (currentScale > kMaxScale)
                {
                    resetWidth = kMaxScale;
                    resetHeight = kMaxScale;
                }
                
                if ([zoomDirection isEqualToString:kIXPinchVertical])
                    resetHeight = 1;
                else if ([zoomDirection isEqualToString:kIXPinchHorizontal])
                    resetWidth = 1;
                
                resetTransform = CGAffineTransformMakeScale(resetHeight, resetWidth);
                
                if (currentScale > kMaxScale || currentScale < kMinScale)
                {
                    [UIView animateWithDuration:0.2
                                     animations:^{
                                         pinchGestureRecognizer.view.transform = resetTransform;
                                     }];
                     
                }
            }
            

        }
    }
    if(pinchGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //Pinch out
        if (pinchGestureRecognizer.scale > 1)
        {
            [[self actionContainer] executeActionsForEventNamed:kIXPinchOut];
        }
        //Pinch in
        else if (pinchGestureRecognizer.scale < 1)
        {
            [[self actionContainer] executeActionsForEventNamed:kIXPinchIn];
        }
    }
}

-(void)controlViewPanGestureRecognized:(UIPanGestureRecognizer *)panGestureRecognizer
{
    BOOL resetPosition = [self.propertyContainer getBoolPropertyValue:kIXPanReset defaultValue:NO];
    BOOL snapToBounds = [self.propertyContainer getBoolPropertyValue:kIXPanSnap defaultValue:YES];
    static CGPoint originalCenter;
    UIView *draggedView = panGestureRecognizer.view;
    CGPoint offset = [panGestureRecognizer translationInView:draggedView.superview];
    CGPoint center = draggedView.center;
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan && !kIXDidDetermineOriginalCenter)
    {
        originalCenter = draggedView.center;
        kIXDidDetermineOriginalCenter = true;
    }
    
    draggedView.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    
    if ((panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
         panGestureRecognizer.state == UIGestureRecognizerStateCancelled))
    {
        if (resetPosition)
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 draggedView.center = originalCenter;
                             }];
        }
        else if (snapToBounds)
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 draggedView.center = [self correctCenterIfOutsideView:draggedView fromOriginalCenter:originalCenter];
                                 //draggedView.center = originalCenter;
                             }];
        }
    }
    
    
    // Reset translation to zero so on the next `panWasRecognized:` message, the
    // translation will just be the additional movement of the touch since now.
    [panGestureRecognizer setTranslation:CGPointZero inView:draggedView.superview];
}

-(CGPoint)correctCenterIfOutsideView:(UIView *)view fromOriginalCenter:(CGPoint)originalCenter
{
    CGFloat newCenterX = view.center.x;
    CGFloat newCenterY = view.center.y;
    
    CGFloat currentLeft = view.frame.origin.x;
    CGFloat currentRight = view.frame.origin.x + view.frame.size.width;
    CGFloat currentTop = view.frame.origin.y;
    CGFloat currentBottom = view.frame.origin.y + view.frame.size.height;
    
    CGFloat originalLeft = originalCenter.x - (view.bounds.size.width / 2);
    CGFloat originalRight = originalCenter.x + (view.bounds.size.width / 2);
    CGFloat originalTop = originalCenter.y - (view.bounds.size.height / 2);
    CGFloat originalBottom = originalCenter.y + (view.bounds.size.height / 2);

    if (currentLeft > originalLeft && currentRight > originalRight)
        newCenterX = newCenterX - currentLeft + originalLeft;
    else if (currentRight < originalRight && currentLeft < originalLeft)
        newCenterX = newCenterX - currentRight + originalRight;
    
    if (currentTop > originalTop && currentBottom > originalBottom)
        newCenterY = newCenterY - currentTop + originalTop;
    else if (currentBottom < originalBottom && currentTop < originalTop)
        newCenterY = newCenterY - currentBottom + originalBottom;
    
    return CGPointMake(newCenterX, newCenterY);
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
            if( ![[baseControl contentView] isHidden]) // previously: && [baseControlView alpha] > 0.0f
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

-(NSString*)getReadOnlyPropertyValue:(NSString*)propertyName
{
    NSString* returnValue = nil;
    if ( [propertyName hasPrefix:kIXLocation] && [[self propertyContainer] hasLayoutProperties] )
    {
        UIView* rootView = [[[[[UIApplication sharedApplication] windows] firstObject] rootViewController] view];
        CGPoint location = [self.contentView convertPoint:self.contentView.frame.origin toView:rootView];
        
        if ( [propertyName isEqualToString:kIXLocationX] )
            returnValue = [NSString stringWithFormat:@"%f", location.x / 2];
        if ( [propertyName isEqualToString:kIXLocationY] )
            returnValue = [NSString stringWithFormat:@"%f", location.y / 2];
        if ( [propertyName isEqualToString:kIXLocation] )
            returnValue = NSStringFromCGPoint(CGPointMake(location.x / 2, location.y / 2));
    }
    return returnValue;
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXToggle] )
    {
        if ([self isContentViewVisible])
        {
            self.contentView.alpha = 0.0f;
            self.contentView.enabled = NO;
        }
        else
        {
            CGFloat originalAlpha = [[self propertyContainer] getFloatPropertyValue:kIXAlpha defaultValue:1.0f];
            if (originalAlpha <= 0)
                originalAlpha = 1;
            self.contentView.alpha = originalAlpha;
            self.contentView.enabled = YES;
        }
    }
    else if ([functionName isEqualToString:kIXStopAnimation])
    {
        [self endAnimation];
    }
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

-(void)beginAnimation:(NSString*)animation duration:(CGFloat)duration repeatCount:(NSInteger)repeatCount params:(NSDictionary*)params
{
    if ([animation isEqualToString:kIXSpin])
    {
        if (!kIXIsAnimating) {
            kIXIsAnimating = YES;
            kIXAnimationCounter = 0;
            [self spinWithOptions: UIViewAnimationOptionCurveLinear duration:duration repeatCount:repeatCount*4 - 1 params:params]; //*4 to = 360º
        }
    }
}

-(void)endAnimation
{
    kIXIsAnimating = NO;
}

// ROTATE/SPIN ANIMATION

- (void)spinWithOptions: (UIViewAnimationOptions) options duration:(CGFloat)duration repeatCount:(NSInteger)repeatCount params:(NSDictionary*)params {

    // Required in order to prevent animation if the object is hidden
    if ([self isContentViewVisible])
    {

        // this spin completes 360 degrees every 1/4 of duration
        NSInteger degrees = 90;
        if ([[params objectForKey:kIXDirection] isEqualToString:kIXReverse])
        {
            degrees = -90;
        }
        
        [UIView animateWithDuration: duration / 4
                              delay: 0.0f
                            options: options
                         animations: ^{
                             self.contentView.transform = CGAffineTransformRotate(self.contentView.transform, DEGREES_TO_RADIANS(degrees));
                         }
                         completion: ^(BOOL finished) {
                             if (finished) {
                                 if (kIXIsAnimating && (kIXAnimationCounter == 0 || kIXAnimationCounter < repeatCount)) {
                                     if (repeatCount > 0)
                                         kIXAnimationCounter++;
                                     // if flag still set, keep spinning with constant speed
                                     [self spinWithOptions: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear duration:duration repeatCount:repeatCount params:params];
                                 } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                     // one last spin, with deceleration
                                     [self spinWithOptions: UIViewAnimationOptionCurveEaseOut duration:duration repeatCount:repeatCount params:params];
                                 }
                             }
                         }];
    }
}

-(void)conserveMemory
{
    for( IXBaseControl* control in [self childObjects] )
    {
        [control conserveMemory];
    }
}

@end
