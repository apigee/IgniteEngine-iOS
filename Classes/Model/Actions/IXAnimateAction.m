//
//  IXAnimateAction.m
//  Ignite Engine
//
//  Created by Brandon on 3/26/14.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXAnimateAction.h"

#import "IXSandbox.h"
#import "IXBaseObject.h"
#import "IXActionContainer.h"
#import "IXAppManager.h"
#import "IXLayout.h"
#import "IXBaseControl.h"

// Animation Properties
static NSString* const kIXDuration = @"duration";
static NSString* const kIXAnimation = @"animation";
static NSString* const kIXRepeatCount = @"repeatCount";

// Animation Options
static NSString* const kIXDirection = @"direction";

// Animations are declared in IXBaseControl.m

@implementation IXAnimateAction

-(void)performAnimation
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeparatedArrayOfValuesForAttribute:kIX_TARGET defaultValue:nil];
    CGFloat duration = [[self actionProperties] getFloatValueForAttribute:kIXDuration defaultValue:0.0f];
    NSString* animation = [[self actionProperties] getStringValueForAttribute:kIXAnimation defaultValue:nil];
    NSInteger repeatCount = [[self actionProperties] getIntValueForAttribute:kIXRepeatCount defaultValue:0];
    NSString* direction = [[self actionProperties] getStringValueForAttribute:kIXDirection defaultValue:nil];
    
    NSDictionary* params;
    
    if (direction)
    {
        params = @{kIXDirection: direction};
    }
    
    if( objectIDs != nil && animation != nil)
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        IXSandbox* sandbox = [ownerObject sandbox];
        for( NSString* objectID in objectIDs )
        {
            NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithID:objectID
                                                                    withSelfObject:ownerObject];
            for( IXBaseObject* baseObject in objectsWithID )
            {
                [baseObject beginAnimation:animation duration:duration repeatCount:repeatCount params:params];
            }
        }
        
        //This isn't working properly yet! Need to work out how to fire completion events.
        [self actionDidFinishWithEvents:nil];
    }
}

-(void)execute
{
    [self performAnimation];
}




@end

