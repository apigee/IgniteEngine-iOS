//
//  IXAttribute.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
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

#import "IXBaseConditionalObject.h"

@class IXBaseObject;
@class IXAttributeContainer;

@interface IXAttribute : IXBaseConditionalObject

@property (nonatomic,weak) IXAttributeContainer* attributeContainer;
@property (nonatomic,assign) BOOL wasAnArray;
@property (nonatomic,copy) NSString* attributeName;
@property (nonatomic,copy) NSString* originalString;
@property (nonatomic,copy) NSString* staticText;
@property (nonatomic,strong) NSArray* evaluations;

-(instancetype)initWithAttributeName:(NSString*)attributeName rawValue:(NSString*)rawValue;
+(instancetype)attributeWithAttributeName:(NSString*)attributeName rawValue:(NSString*)rawValue;
+(instancetype)attributeWithAttributeName:(NSString*)attributeName jsonObject:(id)jsonObject;
+(NSArray*)attributeWithAttributeName:(NSString*)attributeName attributeValueJSONArray:(NSArray*)attributeValueJSONArray;

-(NSString*)attributeStringValue;

@end
