//
//  IxViewController.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import <UIKit/UIKit.h>

@class IxSandbox;
@class IxLayout;
@class IxPropertyContainer;
@class IxActionContainer;
@class IxTextInput;

@interface IxViewController : UIViewController

@property (nonatomic,strong) IxSandbox* sandbox;
@property (nonatomic,strong) IxLayout* containerControl;
@property (nonatomic,strong) IxPropertyContainer* propertyContainer;
@property (nonatomic,strong) IxActionContainer* actionContainer;

@end
