//
//  ixeStructs.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeEnums.h"

typedef struct ixeFrameAndOffset
{
    CGRect frame;
    CGFloat offset;
    
} ixeFrameAndOffset;

static const ixeFrameAndOffset ixeFrameAndOffsetZero = {
    
    .frame   = { {0.0f,0.0f},{0.0f,0.0f} },
    .offset  = 0.0f
};

typedef struct ixeSizeAndPosition
{
    CGSize size;
    CGPoint position;
    
} ixeSizeAndPosition;

static const ixeSizeAndPosition ixeSizeAndPositionZero = {
    
    .size   = { .width = 0.0f, .height = 0.0f },
    .position  = { .x = 0.0f, .y = 0.0f }
};