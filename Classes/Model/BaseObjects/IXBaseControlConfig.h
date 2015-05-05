//
//  IXBaseControlConfig.h
//  Ignite Engine
//
//  Created by Robert Walsh on 2/21/14.
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
@class IXActionContainer;
@class IXAttributeContainer;

@interface IXBaseControlConfig : NSObject <NSCopying>

@property (nonatomic,assign) Class controlClass;
@property (nonatomic,copy)   NSString* styleClass;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXAttributeContainer* propertyContainer;
@property (nonatomic,strong) NSDictionary* controlConfigDictionary;

-(instancetype)initWithControlClass:(Class)controlClass
                         styleClass:(NSString*)styleClass
                  propertyContainer:(IXAttributeContainer*)propertyContainer
                    actionContainer:(IXActionContainer*)actionContainer
            controlConfigDictionary:(NSDictionary*)controlConfigDictionary;

+(instancetype)controlConfigWithJSONDictionary:(NSDictionary*)controlJSONDict;
+(NSArray*)controlConfigsWithJSONControlArray:(NSArray*)controlsValueArray;

-(IXBaseControl*)createControl;

@end
