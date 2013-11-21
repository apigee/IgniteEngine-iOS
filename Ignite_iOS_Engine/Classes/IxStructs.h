//
//  IxStructs.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxEnums.h"

typedef struct IxFrameAndOffset
{
    CGRect frame;
    CGFloat offset;
    
} IxFrameAndOffset;

static const IxFrameAndOffset IxFrameAndOffsetZero = {
    
    .frame   = { {0.0f,0.0f},{0.0f,0.0f} },
    .offset  = 0.0f
};

typedef struct IxSizeAndPosition
{
    CGSize size;
    CGPoint position;
    
} IxSizeAndPosition;

static const IxSizeAndPosition IxSizeAndPositionZero = {
    
    .size   = { .width = 0.0f, .height = 0.0f },
    .position  = { .x = 0.0f, .y = 0.0f }
};