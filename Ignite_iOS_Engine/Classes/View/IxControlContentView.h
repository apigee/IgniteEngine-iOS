//
//  IXControlContentView.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/22.
//  Copyright (c) 2013 All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXBaseControl;

@protocol IXControlContentViewTouchDelegate <NSObject>

@optional

-(void)controlViewTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

@end

@interface IXControlContentView : UIControl

@property (nonatomic,weak) id<IXControlContentViewTouchDelegate> controlContentViewTouchDelegate;

-(id)initWithFrame:(CGRect)frame viewTouchDelegate:(id<IXControlContentViewTouchDelegate>)touchDelegate;

@end
