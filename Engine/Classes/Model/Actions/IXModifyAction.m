//
//  IXModifyAction.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
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
#import "IXProperty.h"

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


@interface IXPropertyContainer ()
@property (nonatomic,strong) NSMutableDictionary* propertiesDict;
@end

@interface IXModifyAction ()
@property (nonatomic,strong) NSMutableDictionary* objectIDAndParameters;
@end

@implementation IXModifyAction

-(instancetype)initWithEventName:(NSString*)eventName
                actionProperties:(IXPropertyContainer*)actionProperties
             setProperties:(IXPropertyContainer*)parameterProperties
              subActionContainer:(IXActionContainer*)subActionContainer
{
    self = [super initWithEventName:eventName actionProperties:actionProperties setProperties:parameterProperties subActionContainer:subActionContainer];
    if( self )
    {
        if( ![actionProperties propertyExistsForPropertyNamed:kIX_TARGET] )
        {
            _objectIDAndParameters = [NSMutableDictionary dictionary];
            NSDictionary* parameters = [[self setProperties] propertiesDict];
            [parameters enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray* propertyArray, BOOL *stop) {
                for( IXProperty* property in propertyArray ) {
                    NSMutableArray* keySeperated = [[key componentsSeparatedByString:kIX_PERIOD_SEPERATOR] mutableCopy];
                    if( [keySeperated count] > 1 ) {
                        NSString* objectID = [keySeperated firstObject];
                        [keySeperated removeObject:objectID];
                        NSString* propertyName = [keySeperated componentsJoinedByString:kIX_PERIOD_SEPERATOR];
                        if( [propertyName length] > 0 ) {
                            [property setPropertyName:propertyName];
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
            [[self setProperties] removeAllProperties];
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
        IXPropertyContainer* sessionProperties = [[IXAppManager sharedAppManager] sessionProperties];
        [sessionProperties addPropertiesFromPropertyContainer:[self setProperties] evaluateBeforeAdding:YES replaceOtherPropertiesWithTheSameName:YES];
        [[IXAppManager sharedAppManager] storeSessionProperties];
    }
    else if( [objectID isEqualToString:kIXAppRef] )
    {
        IXPropertyContainer* appProperties = [[IXAppManager sharedAppManager] appProperties];
        [appProperties addPropertiesFromPropertyContainer:[self setProperties] evaluateBeforeAdding:YES replaceOtherPropertiesWithTheSameName:YES];
        [[IXAppManager sharedAppManager] applyAppProperties];
    }
    else
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        NSArray* objectsWithID = [[ownerObject sandbox] getAllControlsAndDataProvidersWithID:objectID
                                                                              withSelfObject:ownerObject];
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [[baseObject propertyContainer] addPropertiesFromPropertyContainer:[self setProperties] evaluateBeforeAdding:YES replaceOtherPropertiesWithTheSameName:YES];
            
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
        [[self setProperties] addProperties:parameters replaceOtherPropertiesWithTheSameName:YES];
        [self modifyObjectID:objectID];
        if( !needsLayout )
        {
            needsLayout = [[self setProperties] hasLayoutProperties];
        }
        [[self setProperties] removeAllProperties];
    }];

    if( needsLayout )
    {
        [[[[IXAppManager sharedAppManager] currentIXViewController] containerControl] layoutControl];
    }

    [self actionDidFinishWithEvents:nil];
}

-(void)performModify
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
    if( [objectIDs count] > 0 && [self setProperties] != nil )
    {
        for( NSString* objectID in objectIDs )
        {
            [self modifyObjectID:objectID];
        }

        if( [[self setProperties] hasLayoutProperties] )
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
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
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
        
        if( [[self setProperties] hasLayoutProperties] )
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
    CGFloat duration = [[self actionProperties] getFloatPropertyValue:kIXDuration defaultValue:0.0f];
    CGFloat staggerDelay = [self.actionProperties getFloatPropertyValue:kIXStaggerDelay defaultValue:0.0f];
    NSString *animationStyle = [[self actionProperties] getStringPropertyValue:kIXAnimationStyle defaultValue:nil];
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
