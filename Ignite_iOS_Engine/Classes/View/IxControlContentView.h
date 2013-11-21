//
//  IxControlContentView.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/22.
//  Copyright (c) 2013 All rights reserved.
//

#import <UIKit/UIKit.h>

@class IxBaseControl;

@protocol IxControlContentViewTouchDelegate <NSObject>

@optional

-(void)controlViewTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

@end

@interface IxControlContentView : UIControl

@property (nonatomic,weak) id<IxControlContentViewTouchDelegate> controlContentViewTouchDelegate;

-(id)initWithFrame:(CGRect)frame viewTouchDelegate:(id<IxControlContentViewTouchDelegate>)touchDelegate;

@end
