//
//  IXJSONUtils.h
//  IgniteEngine
//
//  Created by Brandon on 4/16/15.
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

#import "IXBaseObject.h"
#import "NSObject+IXAdditions.h"

@interface IXJSONUtils : IXBaseObject

+(NSObject*)setValue:(NSObject*)value forKeyPath:(NSString *)path inContainer:(NSObject*)container;
+(NSObject*)objectForPath:(NSString *)jsonXPath container:(NSObject*)currentNode sandox:(IXSandbox*)sandbox baseObject:(IXBaseObject*)baseObject;
+(NSString*)getQueryValueOutOfValue:(NSString*)value sandbox:(IXSandbox*)sandbox baseObject:(IXBaseObject*)baseObject;
+(NSObject*)appendNewResponseObject:(NSObject *)newObject toPreviousResponseObject:(NSObject *)previousObject forDataPath:(NSString *)dataPath sandox:(IXSandbox*)sandbox baseObject:(IXBaseObject*)baseObject;

@end
