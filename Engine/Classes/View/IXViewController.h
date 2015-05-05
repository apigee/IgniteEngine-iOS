//
//  IXViewController.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXSandbox;
@class IXLayout;
@class IXAttributeContainer;
@class IXActionContainer;
@class IXTextInput;
@class IXViewController;

extern NSString* IXViewControllerDidRecieveRemoteControlEventNotification;
extern NSString* IXViewControllerRemoteControlEventNotificationUserInfoEventKey;

typedef void(^IXViewControllerCreationCompletionBlock)(BOOL didSucceed, IXViewController* viewController, NSError* error);

@interface IXViewController : UIViewController <NSCoding>

@property (nonatomic,strong,readonly) IXSandbox* sandbox;
@property (nonatomic,strong,readonly) IXLayout* containerControl;

/**
 *  Creates and loads a view controller configuring it and its containerControl 
 *  based on the JSON configuration at the path specified.
 *
 *  @param pathToJSON      The path to the JSON configuration used to configure the view controller
 *  @param loadAsync       If YES all of the view controller loading will be done in the background.
 *  @param completionBlock The block that will be executed on completion of the view contoller being created or failing.
 */
+(void)createViewControllerWithPathToJSON:(NSString*)pathToJSON
                                loadAsync:(BOOL)loadAsync
                          completionBlock:(IXViewControllerCreationCompletionBlock)completionBlock;
/**
 *  Applies only the attributes that affect the view controller.  
 *  Does not call applySettings on its containerControl.
 */
-(void)applyViewControllerSpecificSettings;

-(void)fireViewEventNamed:(NSString*)eventName;
-(NSString*)getViewPropertyNamed:(NSString*)propertyName;
-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer;

@end
