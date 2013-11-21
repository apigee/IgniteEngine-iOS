//
//  ixeLayoutEngine.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class ixeBaseControl;
@class ixeLayout;

@interface ixeLayoutEngine : NSObject

+(void)layoutControl:(ixeLayout*)layoutControl inRect:(CGRect)layoutRect;
+(CGSize)getPreferredSizeForLayoutControl:(ixeLayout*)layoutControl forSuggestedSize:(CGSize)suggestedSize;
+(CGRect)getInternalLayoutRectForControl:(ixeBaseControl*)control forOuterLayoutRect:(CGRect)outerLayoutRect;

@end
