//
//  IXBaseShortCode.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXProperty;

@interface IXBaseShortCode : NSObject <NSCopying>

@property (nonatomic,weak) IXProperty* property;
@property (nonatomic,copy) NSString* rawValue;
@property (nonatomic,copy) NSString* objectID;
@property (nonatomic,copy) NSString* methodName;
@property (nonatomic,strong) NSArray* parameters;

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                     parameters:(NSArray*)parameters;

+(IXBaseShortCode*)shortCodeWithRawValue:(NSString*)rawValue
                                objectID:(NSString*)objectID
                              methodName:(NSString*)methodName
                              parameters:(NSArray*)parameters;
-(NSString*)evaluate;

@end
