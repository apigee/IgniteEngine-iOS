//
//  IXStructs.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
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