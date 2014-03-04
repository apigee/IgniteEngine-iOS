//
//  IXControlContentView.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/22/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXBaseControl;
@class IXPropertyContainer;

@protocol IXControlContentViewTouchDelegate <NSObject>

@optional

-(void)controlViewTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)controlViewTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

-(void)controlViewTapGestureRecognized:(UITapGestureRecognizer*)tapGestureRecognizer;
-(void)controlViewSwipeGestureRecognized:(UISwipeGestureRecognizer*)swipeGestureRecognizer;
-(void)controlViewPinchGestureRecognized:(UIPinchGestureRecognizer*)pinchGestureRecognizer;

@end

@interface IXControlContentView : UIControl

@property (nonatomic,weak) id<IXControlContentViewTouchDelegate> controlContentViewTouchDelegate;

-(id)initWithFrame:(CGRect)frame viewTouchDelegate:(id<IXControlContentViewTouchDelegate>)touchDelegate;

-(void)beginListeningForTapGestures;
-(void)beginListeningForSwipeGestures;
-(void)beginListeningForPinchGestures;
-(void)stopListeningForTapGestures;
-(void)stopListeningForSwipeGestures;
-(void)stopListeningForPinchGestures;

@end
