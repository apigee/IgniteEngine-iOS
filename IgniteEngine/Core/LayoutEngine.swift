//
//  LayoutEngine.swift
//  Ignite Engine
//
//  Created by Robert Walsh on 2/9/15.
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

import Foundation

@objc class LayoutEngine {
    
    private final class func calculateEqualWidthForLayoutsControls(layout:IXLayout, totalWidthAvailable:CGFloat) -> CGFloat {
        var totalUnclaimedControls:Int = 0
        var unclaimedWidth:CGFloat = totalWidthAvailable
        if let children = layout.childObjects {
            for child: AnyObject in children {
                if let childControl = child as? IXBaseControl {
                    if let layoutInfo = childControl.layoutInfo  {
                        if childControl.contentView == nil || layoutInfo.isHidden || layoutInfo.isAbsolutePositioned {
                            continue
                        }
                        unclaimedWidth -= ixEvaluateSizeValuePercentageForMaxValue(layoutInfo.width, totalWidthAvailable)
                        if layoutInfo.widthWasDefined {
                            totalUnclaimedControls++;
                        }
                    }
                }
            }
        }
        
        var equalWidthForLayoutsControls:CGFloat = 0.0
        if totalUnclaimedControls > 0 {
            equalWidthForLayoutsControls = unclaimedWidth/CGFloat(totalUnclaimedControls)
        }
        return equalWidthForLayoutsControls;
    }
    
    private final class func calculateControlPosition(control:IXBaseControl,size:CGSize,layoutRect:CGRect) -> CGPoint {
        
        var controlPosition = CGPointMake(layoutRect.origin.x, layoutRect.origin.y)
        
        if let layoutInfo = control.layoutInfo {
            let marginInsets = ixEvaluateEdgeInsets(layoutInfo.marginInsets,layoutRect.size)
            if layoutInfo.leftPositionWasDefined && layoutInfo.isAbsolutePositioned {
                controlPosition.x += ixEvaluateSizeValuePercentageForMaxValue(layoutInfo.leftPosition, layoutRect.size.width)
            } else {
                switch layoutInfo.horizontalAlignment {
                case .Center :
                    controlPosition.x += (layoutRect.size.width - size.width) * 0.5
                case .Left :
                    controlPosition.x += layoutRect.size.width - size.width - marginInsets.right
                case .Right :
                    controlPosition.x += marginInsets.left
                }
            }
            if layoutInfo.topPositionWasDefined && layoutInfo.isAbsolutePositioned {
                controlPosition.y += ixEvaluateSizeValuePercentageForMaxValue(layoutInfo.topPosition, layoutRect.size.height)
            } else {
                switch layoutInfo.verticalAlignment {
                case .Middle :
                    controlPosition.y += (layoutRect.size.height - size.height) * 0.5
                case .Bottom :
                    controlPosition.y += layoutRect.size.height - size.height - marginInsets.bottom
                case .Top :
                    controlPosition.y += marginInsets.top
                }
            }
        }
        
        controlPosition.x = round(controlPosition.x)
        controlPosition.y = round(controlPosition.y)
        
        return controlPosition;
    }
    
    internal final class func calculateControlSize(control:IXBaseControl,layoutSize:CGSize) -> CGSize {
        
        var controlSize = CGSize.zeroSize
        if let layoutInfo = control.layoutInfo {
            let heightDefined = layoutInfo.heightWasDefined
            let widthDefined = layoutInfo.widthWasDefined
            if heightDefined && widthDefined {
                controlSize.width = ixEvaluateSizeValuePercentageForMaxValue(layoutInfo.width, layoutSize.width)
                controlSize.height = ixEvaluateSizeValuePercentageForMaxValue(layoutInfo.height, layoutSize.height)
            } else if !layoutInfo.isHidden {
                if widthDefined {
                    controlSize.width = ixEvaluateSizeValuePercentageForMaxValue(layoutInfo.width, layoutSize.width)
                }
                if heightDefined {
                    controlSize.height = ixEvaluateSizeValuePercentageForMaxValue(layoutInfo.height, layoutSize.height)
                }
                if !heightDefined || !widthDefined {
                    let controlPaddingInsets = ixEvaluateEdgeInsets(layoutInfo.paddingInsets, controlSize)
                    let internalWidth = fmax(0.0,controlSize.width - controlPaddingInsets.left - controlPaddingInsets.right)
                    let internalHeight = fmax(0.0,controlSize.height - controlPaddingInsets.top - controlPaddingInsets.bottom)
                    let preferredSize = control.preferredSizeForSuggestedSize(CGSize(width: internalWidth, height: internalHeight))
                    if !widthDefined {
                        controlSize.width = preferredSize.width + controlPaddingInsets.left + controlPaddingInsets.right
                    }
                    if !heightDefined {
                        controlSize.height = preferredSize.height + controlPaddingInsets.top + controlPaddingInsets.bottom
                    }
                }
            }
        }
        return controlSize
    }
    
    private final class func calculateRemainingSize(controlLayoutInfo:IXControlLayoutInfo,rect:CGRect,controlSize:CGSize,controlPosition:CGPoint) -> CGSize {
        var remainingSize = controlSize
        if controlLayoutInfo.fillRemainingWidth {
            let remainingWidth = rect.size.width - controlPosition.x + rect.origin.x
            if remainingWidth > 0.0 {
                remainingSize.width = remainingWidth
            }
        }
        if controlLayoutInfo.fillRemainingHeight {
            let remainingHeight = rect.size.height - controlPosition.y + rect.origin.y
            if remainingHeight > 0.0 {
                remainingSize.height = remainingHeight
            }
        }
        return remainingSize
    }
    
    private final class func calculateControlFrame(control:IXBaseControl,layout:IXLayout,layoutRect:CGRect,currentOffset:CGFloat,fixOffsetToLayout:Bool,allowOffAxisAlign:Bool) -> IXFrameAndOffset {
        
        var offset = currentOffset
        var sizeAndPosition = IXSizeAndPositionZero
        
        if let layoutInfo = control.layoutInfo {
            
            let controlMarginInsets = ixEvaluateEdgeInsets(layoutInfo.marginInsets, layoutRect.size)
            if layout.layoutFlowVertical || layoutInfo.isAbsolutePositioned {
                
                var verticalLayoutRect = layoutRect
                verticalLayoutRect.origin.y += currentOffset
                
                sizeAndPosition.size = LayoutEngine.calculateControlSize(control, layoutSize: verticalLayoutRect.size)
                
                if !layoutInfo.isAbsolutePositioned {
                    if !allowOffAxisAlign {
                        verticalLayoutRect.size.width = sizeAndPosition.size.width
                    }
                    if !fixOffsetToLayout {
                        verticalLayoutRect.size.height = sizeAndPosition.size.height
                    }
                }
                
                sizeAndPosition.position = LayoutEngine.calculateControlPosition(control, size: sizeAndPosition.size, layoutRect: verticalLayoutRect)
                
                sizeAndPosition.size = LayoutEngine.calculateRemainingSize(layoutInfo, rect: layoutRect, controlSize: sizeAndPosition.size, controlPosition: sizeAndPosition.position)
                
                offset += controlMarginInsets.top + controlMarginInsets.bottom
                if fixOffsetToLayout {
                    offset += fmax(layoutRect.size.height, sizeAndPosition.size.height)
                } else {
                    offset += sizeAndPosition.size.height
                }
            } else {
                var horizontalLayoutRect = layoutRect
                horizontalLayoutRect.origin.x += currentOffset
                
                if !fixOffsetToLayout && !layoutInfo.widthWasDefined {
                    horizontalLayoutRect.size.width = CGFloat.max
                }
                
                sizeAndPosition.size = LayoutEngine.calculateControlSize(control, layoutSize: horizontalLayoutRect.size)
                
                if !fixOffsetToLayout {
                    horizontalLayoutRect.size.width = sizeAndPosition.size.width
                }
                if !allowOffAxisAlign {
                    horizontalLayoutRect.size.height = sizeAndPosition.size.height
                }
                
                if sizeAndPosition.size.width >= CGFloat.max {
                    sizeAndPosition.size.width = layoutRect.size.width
                    horizontalLayoutRect.size.width = layoutRect.size.width
                }
                
                sizeAndPosition.position = LayoutEngine.calculateControlPosition(control, size: sizeAndPosition.size, layoutRect: horizontalLayoutRect)
                
                sizeAndPosition.size = LayoutEngine.calculateRemainingSize(layoutInfo, rect: layoutRect, controlSize: sizeAndPosition.size, controlPosition: sizeAndPosition.position)
                
                offset += controlMarginInsets.left + controlMarginInsets.right
                if fixOffsetToLayout {
                    offset += fmax(layoutRect.size.width, sizeAndPosition.size.width)
                } else {
                    offset += sizeAndPosition.size.width
                }
            }
        }
        
        return IXFrameAndOffset(frame: CGRectMake(round(sizeAndPosition.position.x), round(sizeAndPosition.position.y), round(sizeAndPosition.size.width), round(sizeAndPosition.size.height)), offset: offset)
    }
    
    private final class func addLayoutChildrenToViewHeirarchy(layoutControl:IXLayout) {
        if let children = layoutControl.childObjects {
            var nonFloatIndex:Int = 0
            var floatIndex:Int = 1 // Float index starts at 1 to account for scrollView inside of the layoutControl
            for child: AnyObject in children {
                if let childControl = child as? IXBaseControl {
                    if childControl.contentView != nil {
                        if let layoutInfo = childControl.layoutInfo {
                            if layoutInfo.isFloatPositioned {
                                if childControl.contentView.superview != layoutControl.contentView {
                                    layoutControl.contentView.insertSubview(childControl.contentView, atIndex: floatIndex)
                                }
                                floatIndex++
                            } else {
                                if childControl.contentView.superview != layoutControl.scrollViewContentView {
                                    layoutControl.scrollViewContentView.insertSubview(childControl.contentView, atIndex: nonFloatIndex)
                                }
                                nonFloatIndex++
                            }
                        }
                    }
                }
            }
        }
    }
    
    internal final class func calculateInternalLayoutRect(control:IXBaseControl,rect:CGRect) -> CGRect {
        var internalRect = rect
        if let layoutInfo = control.layoutInfo {
            let controlPaddingInsets = ixEvaluateEdgeInsets(layoutInfo.paddingInsets,rect.size)
            internalRect.origin.x = controlPaddingInsets.left
            internalRect.origin.y = controlPaddingInsets.top
            internalRect.size.width -= controlPaddingInsets.left + controlPaddingInsets.right
            internalRect.size.height -= controlPaddingInsets.top + controlPaddingInsets.bottom
        }
        return internalRect
    }
    
    internal final class func layout(layout:IXLayout,layoutRect:CGRect) {
        
        LayoutEngine.addLayoutChildrenToViewHeirarchy(layout)
        
        let layoutsView = layout.contentView
        let layoutsScrollView = layout.scrollView
        layoutsScrollView.frame = layoutsView.bounds
        
        let absoluteRect = layoutsScrollView.frame
        let relativeRect = layoutRect
        
        var equalWidthForLayoutsControls:CGFloat = 0.0
        var processEqualHorizontalLayout = (!layout.layoutFlowVertical && layout.layoutInfo.widthWasDefined)
        if processEqualHorizontalLayout {
            equalWidthForLayoutsControls = LayoutEngine.calculateEqualWidthForLayoutsControls(layout, totalWidthAvailable: relativeRect.size.width)
        }
        
        var maxPoint = CGPoint.zeroPoint
        var currentOffset:CGFloat = 0.0
        var addXPaddingToScroll = true
        var addYPaddingToScroll = true
        
        if let children = layout.childObjects {
            for child in layout.childObjects {
                if let childControl = child as? IXBaseControl {
                    if let layoutInfo = childControl.layoutInfo {
                        if childControl.contentView == nil || layoutInfo.isHidden {
                            continue
                        }
                        let controlIsAbsolute = layoutInfo.isAbsolutePositioned
                        
                        var fixOffsetToLayoutRect = false
                        var layoutRectForCalculatingFrame = absoluteRect
                        
                        if !controlIsAbsolute {
                            layoutRectForCalculatingFrame = relativeRect
                            fixOffsetToLayoutRect = processEqualHorizontalLayout && !layoutInfo.widthWasDefined
                            if fixOffsetToLayoutRect {
                                layoutRectForCalculatingFrame.size.width = equalWidthForLayoutsControls
                            }
                        }
                        
                        var frameAndOffset = LayoutEngine.calculateControlFrame(childControl, layout: layout, layoutRect: layoutRectForCalculatingFrame, currentOffset:(controlIsAbsolute ? 0.0 : currentOffset), fixOffsetToLayout: fixOffsetToLayoutRect, allowOffAxisAlign: true)
                        
                        layoutInfo.layoutRect = frameAndOffset.frame
                        if !controlIsAbsolute {
                            currentOffset = frameAndOffset.offset
                        }
                        
                        if layoutInfo.canPushParentsBounds {
                            let controlsMaxX = CGRectGetMaxX(layoutInfo.layoutRect)
                            if controlsMaxX > maxPoint.x {
                                if controlIsAbsolute {
                                    addXPaddingToScroll = false
                                } else if !layoutInfo.isFloatPositioned {
                                    addXPaddingToScroll = true
                                }
                                maxPoint.x = controlsMaxX
                            }
                            let controlsMaxY = CGRectGetMaxY(layoutInfo.layoutRect)
                            if controlsMaxY > maxPoint.y {
                                if controlIsAbsolute {
                                    addYPaddingToScroll = false
                                } else if !layoutInfo.isFloatPositioned {
                                    addYPaddingToScroll = true
                                }
                                maxPoint.y = controlsMaxY
                            }
                        }
                        
                        childControl.contentView.hidden = layoutInfo.isHidden
                        childControl.contentView.frame = layoutInfo.layoutRect
                        if childControl.contentView.hidden || CGSizeEqualToSize(layoutInfo.layoutRect.size, CGSize.zeroSize) {
                            continue
                        }
                        
                        childControl.layoutControlContentsInRect(CGRectIntegral(LayoutEngine.calculateInternalLayoutRect(childControl, rect: childControl.contentView.bounds)))
                    }
                }
            }
        }
        
        var contentSize = layoutsView.bounds.size
        let layoutPaddingInsets = ixEvaluateEdgeInsets(layout.layoutInfo.paddingInsets, contentSize)
        
        if layout.verticalScrollEnabled {
            contentSize.height = maxPoint.y
            if addYPaddingToScroll && contentSize.height > layoutsScrollView.bounds.size.height {
                contentSize.height += layoutPaddingInsets.bottom
            }
        }
        if layout.horizontalScrollEnabled {
            contentSize.width = maxPoint.x
            if addXPaddingToScroll && contentSize.width > layoutsScrollView.bounds.size.width {
                contentSize.width += layoutPaddingInsets.right
            }
        }
        
        let layoutsZoomScale = layoutsScrollView.zoomScale
        let layoutsViewWithZoomWidth = layoutsView.bounds.size.width * layoutsZoomScale
        let contentSizeWithZoomWidth = contentSize.width * layoutsZoomScale
        let scrollViewContentViewWidth = fmax(layoutsViewWithZoomWidth,
            contentSizeWithZoomWidth)
        
        let layoutsViewWithZoomHeight = layoutsView.bounds.size.height * layoutsZoomScale
        let contentSizeWithZoomHeight = contentSize.height * layoutsZoomScale
        let scrollViewContentViewHeight = fmax(layoutsViewWithZoomHeight,
            contentSizeWithZoomHeight)
        
        let scrollViewContentViewRect = CGRectMake(0.0, 0.0, scrollViewContentViewWidth, scrollViewContentViewHeight)
        layout.scrollViewContentView.frame = scrollViewContentViewRect
        layoutsScrollView.contentSize = scrollViewContentViewRect.size
        
        let contentSizeIsLargerThanBounds = (layoutsScrollView.contentSize.width > layoutsScrollView.bounds.size.width) ||
            (layoutsScrollView.contentSize.height > layoutsScrollView.bounds.size.height)
        
        layoutsScrollView.scrollEnabled = layout.zoomEnabled || contentSizeIsLargerThanBounds
    }
    
    internal final class func getPreferredSize(layout:IXLayout,suggestedSize:CGSize) -> CGSize {
        var preferredSize = CGSize.zeroSize
        if let layoutInfo = layout.layoutInfo {
            let paddingInsets = ixEvaluateEdgeInsets(layoutInfo.paddingInsets, suggestedSize)
            if layoutInfo.widthWasDefined {
                preferredSize.width = ixEvaluateSizeValuePercentageForMaxValue(layoutInfo.width, suggestedSize.width)
            }
            if layoutInfo.heightWasDefined {
                preferredSize.height = ixEvaluateSizeValuePercentageForMaxValue(layoutInfo.height, suggestedSize.height)
            }
            
            var absoluteRect = CGRect.zeroRect
            absoluteRect.size = suggestedSize
            
            var relativeRect = CGRect.zeroRect
            relativeRect.size = CGSizeMake(preferredSize.width + paddingInsets.left + paddingInsets.right,
                preferredSize.height + paddingInsets.top + paddingInsets.bottom)
            
            var equalWidthForLayoutsControls:CGFloat = 0.0
            var processEqualHorizontalLayout = (!layout.layoutFlowVertical && layoutInfo.widthWasDefined)
            if processEqualHorizontalLayout {
                equalWidthForLayoutsControls = LayoutEngine.calculateEqualWidthForLayoutsControls(layout, totalWidthAvailable: relativeRect.size.width)
            }
            
            
            var currentOffset:CGFloat = 0.0
            
            if let children = layout.childObjects {
                for child in layout.childObjects {
                    if let childControl = child as? IXBaseControl {
                        if childControl.contentView == nil || childControl.layoutInfo.isHidden {
                            continue
                        }
                        let layoutInfo = childControl.layoutInfo
                        let controlIsAbsolute = layoutInfo.isAbsolutePositioned
                        
                        var fixOffsetToLayoutRect = false
                        var layoutRectForCalculatingFrame = absoluteRect
                        
                        if !controlIsAbsolute {
                            layoutRectForCalculatingFrame = relativeRect
                            fixOffsetToLayoutRect = processEqualHorizontalLayout && !layoutInfo.widthWasDefined
                            if fixOffsetToLayoutRect {
                                layoutRectForCalculatingFrame.size.width = equalWidthForLayoutsControls
                            }
                        }
                        
                        var frameAndOffset = LayoutEngine.calculateControlFrame(childControl, layout: layout, layoutRect: layoutRectForCalculatingFrame, currentOffset:(controlIsAbsolute ? 0.0 : currentOffset), fixOffsetToLayout: fixOffsetToLayoutRect, allowOffAxisAlign: false)
                        
                        if !controlIsAbsolute {
                            currentOffset = frameAndOffset.offset
                        }
                        
                        if layoutInfo.canPushParentsBounds {
                            let controlsMaxX = CGRectGetMaxX(frameAndOffset.frame)
                            let controlsMaxY = CGRectGetMaxY(frameAndOffset.frame)
                            preferredSize.width = CGFloat(fmax(controlsMaxX, preferredSize.width))
                            preferredSize.height = CGFloat(fmax(controlsMaxY, preferredSize.height))
                        }
                    }
                }
            }
        }
        
        preferredSize.width = round(preferredSize.width)
        preferredSize.height = round(preferredSize.height)
        
        return preferredSize
    }
}