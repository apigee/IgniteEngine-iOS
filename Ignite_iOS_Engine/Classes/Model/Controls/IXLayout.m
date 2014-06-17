//
//  IXLayoutControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013. All rights reserved.
//

#import "IXLayout.h"
#import "IXClickableScrollView.h"
#import "IXLayoutEngine.h"
#import "IXStructs.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

// IXLayout Attributes
IX_STATIC_CONST_STRING kIXLayoutFlow = @"layout_flow";
IX_STATIC_CONST_STRING kIXVertical = @"vertical";
IX_STATIC_CONST_STRING kIXHorizontal = @"horizontal";
IX_STATIC_CONST_STRING kIXVerticalScrollEnabled = @"vertical_scroll_enabled";
IX_STATIC_CONST_STRING kIXHorizontalScrollEnabled = @"horizontal_scroll_enabled";
IX_STATIC_CONST_STRING kIXEnableScrollsToTop = @"enable_scrolls_to_top";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyle = @"scroll_indicator_style";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyleBlack = @"black";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyleWhite = @"white";
IX_STATIC_CONST_STRING kIXShowsScrollIndicators = @"shows_scroll_indicators";
IX_STATIC_CONST_STRING kIXShowsHorizontalScrollIndicator = @"shows_horizontal_scroll_indicator";
IX_STATIC_CONST_STRING kIXShowsVerticalScrollIndicator = @"shows_vertical_scroll_indicator";
IX_STATIC_CONST_STRING kIXMaxZoomScale = @"max_zoom_scale";
IX_STATIC_CONST_STRING kIXMinZoomScale = @"min_zoom_scale";
IX_STATIC_CONST_STRING kIXEnableZoom = @"enable_zoom";
IX_STATIC_CONST_STRING kIXZoomScale = @"zoom_scale";
IX_STATIC_CONST_STRING kIXColorGradientTop = @"color.gradient_top";
IX_STATIC_CONST_STRING kIXColorGradientBottom = @"color.gradient_bottom";

@interface IXLayout () <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,assign) BOOL zoomEnabled;
@property (nonatomic,assign) BOOL layoutFlowVertical;
@property (nonatomic,assign) BOOL verticalScrollEnabled;
@property (nonatomic,assign) BOOL horizontalScrollEnabled;

@property (nonatomic,strong) CAGradientLayer* gradientLayer;
@property (nonatomic,strong) UITapGestureRecognizer* doubleTapZoomRecognizer;

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
    
    [IXLayoutEngine layoutControl:self inRect:rect];
    
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
    return [IXLayoutEngine getPreferredSizeForLayoutControl:self forSuggestedSize:size];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [self isTopLevelViewControllerLayout] )
    {
        [[[self sandbox] viewController] applyFunction:functionName withParameters:parameterContainer];
    }
    
    [super applyFunction:functionName withParameters:parameterContainer];
}

@end
