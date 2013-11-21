//
//  IxLayoutEngine.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class IxBaseControl;
@class IxLayout;

@interface IxLayoutEngine : NSObject

+(void)layoutControl:(IxLayout*)layoutControl inRect:(CGRect)layoutRect;
+(CGSize)getPreferredSizeForLayoutControl:(IxLayout*)layoutControl forSuggestedSize:(CGSize)suggestedSize;
+(CGRect)getInternalLayoutRectForControl:(IxBaseControl*)control forOuterLayoutRect:(CGRect)outerLayoutRect;

@end
