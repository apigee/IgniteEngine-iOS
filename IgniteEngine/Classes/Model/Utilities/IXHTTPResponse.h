//
//  IXResponseObject.h
//  IgniteEngine
//
//  Created by Brandon on 4/13/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IXHTTPResponse : NSObject

@property (nonatomic,strong) id responseObject;
@property (nonatomic,strong) NSString* responseString;
@property (nonatomic,assign) NSInteger statusCode;
@property (nonatomic,strong) NSDictionary* headers;
@property (nonatomic,strong) NSString* errorMessage;
@property (nonatomic,strong) NSString* paginationNextValue;
@property (nonatomic,strong) NSString* paginationPreviousValue;
@property (nonatomic) CGFloat responseTime;
@property (nonatomic) CFAbsoluteTime requestStartTime; // = CFAbsoluteTimeGetCurrent();
@property (nonatomic) CFAbsoluteTime requestEndTime;

-(void)setResponseStringFromObject:(NSObject*)object;

@end
