//
//  IXStructs.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/21/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXEnums.h"

typedef struct IXFrameAndOffset
{
    CGRect frame;
    CGFloat offset;
    
} IXFrameAndOffset;

extern const IXFrameAndOffset IXFrameAndOffsetZero;

typedef struct IXSizeAndPosition
{
    CGSize size;
    CGPoint position;
    
} IXSizeAndPosition;

extern const IXSizeAndPosition IXSizeAndPositionZero;

typedef struct IXSizeValuePercentage
{
    BOOL propertyWasDefined;
    BOOL isPercentage;
    float value;
    
} IXSizeValuePercentage;

typedef struct IXEdgeInsets
{
    IXSizeValuePercentage defaultInset;
    IXSizeValuePercentage top;
    IXSizeValuePercentage left;
    IXSizeValuePercentage bottom;
    IXSizeValuePercentage right;
    
} IXEdgeInsets;

