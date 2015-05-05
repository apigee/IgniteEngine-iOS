//
//  IXGetVariable.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/21/13.
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

#import "IXGetEvaluation.h"

#import "IXBaseObject.h"
#import "IXAttribute.h"
#import "IXAttributeContainer.h"
#import "IXSandbox.h"
#import "IXViewController.h"
#import "IXAppManager.h"
#import "IXLayout.h"

@implementation IXGetEvaluation

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    NSString* propertyName = [self methodName];
    if( !propertyName )
    {
        IXAttribute* parameterProperty = (IXAttribute*)[[self parameters] firstObject];
        propertyName = [parameterProperty attributeStringValue];
    }
    
    if( [[self objectID] isEqualToString:kIXSessionRef
         ] )
    {
        returnValue = [[[IXAppManager sharedAppManager] sessionProperties] getStringValueForAttribute:propertyName defaultValue:nil];
    }
    else if( [[self objectID] isEqualToString:kIXViewControlRef] )
    {
        IXSandbox* sandbox = [[[[self property] attributeContainer] ownerObject] sandbox];
        IXViewController* viewController = [sandbox viewController];
        returnValue = [viewController getViewPropertyNamed:propertyName];
    }
    else
    {
        IXBaseObject* baseObject = [[[self property] attributeContainer] ownerObject];
        NSArray* objectWithIDArray = [[baseObject sandbox] getAllControlsAndDataProvidersWithID:[self objectID] withSelfObject:baseObject];
        baseObject = [objectWithIDArray firstObject];
        
        if( baseObject )
        {
            returnValue = [baseObject getReadOnlyPropertyValue:propertyName];
            if( returnValue == nil )
            {
                returnValue = [[baseObject attributeContainer] getStringValueForAttribute:propertyName defaultValue:nil];
            }
        }
    }
    
    return returnValue;
}

@end
