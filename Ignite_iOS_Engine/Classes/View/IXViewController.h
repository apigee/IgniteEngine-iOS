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
@class IXViewController;

typedef void(^IXViewControllerCreationCompletionBlock)(BOOL didSucceed, IXViewController* viewController, NSError* error);

@interface IXViewController : UIViewController

@property (nonatomic,strong,readonly) IXSandbox* sandbox;
@property (nonatomic,strong,readonly) IXLayout* containerControl;

+(instancetype)viewControllerWithPathToJSON:(NSString*)pathToJSON
                                  loadAsync:(BOOL)loadAsync
                            completionBlock:(IXViewControllerCreationCompletionBlock)completionBlock;

-(void)fireViewEventNamed:(NSString*)eventName;
-(NSString*)getViewPropertyNamed:(NSString*)propertyName;

@end
