//
//  IXLoadAction.m
//  Ignite Engine
//
//  Created by Brandon on 3/6/14.
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

#import "IXLoadAction.h"

#import "IXBaseObject.h"
#import "IXActionContainer.h"
#import "IXAppManager.h"
#import "IXViewController.h"
#import "IXNavigationViewController.h"
#import "IXLayout.h"
#import "IXBaseControl.h"
#import "IXBaseDataProvider.h"

@implementation IXLoadAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeparatedArrayOfValuesForAttribute:kIX_TARGET defaultValue:nil];
    
    if( [objectIDs count] )
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        IXSandbox* sandbox = [ownerObject sandbox];
        NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                                 withSelfObject:ownerObject];
        
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [baseObject applySettings];
            
            if( [baseObject isKindOfClass:[IXBaseDataProvider class]] )
            {
                [((IXBaseDataProvider*)baseObject) loadData:YES];
            }
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
