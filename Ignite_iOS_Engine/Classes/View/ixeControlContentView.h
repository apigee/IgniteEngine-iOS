//
//  ixeControlContentView.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/22.
//  Copyright (c) 2013 All rights reserved.
//

#import <UIKit/UIKit.h>

@class ixeBaseControl;

@protocol ixeControlContentViewTouchDelegate <NSObject>

@optional

-(void)controlViewTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

@end

@interface ixeControlContentView : UIControl

@property (nonatomic,weak) id<ixeControlContentViewTouchDelegate> controlContentViewTouchDelegate;

-(id)initWithFrame:(CGRect)frame viewTouchDelegate:(id<ixeControlContentViewTouchDelegate>)touchDelegate;

@end
