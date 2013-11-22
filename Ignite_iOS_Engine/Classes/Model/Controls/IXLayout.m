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


@interface IXLayout () <UIScrollViewDelegate,UIGestureRecognizerDelegate>

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
    
    NSString* layoutFlow = [[self propertyContainer] getStringPropertyValue:@"layout_flow" defaultValue:@"vertical"];
    [self setLayoutFlowVertical:(![layoutFlow isEqualToString:@"horizontal"])];
    
    [self setVerticalScrollEnabled:[[self propertyContainer] getBoolPropertyValue:@"vertical_scroll_enabled" defaultValue:YES]];
    [self setVerticalScrollEnabled:[[self propertyContainer] getBoolPropertyValue:@"horizontal_scroll_enabled" defaultValue:YES]];
    [[self scrollView] setScrollsToTop:[[self propertyContainer] getBoolPropertyValue:@"enable_scrolls_to_top" defaultValue:NO]];

    NSString* scrollIndicatorStyle = [[self propertyContainer] getStringPropertyValue:@"scroll_indicator_style" defaultValue:@"default"];
    if( [scrollIndicatorStyle isEqualToString:@"black"] ) {
        [[self scrollView] setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    } else if( [scrollIndicatorStyle isEqualToString:@"white"] ) {
        [[self scrollView] setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    } else {
        [[self scrollView] setIndicatorStyle:UIScrollViewIndicatorStyleDefault];
    }
    
    BOOL showScrollIndicators = [[self propertyContainer] getBoolPropertyValue:@"shows_scroll_indicators" defaultValue:YES];
    [[self scrollView] setShowsHorizontalScrollIndicator:[[self propertyContainer] getBoolPropertyValue:@"shows_horizontal_scroll_indicator" defaultValue:showScrollIndicators]];
    [[self scrollView] setShowsVerticalScrollIndicator:[[self propertyContainer] getBoolPropertyValue:@"shows_vertical_scroll_indicator" defaultValue:showScrollIndicators]];
    
    [[self scrollView] setMaximumZoomScale:[[self propertyContainer] getFloatPropertyValue:@"max_zoom_scale" defaultValue:2.0f]];
    [[self scrollView] setMinimumZoomScale:[[self propertyContainer] getFloatPropertyValue:@"min_zoom_scale" defaultValue:0.5f]];
    [self setZoomEnabled:[[self propertyContainer] getBoolPropertyValue:@"enable_zoom" defaultValue:NO]];
    if( [self isZoomEnabled] )
    {
        [[self scrollView] setZoomScale:[[self propertyContainer] getFloatPropertyValue:@"zoom_scale" defaultValue:1.0f]];
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
        [[self scrollView] setZoomScale:1.0f animated:YES];
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
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    UIColor* topUIColor = [[self propertyContainer] getColorPropertyValue:@"color.gradient_top" defaultValue:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6]];
    //CGColorRef topColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6] CGColor];
    UIColor* bottomUIColor = [[self propertyContainer] getColorPropertyValue:@"color.gradient_bottom" defaultValue:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.6]];
    //CGColorRef bottomColor = [[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.6] CGColor];
    
    CGColorRef topColor = [topUIColor CGColor];
    CGColorRef bottomColor = [bottomUIColor CGColor];
    
    BOOL showGradient = [[self propertyContainer] propertyExistsForPropertyNamed:@"color.gradient_top"];
    
    NSLog(showGradient ? @"Is the gradient visible? Yes" : @"Is the gradient visible? No");
    
    if (showGradient)
    {
        CGRect gradientFrame = self.scrollView.bounds;
        gradientFrame.size.width = rect.size.width;
        gradientFrame.size.height = rect.size.height;
        gradient.frame = gradientFrame;
        gradient.colors = [NSArray arrayWithObjects: (id)CFBridgingRelease(topColor), (id)CFBridgingRelease(bottomColor), nil];
        
        [_scrollView.layer insertSublayer:gradient atIndex:0];
    }
    
    
    
    
    [IXLayoutEngine layoutControl:self inRect:rect];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [IXLayoutEngine getPreferredSizeForLayoutControl:self forSuggestedSize:size];
}

@end
