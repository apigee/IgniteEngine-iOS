//
//  IXLayoutEngine.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXBaseControl;
@class IXLayout;

@interface IXLayoutEngine : NSObject

+(void)layoutControl:(IXLayout*)layoutControl inRect:(CGRect)layoutRect;
+(CGSize)getPreferredSizeForLayoutControl:(IXLayout*)layoutControl forSuggestedSize:(CGSize)suggestedSize;
+(CGRect)getInternalLayoutRectForControl:(IXBaseControl*)control forOuterLayoutRect:(CGRect)outerLayoutRect;

@end
