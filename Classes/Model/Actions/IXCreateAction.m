//
//  IXCreateAction.m
//  Ignite Engine
//
//  Created by Robert Walsh on 1/27/14.
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

#import "IXCreateAction.h"

#import "IXAppManager.h"
#import "IXLogger.h"

#import "IXAttributeContainer.h"
#import "IXBaseControlConfig.h"
#import "IXControlCacheContainer.h"
#import "IXCustom.h"

#import "IXBaseControl.h"

// IXCreateAction Properties
static NSString* const kIXControlLocation = @"control.url";
static NSString* const kIXParentID = @"parent.id";

// IXCreateAction Events: kIX_SUCCESS and kIX_FAILED
static NSString* const kIXCreated = @"created"; // Fires on the actual created control. 

@implementation IXCreateAction

-(void)execute
{
    [super execute];
    
    BOOL needsToSendFailed = YES;
    
    NSString* controlJSONLocation = [[self actionProperties] getPathValueForAttribute:kIXControlLocation
                                                                         basePath:nil
                                                                     defaultValue:nil];
    
    if( controlJSONLocation )
    {
        NSString* parentControlID = [[self actionProperties] getStringValueForAttribute:kIXParentID
                                                                       defaultValue:nil];

        IXBaseControl* parentControl = nil;
        IXSandbox* sandbox = [[[self actionContainer] ownerObject] sandbox];
        if( [parentControlID length] > 0 )
        {
            parentControl = [[sandbox getAllControlsWithID:parentControlID] firstObject];
        }
        else
        {
            parentControl = [sandbox containerControl];
        }
        
        if( parentControl != nil )
        {
            needsToSendFailed = NO;
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(parentControl) weakParentControl = parentControl;
            
            [IXControlCacheContainer createControlWithPathToJSON:controlJSONLocation loadAsync:NO completionBlock:^(BOOL didSucceed, IXBaseControl *createdControl, NSError *error) {
                                                     
                 if( createdControl && weakParentControl )
                 {
                     [weakParentControl addChildObject:createdControl];

                     if( [createdControl isKindOfClass:[IXCustom class]] )
                     {
                         IXCustom* customControl = (IXCustom*)createdControl;
                         if( !([[customControl pathToJSON] length] > 0) )
                         {
                             [customControl setPathToJSON:controlJSONLocation];
                         }
                     }

                     [createdControl applySettings];
                     [weakParentControl layoutControl];
                     
                     // Fire the created action on the actual created control (not on the action).
                     [[createdControl actionContainer] executeActionsForEventNamed:kIXCreated];
                     
                     [weakSelf actionDidFinishWithEvents:@[kIX_SUCCESS]];
                }
                else
                {
                    [weakSelf actionDidFinishWithEvents:@[kIX_ERROR]];
                }
             }];
        }
    }
    
    if( needsToSendFailed )
    {
        [self actionDidFinishWithEvents:@[kIX_ERROR]];
    }
}

@end
