//
//  IXDeleteAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/27/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXDeleteAction.h"

#import "IXSandbox.h"
#import "IXBaseControl.h"
#import "IXPropertyContainer.h"

// IXDeleteAction Events
static NSString* kIXSuccess = @"success";
static NSString* kIXFailed = @"failed";

@implementation IXDeleteAction

-(void)execute
{
    [super execute];
    
    BOOL didSucceed = NO;

    NSString* deleteControlID = [[self actionProperties] getStringPropertyValue:kIX_ID defaultValue:nil];
    if( deleteControlID )
    {
        NSMutableArray* parentsNeedingLayout = [NSMutableArray array];
        IXSandbox* sandbox = [[[self actionContainer] ownerObject] sandbox];
        NSArray* controlsToDelete = [sandbox getAllControlsWithID:deleteControlID];
        for( IXBaseControl* control in controlsToDelete )
        {
            if( [control parentObject] )
            {
                [parentsNeedingLayout addObject:[control parentObject]];
                [[control parentObject] removeChildObject:control];
            }
        }
        
        for( IXBaseControl* parent in parentsNeedingLayout )
        {
            [parent layoutControl];
        }
        
        didSucceed = ([controlsToDelete count] > 0);
    }
    
    if( didSucceed )
    {
        [self actionDidFinishWithEvents:@[kIXSuccess]];
    }
    else
    {
        [self actionDidFinishWithEvents:@[kIXFailed]];
    }
}

@end
