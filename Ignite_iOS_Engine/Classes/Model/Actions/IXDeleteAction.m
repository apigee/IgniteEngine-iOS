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

@implementation IXDeleteAction

-(void)execute
{
    [super execute];
    
    NSString* deleteControlID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    if( deleteControlID )
    {
        NSMutableArray* parentsNeedingLayout = [NSMutableArray array];
        NSArray* controlsToDelete = [[[self actionProperties] sandbox] getAllControlsWithID:deleteControlID];
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
    }
}

@end
