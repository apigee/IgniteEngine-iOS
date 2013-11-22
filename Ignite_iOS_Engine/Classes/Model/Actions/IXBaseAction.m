//
//  IXBaseAction.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXBaseAction.h"

#import "IXPropertyContainer.h"
#import "IXProperty.h"
#import "IXActionContainer.h"

@implementation IXBaseAction

-(id)init
{
    self = [super init];
    if( self )
    {
        _eventName = nil;
        _actionProperties = [[IXPropertyContainer alloc] init];
        _parameterProperties = [[IXPropertyContainer alloc] init];
        
#warning NEED TO CHECK THIS LATER ON
        _subActionContainer = [[IXActionContainer alloc] init];
        [_subActionContainer setActionContainerOwner:[[self actionContainer] actionContainerOwner]];
    }
    return self;
}

-(void)execute
{
    // Base action does nothing.
}

@end
