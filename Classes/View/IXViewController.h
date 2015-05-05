//
//  IXViewController.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
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
