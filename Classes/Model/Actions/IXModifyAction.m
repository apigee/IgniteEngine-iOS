//
//  IXModifyAction.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/15/13.
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

#import "IXModifyAction.h"

#import "IXSandbox.h"
#import "IXBaseObject.h"
#import "IXActionContainer.h"
#import "IXAppManager.h"
#import "IXViewController.h"
#import "IXNavigationViewController.h"
#import "IXLayout.h"
#import "IXBaseControl.h"
#import "IXBaseDataProvider.h"
#import "IXAttribute.h"

// IXModifyAction Properties
static NSString* const kIXDuration = @"duration";
static NSString* const kIXAnimationStyle = @"animationStyle";

// kIXAnimationStyle Types
static NSString* const kIXEaseInOut = @"easeInOut";
static NSString* const kIXEaseIn = @"easeIn";
static NSString* const kIXEaseOut = @"easeOut";
static NSString* const kIXLinear = @"linear";

static NSString* const kIXStaggerDelay = @"staggerDelay";

// NSCoding Key Constants
static NSString* const kIXObjectIDAndParameters = @"objectIDAndParameters";


@interface IXAttributeContainer ()
@property (nonatomic,strong) NSMutableDictionary* attributesDict;
@end

@interface IXModifyAction ()
@property (nonatomic,strong) NSMutableDictionary* objectIDAndParameters;
@end

@implementation IXModifyAction

-(instancetype)initWithEventName:(NSString*)eventName
                actionProperties:(IXAttributeContainer*)actionProperties
             setProperties:(IXAttributeContainer*)parameterProperties
              subActionContainer:(IXActionContainer*)subActionContainer
{
    self = [super initWithEventName:eventName actionProperties:actionProperties setProperties:parameterProperties subActionContainer:subActionContainer];
    if( self )
    {
        if( ![actionProperties attributeExistsForName:kIX_TARGET] )
        {
            _objectIDAndParameters = [NSMutableDictionary dictionary];
            NSDictionary* parameters = [[self setProperties] attributesDict];
            [parameters enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray* propertyArray, BOOL *stop) {
                for( IXAttribute* property in propertyArray ) {
                    NSMutableArray* keyseparated = [[key componentsSeparatedByString:kIX_PERIOD_SEPERATOR] mutableCopy];
                    if( [keyseparated count] > 1 ) {
                        NSString* objectID = [keyseparated firstObject];
                        [keyseparated removeObject:objectID];
                        NSString* propertyName = [keyseparated componentsJoinedByString:kIX_PERIOD_SEPERATOR];
                        if( [propertyName length] > 0 ) {
                            [property setAttributeName:propertyName];
                            NSMutableArray* parametersForObjectID = _objectIDAndParameters[objectID];
                            if( parametersForObjectID ) {
                                [parametersForObjectID addObject:property];
                            } else {
                                parametersForObjectID = [NSMutableArray arrayWithObject:property];
                                [_objectIDAndParameters setObject:parametersForObjectID forKey:objectID];
                            }
                        }
                    }
                }
            }];
            [[self setProperties] removeAllAttributes];
        }
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXModifyAction* actionCopy = [super copyWithZone:zone];
    if( actionCopy )
    {
        [actionCopy setObjectIDAndParameters:[[self objectIDAndParameters] copy]];
    }
    return actionCopy;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self setObjectIDAndParameters:[aDecoder decodeObjectForKey:kIXObjectIDAndParameters]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:[self objectIDAndParameters] forKey:kIXObjectIDAndParameters];
}

-(void)modifyObjectID:(NSString *)objectID
{
    if( [objectID isEqualToString:kIXSessionRef] )
    {
        IXAttributeContainer* sessionProperties = [[IXAppManager sharedAppManager] sessionProperties];
        [sessionProperties addAttributesFromContainer:[self setProperties] evaluateBeforeAdding:YES replaceOtherAttributesWithSameName:YES];
        [[IXAppManager sharedAppManager] storeSessionProperties];
    }
    else if( [objectID isEqualToString:kIXAppRef] )
    {
        IXAttributeContainer* appProperties = [[IXAppManager sharedAppManager] appProperties];
        [appProperties addAttributesFromContainer:[self setProperties] evaluateBeforeAdding:YES replaceOtherAttributesWithSameName:YES];
        [[IXAppManager sharedAppManager] applyAppProperties];
    }
    else
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        NSArray* objectsWithID = [[ownerObject sandbox] getAllControlsAndDataProvidersWithID:objectID
                                                                              withSelfObject:ownerObject];
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [[baseObject attributeContainer] addAttributesFromContainer:[self setProperties] evaluateBeforeAdding:YES replaceOtherAttributesWithSameName:YES];
            
            [baseObject applySettings];
            
            if( [baseObject isKindOfClass:[IXBaseDataProvider class]] )
            {
                [((IXBaseDataProvider*)baseObject) loadData:NO];
            }
        }
    }
}

-(void)performModifyUsingObjectIdsFromParameters
{
    __block BOOL needsLayout = NO;
    [[self objectIDAndParameters] enumerateKeysAndObjectsUsingBlock:^(NSString* objectID, NSArray* parameters, BOOL *stop) {
        [[self setProperties] addAttributes:parameters replaceOtherAttributesWithSameName:YES];
        [self modifyObjectID:objectID];
        if( !needsLayout )
        {
            needsLayout = [[self setProperties] hasLayoutAttributes];
        }
        [[self setProperties] removeAllAttributes];
    }];

    if( needsLayout )
    {
        [[[[IXAppManager sharedAppManager] currentIXViewController] containerControl] layoutControl];
    }

    [self actionDidFinishWithEvents:nil];
}

-(void)performModify
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeparatedArrayOfValuesForAttribute:kIX_TARGET defaultValue:nil];
    if( [objectIDs count] > 0 && [self setProperties] != nil )
    {
        for( NSString* objectID in objectIDs )
        {
            [self modifyObjectID:objectID];
        }

        if( [[self setProperties] hasLayoutAttributes] )
        {
            [[[[IXAppManager sharedAppManager] currentIXViewController] containerControl] layoutControl];
        }
        
        [self actionDidFinishWithEvents:nil];
    }
    else
    {
        [self performModifyUsingObjectIdsFromParameters];
    }
}

-(void)performStaggeredModifyWithDuration:(CGFloat)duration
                       withAnimationCurve:(UIViewAnimationCurve)animationCurve
                         withStaggerDelay:(CGFloat)staggerDelay
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeparatedArrayOfValuesForAttribute:kIX_TARGET defaultValue:nil];
    if( [objectIDs count] && [self setProperties] != nil )
    {
        CGFloat delay = 0.0f;
        for( NSString* objectID in objectIDs )
        {
            //[NSThread sleepForTimeInterval:1];
            [UIView animateWithDuration:duration
                                  delay:delay
                                options: animationCurve | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 [self modifyObjectID:objectID];
                             } completion:nil];
            delay += staggerDelay;
        }
        
        if( [[self setProperties] hasLayoutAttributes] )
        {
            [[[[IXAppManager sharedAppManager] currentIXViewController] containerControl] layoutControl];
        }
        
        [self actionDidFinishWithEvents:nil];
    }
    else
    {
        [self performModifyUsingObjectIdsFromParameters];
    }
}

-(void)execute
{
    CGFloat duration = [[self actionProperties] getFloatValueForAttribute:kIXDuration defaultValue:0.0f];
    CGFloat staggerDelay = [self.actionProperties getFloatValueForAttribute:kIXStaggerDelay defaultValue:0.0f];
    NSString *animationStyle = [[self actionProperties] getStringValueForAttribute:kIXAnimationStyle defaultValue:nil];
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseInOut;

    if (animationStyle)
    {
        if ( [animationStyle isEqualToString:kIXEaseInOut] )
            animationCurve = UIViewAnimationCurveEaseInOut;
        else if ( [animationStyle isEqualToString:kIXEaseIn] )
            animationCurve = UIViewAnimationCurveEaseIn;
        else if ( [animationStyle isEqualToString:kIXEaseOut] )
            animationCurve = UIViewAnimationCurveEaseOut;
        else if ( [animationStyle isEqualToString:kIXLinear] )
            animationCurve = UIViewAnimationCurveLinear;
    }
    
    if( duration > 0.0f )
    {
        if (staggerDelay > 0)
        {
            [self performStaggeredModifyWithDuration:duration withAnimationCurve:animationCurve withStaggerDelay:staggerDelay];
        }
        else
        {
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:duration
                                  delay:0.0f
                                options: animationCurve | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 [weakSelf performModify];
                             } completion:nil];
        }
    }
    else
    {
        [self performModify];
    }
}

@end
