//
//  IXControlCacheContainer.h
//  Ignite Engine
//
//  Created by Robert Walsh on 3/17/14.
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

#import <Foundation/Foundation.h>

@class IXBaseControl;
@class IXAttributeContainer;
@class IXActionContainer;
@class IXControlCacheContainer;

typedef void(^IXGetControlCacheContainerCompletionBlock)(BOOL didSucceed, IXControlCacheContainer* controlCacheContainer, NSError* error);
typedef void(^IXCreateControlCompletionBlock)(BOOL didSucceed, IXBaseControl* createdControl, NSError* error);
typedef void(^IXPopulateControlCompletionBlock)(BOOL didSucceed, IXBaseControl* populatedControl, NSError* error);

@interface IXControlCacheContainer : NSObject <NSCopying>

@property (nonatomic,readonly) Class controlClass;
@property (nonatomic,copy) NSString* controlType;
@property (nonatomic,copy) NSString* styleClass;
@property (nonatomic,strong) IXAttributeContainer* propertyContainer;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) NSArray* childConfigControls;
@property (nonatomic,strong) NSArray* dataProviderConfigs;

-(instancetype)initWithControlType:(NSString*)controlType
                        styleClass:(NSString*)styleClass
                 propertyContainer:(IXAttributeContainer*)propertyContainer
                   actionContainer:(IXActionContainer*)actionContainer
               childConfigControls:(NSArray*)childConfigControls
               dataProviderConfigs:(NSArray*)dataProviderConfigs;

+(void)controlCacheContainerWithJSONAtPath:(NSString*)pathToJSON
                                 loadAsync:(BOOL)loadAsync
                           completionBlock:(IXGetControlCacheContainerCompletionBlock)completionBlock;

+(void)createControlWithPathToJSON:(NSString*)pathToJSON
                         loadAsync:(BOOL)loadAsync
                   completionBlock:(IXCreateControlCompletionBlock)completionBlock;

+(void)createControlWithControlCacheContainer:(IXControlCacheContainer*)controlCacheContainer
                              completionBlock:(IXCreateControlCompletionBlock)completionBlock;

+(void)populateControl:(IXBaseControl*)control
        withJSONAtPath:(NSString*)pathToJSON
             loadAsync:(BOOL)loadAsync
       completionBlock:(IXPopulateControlCompletionBlock)completionBlock;

+(void)populateControl:(IXBaseControl*)control
 controlCacheContainer:(IXControlCacheContainer*)controlCacheContainer
       completionBlock:(IXPopulateControlCompletionBlock)completionBlock;

+(void)clearCache;

@end
