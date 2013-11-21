//
//  ixeViewController.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import <UIKit/UIKit.h>

@class ixeSandbox;
@class ixeLayout;
@class ixePropertyContainer;
@class ixeActionContainer;
@class ixeTextInput;

@interface ixeViewController : UIViewController

@property (nonatomic,strong) ixeSandbox* sandbox;
@property (nonatomic,strong) ixeLayout* containerControl;
@property (nonatomic,strong) ixePropertyContainer* propertyContainer;
@property (nonatomic,strong) ixeActionContainer* actionContainer;

@end
