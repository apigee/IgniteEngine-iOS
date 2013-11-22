//
//  IXViewController.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXSandbox;
@class IXLayout;
@class IXPropertyContainer;
@class IXActionContainer;
@class IXTextInput;

@interface IXViewController : UIViewController

@property (nonatomic,strong) IXSandbox* sandbox;
@property (nonatomic,strong) IXLayout* containerControl;
@property (nonatomic,strong) IXPropertyContainer* propertyContainer;
@property (nonatomic,strong) IXActionContainer* actionContainer;

@end
