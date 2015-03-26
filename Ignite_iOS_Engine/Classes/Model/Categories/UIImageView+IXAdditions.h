//
//  UIImageView+IXAdditions.h
//  Ignite Engine
//
//  Created by Robert Walsh on 2/12/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (IXAdditions)

// Both pause and resume animation are based off of https://developer.apple.com/library/ios/qa/qa1673/_index.html

-(void)pauseAnimation;

-(void)resumeAnimation;

@end
