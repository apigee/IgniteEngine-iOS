//
//  UILabel+IXAdditions.h
//  Ignite Engine
//
//  Created by Robert Walsh on 12/19/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (IXAdditions)

-(CGSize)sizeForFixedWidth:(float)fixedWidth;
+(NSTextAlignment)ix_textAlignmentFromString:(NSString*)textAlignmentString;

@end
