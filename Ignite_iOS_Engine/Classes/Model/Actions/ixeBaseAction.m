//
//  ixeBaseAction.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeBaseAction.h"

#import "ixePropertyContainer.h"
#import "ixeProperty.h"
#import "ixeActionContainer.h"

@implementation ixeBaseAction

-(id)init
{
    self = [super init];
    if( self )
    {
        _eventName = nil;
        _actionProperties = [[ixePropertyContainer alloc] init];
        _parameterProperties = [[ixePropertyContainer alloc] init];
        
#warning NEED TO CHECK THIS LATER ON
        _subActionContainer = [[ixeActionContainer alloc] init];
        [_subActionContainer setActionContainerOwner:[[self actionContainer] actionContainerOwner]];
    }
    return self;
}

-(void)execute
{
    // Base action does nothing.
}

@end
