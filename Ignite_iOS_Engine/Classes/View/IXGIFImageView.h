//
//  IXGIFImageView.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/24/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IXGIFImageView : UIImageView

@property (nonatomic,copy) NSURL* animatedGIFURL;
@property (nonatomic,assign) NSTimeInterval animatedGIFDuration;

-(BOOL)isGIFAnimating;
-(void)startGIFAnimation:(BOOL)restartFromFirstFrame;
-(void)stopGIFAnimation:(BOOL)removeImageFromView;

@end
