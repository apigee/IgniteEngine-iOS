//
//  IxBaseAction.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxBaseAction.h"

#import "IxPropertyContainer.h"
#import "IxProperty.h"
#import "IxActionContainer.h"

@implementation IxBaseAction

-(id)init
{
    self = [super init];
    if( self )
    {
        _eventName = nil;
        _actionProperties = [[IxPropertyContainer alloc] init];
        _parameterProperties = [[IxPropertyContainer alloc] init];
        
#warning NEED TO CHECK THIS LATER ON
        _subActionContainer = [[IxActionContainer alloc] init];
        [_subActionContainer setActionContainerOwner:[[self actionContainer] actionContainerOwner]];
    }
    return self;
}

-(void)execute
{
    // Base action does nothing.
}

@end
