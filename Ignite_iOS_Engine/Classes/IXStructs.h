//
//  IXStructs.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/21/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXEnums.h"

typedef struct IXFrameAndOffset
{
    CGRect frame;
    CGFloat offset;
    
} IXFrameAndOffset;

static const IXFrameAndOffset IXFrameAndOffsetZero = {
    
    .frame   = { {0.0f,0.0f},{0.0f,0.0f} },
    .offset  = 0.0f
};

typedef struct IXSizeAndPosition
{
    CGSize size;
    CGPoint position;
    
} IXSizeAndPosition;

static const IXSizeAndPosition IXSizeAndPositionZero = {
    
    .size   = { .width = 0.0f, .height = 0.0f },
    .position  = { .x = 0.0f, .y = 0.0f }
};

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

