//
//  IXBaseObject.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
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

#import "IXConstants.h"
#import "IXSandbox.h"
#import "IXActionContainer.h"
#import "IXAttributeContainer.h"


@class IXBaseAction;

@interface IXBaseObject : NSObject <NSCopying,NSCoding>

@property (nonatomic,weak) IXBaseObject* parentObject;
@property (nonatomic,weak) IXSandbox* sandbox;

@property (nonatomic,copy) NSString* ID;
@property (nonatomic,copy) NSString* styleClass;

@property (nonatomic,strong) NSMutableArray* childObjects;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXAttributeContainer* attributeContainer;

-(void)addChildObject:(IXBaseObject*)childObject;
-(void)removeChildObject:(IXBaseObject*)childObject;
-(void)addChildObjects:(NSArray*)childObjects;
-(NSArray*)childrenWithID:(NSString*)childObjectID;
-(NSArray*)childrenThatAreKindOfClass:(Class)baseObjectClass;

-(void)applySettings;
-(void)applyFunction:(NSString*)functionName withParameters:(IXAttributeContainer*)parameterContainer;
-(void)beginAnimation:(NSString*)animation duration:(CGFloat)duration repeatCount:(NSInteger)repeatCount params:(NSDictionary*)params;
-(void)endAnimation:(NSString*)animation;
-(NSString*)getReadOnlyPropertyValue:(NSString*)propertyName;

@end
