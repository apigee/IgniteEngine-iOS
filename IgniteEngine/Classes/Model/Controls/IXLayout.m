//
//  IXLayoutControl.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013. All rights reserved.
//

#import "IXLayout.h"
#import "IXClickableScrollView.h"
#import "IXStructs.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "IgniteEngine-Swift.h"

// IXLayout Attributes
IX_STATIC_CONST_STRING kIXLayoutFlow = @"layoutFlow";
IX_STATIC_CONST_STRING kIXVertical = @"vertical";
IX_STATIC_CONST_STRING kIXHorizontal = @"horizontal";
IX_STATIC_CONST_STRING kIXVerticalScrollEnabled = @"scrolling.v.enabled";
IX_STATIC_CONST_STRING kIXHorizontalScrollEnabled = @"scrolling.h.enabled";
IX_STATIC_CONST_STRING kIXEnableScrollsToTop = @"scrollTop.enabled";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyle = @"scrollBars.style";
IX_STATIC_CONST_STRING kIXBlurBackground = @"bg.blur";

IX_STATIC_CONST_STRING kIXBlurBackgroundStyleExtraLight = @"xlight";
IX_STATIC_CONST_STRING kIXBlurBackgroundStyleLight = @"light";
IX_STATIC_CONST_STRING kIXBlurBackgroundStyleDark = @"dark";
IX_STATIC_CONST_STRING kIXBlurTintColor = @"bg.blur.tint";
IX_STATIC_CONST_STRING kIXBlurTintAlpha = @"bg.blur.alpha";


IX_STATIC_CONST_STRING kIXScrollIndicatorStyleBlack = @"black";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyleWhite = @"white";
IX_STATIC_CONST_STRING kIXShowsScrollIndicators = @"scrollBars.enabled";
IX_STATIC_CONST_STRING kIXShowsHorizontalScrollIndicator = @"scrollBars.h.enabled";
IX_STATIC_CONST_STRING kIXShowsVerticalScrollIndicator = @"scrollBars.v.enabled";
IX_STATIC_CONST_STRING kIXMaxZoomScale = @"zoomScale.max";
IX_STATIC_CONST_STRING kIXMinZoomScale = @"zoomScale.min";
IX_STATIC_CONST_STRING kIXEnableZoom = @"zoom.enabled";
IX_STATIC_CONST_STRING kIXZoomScale = @"zoomScale";
IX_STATIC_CONST_STRING kIXColorGradientTop = @"gradient.top";
IX_STATIC_CONST_STRING kIXColorGradientBottom = @"gradient.bottom";

IX_STATIC_CONST_STRING kIXStartedScrolling = @"didBeginScrolling";
IX_STATIC_CONST_STRING kIXEndedScrolling = @"didEndScrolling";

@interface IXLayout () <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,assign) BOOL zoomEnabled;
@property (nonatomic,assign) BOOL layoutFlowVertical;
@property (nonatomic,assign) BOOL verticalScrollEnabled;
@property (nonatomic,assign) BOOL horizontalScrollEnabled;

@property (nonatomic,strong) CAGradientLayer* gradientLayer;
@property (nonatomic,strong) UITapGestureRecognizer* doubleTapZoomRecognizer;
@property (nonatomic,strong) UIView* overlayView;
@property (nonatomic,strong) UIView* visualEffectView;

-(void)doubleTapZoomRecognized:(id)sender;

@end

@implementation IXLayout

-(void)dealloc
{
    [_scrollView setDelegate:nil];
}

-(void)buildView
{
    [super buildView];
    
    _zoomEnabled = NO;
    _layoutFlowVertical = YES;
    _verticalScrollEnabled = YES;
    _horizontalScrollEnabled = YES;
    _topLevelViewControllerLayout = NO;
    _gradientLayer = [CAGradientLayer layer];
    
    _scrollView = [[IXClickableScrollView alloc] initWithFrame:CGRectZero];
    [_scrollView setDelegate:self];
    [_scrollView setParentControl:self];
    [_scrollView setOpaque:YES];
    [_scrollView setClipsToBounds:YES];
    [_scrollView setScrollsToTop:NO];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeNone];
    
    _scrollViewContentView = [[UIView alloc] initWithFrame:CGRectZero];
    [_scrollViewContentView setOpaque:YES];
    [_scrollViewContentView setClipsToBounds:YES];
    [_scrollViewContentView setBackgroundColor:[UIColor clearColor]];
    
    [_scrollView addSubview:_scrollViewContentView];
    
    [[self contentView] addSubview:_scrollView];
}

-(void)applySettings
{
    [super applySettings];
    
    NSString* layoutFlow = [[self propertyContainer] getStringPropertyValue:kIXLayoutFlow defaultValue:kIXVertical];
    [self setLayoutFlowVertical:(![layoutFlow isEqualToString:kIXHorizontal])];
    
    [self setVerticalScrollEnabled:[[self propertyContainer] getBoolPropertyValue:kIXVerticalScrollEnabled defaultValue:YES]];
    [self setHorizontalScrollEnabled:[[self propertyContainer] getBoolPropertyValue:kIXHorizontalScrollEnabled defaultValue:YES]];
    [[self scrollView] setScrollsToTop:[[self propertyContainer] getBoolPropertyValue:kIXEnableScrollsToTop defaultValue:NO]];
    
    NSString* scrollIndicatorStyle = [[self propertyContainer] getStringPropertyValue:kIXScrollIndicatorStyle defaultValue:kIX_DEFAULT];
    if( [scrollIndicatorStyle isEqualToString:kIXScrollIndicatorStyleBlack] ) {
        [[self scrollView] setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    } else if( [scrollIndicatorStyle isEqualToString:kIXScrollIndicatorStyleWhite] ) {
        [[self scrollView] setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    } else {
        [[self scrollView] setIndicatorStyle:UIScrollViewIndicatorStyleDefault];
    }
    
    BOOL showScrollIndicators = [[self propertyContainer] getBoolPropertyValue:kIXShowsScrollIndicators defaultValue:YES];
    [[self scrollView] setShowsHorizontalScrollIndicator:[[self propertyContainer] getBoolPropertyValue:kIXShowsHorizontalScrollIndicator defaultValue:showScrollIndicators]];
    [[self scrollView] setShowsVerticalScrollIndicator:[[self propertyContainer] getBoolPropertyValue:kIXShowsVerticalScrollIndicator defaultValue:showScrollIndicators]];
    
    [self setZoomEnabled:[[self propertyContainer] getBoolPropertyValue:kIXEnableZoom defaultValue:NO]];
    if( [self isZoomEnabled] )
    {
        [[self scrollView] setZoomScale:[[self propertyContainer] getFloatPropertyValue:kIXZoomScale defaultValue:1.0f]];
        [[self scrollView] setMaximumZoomScale:[[self propertyContainer] getFloatPropertyValue:kIXMaxZoomScale defaultValue:2.0f]];
        [[self scrollView] setMinimumZoomScale:[[self propertyContainer] getFloatPropertyValue:kIXMinZoomScale defaultValue:0.5f]];
        if( [self doubleTapZoomRecognizer] == nil )
        {
            UITapGestureRecognizer* doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:[self contentView]
                                                                                                  action:@selector(doubleTapZoomRecognized:)];
            [doubleTapRecognizer setNumberOfTapsRequired:2];
            [[self contentView] addGestureRecognizer:doubleTapRecognizer];
            [self setDoubleTapZoomRecognizer:doubleTapRecognizer];
        }
    }
    else
    {
        if( [self doubleTapZoomRecognizer] != nil )
        {
            [[self contentView] removeGestureRecognizer:[self doubleTapZoomRecognizer]];
            [self setDoubleTapZoomRecognizer:nil];
        }
        [[self scrollView] setMinimumZoomScale:1.0f];
        [[self scrollView] setMaximumZoomScale:1.0f];
        [[self scrollView] setZoomScale:1.0f animated:YES];
    }
    
    if( [[self propertyContainer] propertyExistsForPropertyNamed:kIXColorGradientTop] )
    {
        UIColor* topUIColor = [[self propertyContainer] getColorPropertyValue:kIXColorGradientTop defaultValue:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6]];
        UIColor* bottomUIColor = [[self propertyContainer] getColorPropertyValue:kIXColorGradientBottom defaultValue:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.6]];
        [[self gradientLayer] setColors:[NSArray arrayWithObjects:(id)CFBridgingRelease([topUIColor CGColor]), (id)CFBridgingRelease([bottomUIColor CGColor]), nil]];
    }
}

-(void)doubleTapZoomRecognized:(id)sender
{
    if( [self isZoomEnabled] )
    {
        CGFloat zoomScale = 1.0f;
        if( [[self scrollView] zoomScale] == 1.0f )
        {
            zoomScale = [[self scrollView] maximumZoomScale];
        }
        [[self scrollView] setZoomScale:zoomScale animated:YES];
    }
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [super layoutControlContentsInRect:rect];
    
    [LayoutEngine layout:self layoutRect:rect];
    
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
    [self.visualEffectView removeFromSuperview];
    self.visualEffectView = nil;
    
    if( [[self propertyContainer] propertyExistsForPropertyNamed:kIXBlurBackground] )
    {
        NSString* blurStyle = [[self propertyContainer] getStringPropertyValue:kIXBlurBackground defaultValue:kIX_DEFAULT];
        
        UIBlurEffect *blurEffect;
        
        if( [blurStyle isEqualToString:kIXBlurBackgroundStyleExtraLight] ) {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        } else if( [blurStyle isEqualToString:kIXBlurBackgroundStyleLight] ) {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        } else {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        }
        
        //Header blur
        [self setVisualEffectView:[[UIVisualEffectView alloc] initWithEffect:blurEffect]];
        self.visualEffectView.frame = _scrollViewContentView.bounds;
        
        [self setOverlayView:[[UIView alloc] initWithFrame:_scrollViewContentView.bounds]];
        self.overlayView.alpha = [[self propertyContainer] getFloatPropertyValue:kIXBlurTintAlpha defaultValue:0.0f];
        self.overlayView.backgroundColor = [[self propertyContainer] getColorPropertyValue:kIXBlurTintColor defaultValue:[UIColor clearColor]];
        
        [_scrollViewContentView insertSubview:[self overlayView] atIndex:0];
        [_scrollViewContentView insertSubview:[self visualEffectView] atIndex:0];
    }
    
    if( [[self propertyContainer] propertyExistsForPropertyNamed:kIXColorGradientTop] )
    {
        if( [[self gradientLayer] superlayer] != [[self scrollView] layer] )
        {
            [[self gradientLayer] removeFromSuperlayer];
            [[[self scrollView] layer] insertSublayer:[self gradientLayer] atIndex:0];
        }
        
        CGRect gradientFrame = [[self scrollView] bounds];
        gradientFrame.size = CGSizeMake(rect.size.width, rect.size.height);
        [[self gradientLayer] setFrame:gradientFrame];
    }
    else
    {
        [[self gradientLayer] removeFromSuperlayer];
    }
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [LayoutEngine getPreferredSize:self suggestedSize:size];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [self isTopLevelViewControllerLayout] )
    {
        [[[self sandbox] viewController] applyFunction:functionName withParameters:parameterContainer];
    }
    
    [super applyFunction:functionName withParameters:parameterContainer];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[self actionContainer] executeActionsForEventNamed:kIXStartedScrolling];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[self actionContainer] executeActionsForEventNamed:kIXEndedScrolling];
}

@end