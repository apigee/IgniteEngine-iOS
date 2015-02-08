//
//  IXLayoutEngine.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/21/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXBaseControl;
@class IXView;

@interface IXLayoutEngine : NSObject

+(void)layoutControl:(IXView*)layoutControl inRect:(CGRect)layoutRect;
+(CGSize)getControlSize:(IXBaseControl*)control forLayoutSize:(CGSize)layoutSize;
+(CGSize)getPreferredSizeForLayoutControl:(IXView*)layoutControl forSuggestedSize:(CGSize)suggestedSize;
+(CGRect)getInternalLayoutRectForControl:(IXBaseControl*)control forOuterLayoutRect:(CGRect)outerLayoutRect;

@end
