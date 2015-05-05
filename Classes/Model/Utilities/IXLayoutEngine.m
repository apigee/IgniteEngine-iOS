//
//  IXLayoutEngine.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/21/13.
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

#import "IXLayoutEngine.h"

#import "IXLayout.h"
#import "IXControlLayoutInfo.h"
#import "IXClickableScrollView.h"

@interface IXLayoutEngine ()

+(void)addLayoutChildrenToViewHeirarchy:(IXLayout*)layoutControl;

+(CGFloat)calculateEqualWidthForUnclaimedControls:(IXLayout*)layoutControl
                                        forWidth:(CGFloat)totalWidthAvailable;

+(CGPoint)getControlPosition:(IXBaseControl*)control
              forControlSize:(CGSize)controlSize
              forLayoutRect:(CGRect)layoutRect;

+(CGSize)getControlSize:(IXBaseControl*)control
         forLayoutSize:(CGSize)layoutSize;

+(CGSize)calculateRemainingSizeForControlLayoutInfo:(IXControlLayoutInfo*)controlLayoutInfo
                                           forRect:(CGRect)rect controlSize:(CGSize)controlSize
                                    controlPosition:(CGPoint)controlPositiong;

+(IXFrameAndOffset)getControlFrame:(IXBaseControl*)control
                   forLayoutControl:(IXLayout*)layoutControl
                     forLayoutRect:(CGRect)layoutRect
                     currentOffset:(CGFloat)currentOffset
             fixOffsetToLayoutRect:(BOOL)fixOffsetToLayoutRect
             allowOffAxisAlignment:(BOOL)allowOffAxisAlignment;

@end

@implementation IXLayoutEngine

+(CGFloat)calculateEqualWidthForUnclaimedControls:(IXLayout*)layoutControl forWidth:(CGFloat)totalWidthAvailable
{
    CGFloat equalWidthForRemainingUnclaimedControls = 0.0f;
    
    CGFloat unclaimedWidth = totalWidthAvailable;
    int totalUnclaimedControls = 0;
    for( IXBaseControl* control in [layoutControl childObjects] )
    {
        IXControlLayoutInfo* controlLayoutInfo = [control layoutInfo];
        if( [control contentView] == nil || [controlLayoutInfo isHidden] || [controlLayoutInfo isAbsolutePositioned] )
        {
            continue;
        }
        unclaimedWidth -= ixEvaluateSizeValuePercentageForMaxValue([controlLayoutInfo width], totalWidthAvailable);
        
        if( ![controlLayoutInfo widthWasDefined] )
        {
            totalUnclaimedControls++;
        }
    }
    
    if( totalUnclaimedControls > 0 )
        equalWidthForRemainingUnclaimedControls = fmaxf(0.0f,unclaimedWidth/totalUnclaimedControls);
    
    return equalWidthForRemainingUnclaimedControls;
}

+(CGPoint)getControlPosition:(IXBaseControl*)control forControlSize:(CGSize)controlSize forLayoutRect:(CGRect)layoutRect
{
    CGPoint returnPosition = CGPointZero;
    
    IXControlLayoutInfo* controlLayoutInfo = [control layoutInfo];
    
    UIEdgeInsets controlMarginInsets = ixEvaluateEdgeInsets(controlLayoutInfo.marginInsets, layoutRect.size);
    
    if( [controlLayoutInfo leftPositionWasDefined] && [controlLayoutInfo isAbsolutePositioned] )
    {
        returnPosition.x = ixEvaluateSizeValuePercentageForMaxValue([controlLayoutInfo leftPosition], layoutRect.size.width);
    }
    else
    {
        switch ( [controlLayoutInfo horizontalAlignment] )
        {
            case IXLayoutHorizontalAlignmentCenter:
            {
                returnPosition.x = (layoutRect.size.width - controlSize.width) * 0.5f;
                break;
            }
            case IXLayoutHorizontalAlignmentLeft:
            {
                returnPosition.x = layoutRect.size.width - controlSize.width - controlMarginInsets.right;
                break;
            }
            case IXLayoutHorizontalAlignmentRight:
            default:
            {
                returnPosition.x = controlMarginInsets.left;
                break;
            }
        }
    }
    
    if( [controlLayoutInfo topPositionWasDefined] && [controlLayoutInfo isAbsolutePositioned ] )
    {
        returnPosition.y = ixEvaluateSizeValuePercentageForMaxValue([controlLayoutInfo topPosition], layoutRect.size.height);
    }
    else
    {
        switch ( [controlLayoutInfo verticalAlignment] )
        {
            case IXLayoutVerticalAlignmentMiddle:
            {
                returnPosition.y = (layoutRect.size.height - controlSize.height) * 0.5f;
                break;
            }
            case IXLayoutVerticalAlignmentBottom:
            {
                returnPosition.y = layoutRect.size.height - controlSize.height - controlMarginInsets.bottom;
                break;
            }
            case IXLayoutVerticalAlignmentTop:
            default:
            {
                returnPosition.y = controlMarginInsets.top;
                break;
            }
        }
    }
    
    returnPosition.x += layoutRect.origin.x;
    returnPosition.y += layoutRect.origin.y;
    returnPosition.x = round(returnPosition.x);
    returnPosition.y = round(returnPosition.y);
    
    return returnPosition;
}

+(CGSize)getControlSize:(IXBaseControl*)control forLayoutSize:(CGSize)layoutSize
{
    CGSize returnSize = CGSizeZero;
 
    IXControlLayoutInfo* controlLayoutInfo = [control layoutInfo];
    
    BOOL heightWasDefined = [controlLayoutInfo heightWasDefined];
    BOOL widthWasDefined = [controlLayoutInfo widthWasDefined];
    
    if( heightWasDefined && widthWasDefined )
    {
        // If both height and width were defined then just set the returnSize to the calculated sizes.
        returnSize.width = ixEvaluateSizeValuePercentageForMaxValue([controlLayoutInfo width], layoutSize.width);
        returnSize.height = ixEvaluateSizeValuePercentageForMaxValue([controlLayoutInfo height], layoutSize.height);
    }
    else if( ![controlLayoutInfo isHidden ] )
    {
        if( widthWasDefined )
        {
            layoutSize.width = ixEvaluateSizeValuePercentageForMaxValue([controlLayoutInfo width], layoutSize.width);
        }
        if( heightWasDefined )
        {
            layoutSize.height = ixEvaluateSizeValuePercentageForMaxValue([controlLayoutInfo height], layoutSize.height);
        }
        
        returnSize = layoutSize;
        
        if( !widthWasDefined || !heightWasDefined )
        {
            UIEdgeInsets controlPaddingInsets = ixEvaluateEdgeInsets(controlLayoutInfo.paddingInsets, layoutSize);
            
            CGSize internalSize = CGSizeMake( fmaxf(0.0f,layoutSize.width - controlPaddingInsets.left - controlPaddingInsets.right),
                                              fmaxf(0.0f,layoutSize.height - controlPaddingInsets.top - controlPaddingInsets.bottom));
            
            CGSize preferredSize = [control preferredSizeForSuggestedSize:internalSize];
            
            if( !widthWasDefined )
            {
                returnSize.width = preferredSize.width + controlPaddingInsets.left + controlPaddingInsets.right;
            }
            if( !heightWasDefined )
            {
                returnSize.height = preferredSize.height + controlPaddingInsets.top + controlPaddingInsets.bottom;
            }
        }
    }
    return returnSize;
}

+(CGSize)calculateRemainingSizeForControlLayoutInfo:(IXControlLayoutInfo*)controlLayoutInfo forRect:(CGRect)rect controlSize:(CGSize)controlSize controlPosition:(CGPoint)controlPositiong
{
    CGSize returnSize = controlSize;
    if( [controlLayoutInfo fillRemainingWidth] )
    {
        float remainingWidth = rect.size.width - controlPositiong.x + rect.origin.x;
        if( remainingWidth > 0.0f )
        {
            returnSize.width = remainingWidth;
        }
    }
    if( [controlLayoutInfo fillRemainingHeight] )
    {
        float remainingHeight = rect.size.height - controlPositiong.y + rect.origin.y;
        if( remainingHeight > 0.0f )
        {
            returnSize.height = remainingHeight;
        }
    }
    return returnSize;
}

+(CGRect)getInternalLayoutRectForControl:(IXBaseControl*)control forOuterLayoutRect:(CGRect)outerLayoutRect
{
    CGRect returnRect = outerLayoutRect;
    
    UIEdgeInsets controlPaddingInsets = ixEvaluateEdgeInsets([[control layoutInfo] paddingInsets], returnRect.size);
    
    returnRect.origin.x = controlPaddingInsets.left;
    returnRect.origin.y = controlPaddingInsets.top;
    returnRect.size.width -= controlPaddingInsets.left + controlPaddingInsets.right;
    returnRect.size.height -= controlPaddingInsets.top + controlPaddingInsets.bottom;
    
    return returnRect;
}

+(IXFrameAndOffset)getControlFrame:(IXBaseControl*)control forLayoutControl:(IXLayout*)layoutControl forLayoutRect:(CGRect)layoutRect currentOffset:(CGFloat)currentOffset fixOffsetToLayoutRect:(BOOL)fixOffsetToLayoutRect allowOffAxisAlignment:(BOOL)allowOffAxisAlignment
{
    IXControlLayoutInfo* controlLayoutInfo = [control layoutInfo];
    
    UIEdgeInsets controlMarginInsets = ixEvaluateEdgeInsets(controlLayoutInfo.marginInsets, layoutRect.size);
    
    IXSizeAndPosition sizeAndPosition = IXSizeAndPositionZero;
    
    if( [layoutControl isLayoutFlowVertical] || [controlLayoutInfo isAbsolutePositioned] )
    {
        CGRect verticalLayoutRect = layoutRect;
        verticalLayoutRect.origin.y += currentOffset;
        
        sizeAndPosition.size = [IXLayoutEngine getControlSize:control
                                                forLayoutSize:verticalLayoutRect.size];
        
        if( ![controlLayoutInfo isAbsolutePositioned] )
        {
            if( !allowOffAxisAlignment )
            {
                verticalLayoutRect.size.width = sizeAndPosition.size.width;
            }
            if( !fixOffsetToLayoutRect )
            {
                verticalLayoutRect.size.height = sizeAndPosition.size.height;
            }
        }
        
        sizeAndPosition.position = [IXLayoutEngine getControlPosition:control
                                                        forControlSize:sizeAndPosition.size
                                                        forLayoutRect:verticalLayoutRect];
        
        sizeAndPosition.size = [IXLayoutEngine calculateRemainingSizeForControlLayoutInfo:controlLayoutInfo
                                                                                  forRect:layoutRect
                                                                               controlSize:sizeAndPosition.size
                                                                           controlPosition:sizeAndPosition.position];
        
        // Add margins to the current offset.
        currentOffset += controlMarginInsets.top + controlMarginInsets.bottom;
        
        // If fix offset add the max between the layoutRects height and the controlSize height if not use the controlSize height.
        currentOffset += ( fixOffsetToLayoutRect ) ? fmaxf(layoutRect.size.height, sizeAndPosition.size.height) : sizeAndPosition.size.height;
    }
    else
    {
        CGRect horizontalLayoutRect = layoutRect;
        horizontalLayoutRect.origin.x += currentOffset;
        
        if( !fixOffsetToLayoutRect && ![controlLayoutInfo widthWasDefined] )
        {
            horizontalLayoutRect.size.width = CGFLOAT_MAX;
        }
        
        sizeAndPosition.size = [IXLayoutEngine getControlSize:control
                                                forLayoutSize:horizontalLayoutRect.size];
        
        if( !fixOffsetToLayoutRect )
        {
            horizontalLayoutRect.size.width = sizeAndPosition.size.width;
        }
        if( !allowOffAxisAlignment )
        {
            horizontalLayoutRect.size.height = sizeAndPosition.size.height;
        }
        
        if( sizeAndPosition.size.width >= CGFLOAT_MAX )
        {
            sizeAndPosition.size.width = layoutRect.size.width;
            horizontalLayoutRect.size.width = layoutRect.size.width;
        }
        
        sizeAndPosition.position = [IXLayoutEngine getControlPosition:control
                                                        forControlSize:sizeAndPosition.size
                                                        forLayoutRect:horizontalLayoutRect];
        
        sizeAndPosition.size = [IXLayoutEngine calculateRemainingSizeForControlLayoutInfo:controlLayoutInfo
                                                                                  forRect:layoutRect
                                                                               controlSize:sizeAndPosition.size
                                                                           controlPosition:sizeAndPosition.position];
        
        // Add margins to the current offset.
        currentOffset += controlMarginInsets.left + controlMarginInsets.right;
        
        // If fix offset add the max between the layoutRects width and the controlSize width if not use the controlSize width.
        currentOffset += ( fixOffsetToLayoutRect ) ? fmaxf(layoutRect.size.width, sizeAndPosition.size.width) : sizeAndPosition.size.width;
    }
    
    IXFrameAndOffset returnFrameAndOffset = IXFrameAndOffsetZero;
    returnFrameAndOffset.frame = CGRectMake(round(sizeAndPosition.position.x),
                                            round(sizeAndPosition.position.y),
                                            round(sizeAndPosition.size.width),
                                            round(sizeAndPosition.size.height));
    
    returnFrameAndOffset.offset = currentOffset;
    return returnFrameAndOffset;
}

+(void)addLayoutChildrenToViewHeirarchy:(IXLayout*)layoutControl
{
    int nonFloatIndex = 0;
    int floatIndex = 1; // Float index starts at 1 to account for scrollView inside of the layoutControl
    
    for( IXBaseControl* control in [layoutControl childObjects] )
    {
        if( [control contentView] == nil )
        {
            continue;
        }
        
        IXControlLayoutInfo* controlLayoutInfo = [control layoutInfo];
        if( [controlLayoutInfo isFloatPositioned] )
        {
            if( [[control contentView] superview] != [layoutControl contentView] )
            {
                [[layoutControl contentView] insertSubview:[control contentView] atIndex:floatIndex];
            }
            floatIndex++;
        }
        else
        {
            if( [[control contentView] superview] != [layoutControl scrollViewContentView] )
            {
                [[layoutControl scrollViewContentView] insertSubview:[control contentView] atIndex:nonFloatIndex];
            }
            nonFloatIndex++;
        }
    }
}

+(void)layoutControl:(IXLayout*)layoutControl inRect:(CGRect)layoutRect
{
    [IXLayoutEngine addLayoutChildrenToViewHeirarchy:layoutControl];
    
    UIControl* layoutsView = [layoutControl contentView];
    UIScrollView* layoutScrollView = [layoutControl scrollView];
    
    [layoutScrollView setFrame:[layoutsView bounds]];
    
    CGRect absoluteLayoutRect = [layoutScrollView frame];
    CGRect relativeLayoutRect = layoutRect;
    
    CGFloat equalWidthForRemainingUnclaimedControls = 0.0f;
    
    BOOL processEqualHorizontalLayout = (![layoutControl isLayoutFlowVertical] && [[layoutControl layoutInfo] widthWasDefined] );
    if( processEqualHorizontalLayout )
    {
        equalWidthForRemainingUnclaimedControls = [IXLayoutEngine calculateEqualWidthForUnclaimedControls:layoutControl
                                                                                                forWidth:relativeLayoutRect.size.width];
    }
    
    CGPoint maxPoint = CGPointZero;
    CGFloat currentOffset = 0.0f;
    BOOL addXPaddingToScroll = YES;
    BOOL addYPaddingToScroll = YES;
    
    for( IXBaseControl* control in [layoutControl childObjects] )
    {
        IXControlLayoutInfo* controlLayoutInfo = [control layoutInfo];
        if( [control contentView] == nil || [controlLayoutInfo isHidden] )
            continue;
        
        CGRect layoutRectToCalculateControlFrame = absoluteLayoutRect;
        BOOL controlIsAbsolutePositioned = [controlLayoutInfo isAbsolutePositioned];
        BOOL fixOffsetToLayoutRect = NO;

        if( !controlIsAbsolutePositioned )
        {
            layoutRectToCalculateControlFrame = relativeLayoutRect;
            fixOffsetToLayoutRect = (processEqualHorizontalLayout && ![controlLayoutInfo widthWasDefined]);
            if( fixOffsetToLayoutRect )
            {
                layoutRectToCalculateControlFrame.size.width = equalWidthForRemainingUnclaimedControls;
            }
        }
        
        IXFrameAndOffset frameAndOffset = [IXLayoutEngine getControlFrame:control
                                                         forLayoutControl:layoutControl
                                                            forLayoutRect:layoutRectToCalculateControlFrame
                                                            currentOffset:(controlIsAbsolutePositioned) ? 0.0f : currentOffset
                                                    fixOffsetToLayoutRect:fixOffsetToLayoutRect
                                            allowOffAxisAlignment:YES];
        
        [controlLayoutInfo setLayoutRect:frameAndOffset.frame];
        if( !controlIsAbsolutePositioned )
        {
            currentOffset = frameAndOffset.offset;
        }
        
        if( [controlLayoutInfo canPushParentsBounds] )
        {
            float controlsMaxX = CGRectGetMaxX([controlLayoutInfo layoutRect]);
            float controlsMaxY = CGRectGetMaxY([controlLayoutInfo layoutRect]);
            
            if( controlsMaxX > maxPoint.x )
            {
                if( controlIsAbsolutePositioned ) {
                    addXPaddingToScroll = NO;
                } else if( ![controlLayoutInfo isFloatPositioned] ) {
                    addXPaddingToScroll = YES;
                }
                maxPoint.x = controlsMaxX;
            }
            if( controlsMaxY > maxPoint.y )
            {
                if( controlIsAbsolutePositioned ) {
                    addYPaddingToScroll = NO;
                } else if( ![controlLayoutInfo isFloatPositioned] ) {
                    addYPaddingToScroll = YES;
                }
                maxPoint.y = controlsMaxY;
            }
        }
        
//        if( [controlLayoutInfo layoutRect].size.width == 0.0f || [controlLayoutInfo layoutRect].size.height == 0.0f )
//        {
//            // If either the width or height of the controls frame is 0 we can just set it to be hidden.
//            [[control contentView] setHidden:YES];
//        }
//        else
//        {
            [[control contentView] setHidden:[controlLayoutInfo isHidden]];
//        }
        
        [[control contentView] setFrame:[controlLayoutInfo layoutRect]];
        
        if( [[control contentView] isHidden] || CGSizeEqualToSize([controlLayoutInfo layoutRect].size,CGSizeZero) )
        {
            continue;
        }
        
        CGRect internalControlRect = [IXLayoutEngine getInternalLayoutRectForControl:control
                                                                 forOuterLayoutRect:[[control contentView] bounds]];
        
        [control layoutControlContentsInRect:CGRectIntegral(internalControlRect)];
    }
    
    UIEdgeInsets layoutControlPaddingInsets = ixEvaluateEdgeInsets([[layoutControl layoutInfo] paddingInsets], layoutsView.bounds.size);
    
    CGSize contentSize = [layoutsView bounds].size;
    
    if( [layoutControl isVerticalScrollEnabled] )
    {
        contentSize.height = maxPoint.y;
        
        if( addYPaddingToScroll && contentSize.height > [layoutScrollView bounds].size.height )
        {
            contentSize.height += layoutControlPaddingInsets.bottom;
        }
    }
    
    if( [layoutControl isHorizontalScrollEnabled] )
    {
        contentSize.width = maxPoint.x;
        
        if( addXPaddingToScroll && contentSize.width > [layoutScrollView bounds].size.width )
        {
            contentSize.width += layoutControlPaddingInsets.right;
        }
    }
    
    CGFloat layoutScrollViewZoomScale = layoutScrollView.zoomScale;
    float scrollViewContentViewWidth = fmaxf(layoutsView.bounds.size.width * layoutScrollViewZoomScale,
                                            contentSize.width * layoutScrollViewZoomScale);
    
    float scrollViewContentViewHeight = fmaxf(layoutsView.bounds.size.height * layoutScrollViewZoomScale,
                                             contentSize.height * layoutScrollViewZoomScale);

    CGRect scrollViewContentViewRect = CGRectMake(0.0f, 0.0f, scrollViewContentViewWidth, scrollViewContentViewHeight);
    [[layoutControl scrollViewContentView] setFrame:scrollViewContentViewRect];
    [layoutScrollView setContentSize:scrollViewContentViewRect.size];
    
    BOOL contentSizeIsLargerThanBounds = (layoutScrollView.contentSize.width > layoutScrollView.bounds.size.width) ||
                                         (layoutScrollView.contentSize.height > layoutScrollView.bounds.size.height);
    
    if( [layoutControl isZoomEnabled] || contentSizeIsLargerThanBounds )
    {
        [layoutScrollView setScrollEnabled:YES];
    }
    else
    {
        [layoutScrollView setScrollEnabled:NO];
    }
}

+(CGSize)getPreferredSizeForLayoutControl:(IXLayout*)layoutControl forSuggestedSize:(CGSize)suggestedSize
{
    CGSize returnSize = CGSizeZero;

    IXControlLayoutInfo* layoutControlsLayoutInfo = [layoutControl layoutInfo];
    
    UIEdgeInsets layoutControlPaddingInsets = ixEvaluateEdgeInsets([layoutControlsLayoutInfo paddingInsets], suggestedSize);
    
    if( [layoutControlsLayoutInfo widthWasDefined] )
    {
        returnSize.width = ixEvaluateSizeValuePercentageForMaxValue([layoutControlsLayoutInfo width], suggestedSize.width);
    }
    if( [layoutControlsLayoutInfo heightWasDefined] )
    {
        returnSize.height = ixEvaluateSizeValuePercentageForMaxValue([layoutControlsLayoutInfo height], suggestedSize.height);
    }
    
    CGRect absoluteLayoutRect = CGRectZero;
    absoluteLayoutRect.size = suggestedSize;
    
    CGRect relativeLayoutRect = CGRectZero;
    relativeLayoutRect.size = CGSizeMake(returnSize.width + layoutControlPaddingInsets.left + layoutControlPaddingInsets.right,
                                         returnSize.height + layoutControlPaddingInsets.top + layoutControlPaddingInsets.bottom);
    
    CGFloat equalWidthForRemainingUnclaimedControls = 0.0f;
    BOOL processEqualHorizontalLayout = (![layoutControl isLayoutFlowVertical] && [[layoutControl layoutInfo] widthWasDefined] );
    if( processEqualHorizontalLayout )
    {
        equalWidthForRemainingUnclaimedControls = [IXLayoutEngine calculateEqualWidthForUnclaimedControls:layoutControl
                                                                                                forWidth:relativeLayoutRect.size.width];
    }
    
    CGFloat currentOffset = 0.0f;
    
    for( IXBaseControl* control in [layoutControl childObjects] )
    {
        IXControlLayoutInfo* controlLayoutInfo = [control layoutInfo];
        
        if( [control contentView] == nil || [controlLayoutInfo isHidden] )
            continue;
        
        CGRect layoutRectToCalculateControlFrame = absoluteLayoutRect;
        BOOL fixOffsetToLayoutRect = NO;
        
        BOOL controlIsAbsolutePositioned = [controlLayoutInfo isAbsolutePositioned];
        if( !controlIsAbsolutePositioned )
        {
            layoutRectToCalculateControlFrame = relativeLayoutRect;
            fixOffsetToLayoutRect = ( processEqualHorizontalLayout && ![controlLayoutInfo widthWasDefined] );
            if( fixOffsetToLayoutRect )
            {
                layoutRectToCalculateControlFrame.size.width = equalWidthForRemainingUnclaimedControls;
            }
        }
        
        IXFrameAndOffset frameAndOffset = [IXLayoutEngine getControlFrame:control
                                                           forLayoutControl:layoutControl
                                                             forLayoutRect:layoutRectToCalculateControlFrame
                                                             currentOffset:(controlIsAbsolutePositioned) ? 0.0f : currentOffset
                                                     fixOffsetToLayoutRect:fixOffsetToLayoutRect
                                                     allowOffAxisAlignment:NO];
        
        if( !controlIsAbsolutePositioned )
        {
            currentOffset = frameAndOffset.offset;
        }
        
        if( [controlLayoutInfo canPushParentsBounds] )
        {
            float controlsMaxX = CGRectGetMaxX(frameAndOffset.frame);
            float controlsMaxY = CGRectGetMaxY(frameAndOffset.frame);
            
            returnSize.width = fmaxf(controlsMaxX, returnSize.width);
            returnSize.height = fmaxf(controlsMaxY, returnSize.height);
        }
    }
    
    returnSize.width = round(returnSize.width);
    returnSize.height = round(returnSize.height);
    
    return returnSize;
}

@end
