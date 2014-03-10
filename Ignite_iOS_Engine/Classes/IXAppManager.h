//
//  IXAppManager.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/8/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IXEnums.h"

@class IXBaseControl;
@class IXSandbox;
@class IXViewController;
@class IXPropertyContainer;
@class IXNavigationViewController;
@class JASidePanelController;
@class Reachability;

@interface IXAppManager : NSObject

@property (nonatomic,strong) IXBaseControl* testControl;

@property (nonatomic,assign) IXAppMode appMode;

@property (nonatomic,strong) JASidePanelController* sidePanelController;
@property (nonatomic,strong) IXNavigationViewController* rootViewController;
@property (nonatomic,strong) IXViewController* rightPanel;
@property (nonatomic,strong) IXViewController* leftPanel;

@property (nonatomic,copy) NSString* appConfigPath;
@property (nonatomic,copy) NSString* appDefaultViewPath;
@property (nonatomic,copy) NSString* appDefaultViewRootPath;

@property (nonatomic,strong) IXPropertyContainer* deviceProperties;
@property (nonatomic,strong) IXPropertyContainer* appProperties;
@property (nonatomic,strong) IXPropertyContainer* sessionProperties;

@property (nonatomic,strong) NSString* appID;
@property (nonatomic,strong) NSString* bundleID;
@property (nonatomic,strong) NSString* versionNumberMajor;
@property (nonatomic,strong) NSString* versionNumberMinor;

@property (nonatomic,strong) IXSandbox* applicationSandbox;
@property (nonatomic,strong) Reachability* reachabilty;

@property (nonatomic,assign,getter = isLayoutDebuggingEnabled) BOOL layoutDebuggingEnabled;

+(IXAppManager*)sharedAppManager;
-(void)startApplication;
-(IXViewController*)currentIXViewController;

+(UIInterfaceOrientation)currentInterfaceOrientation;
-(NSString*)evaluateJavascript:(NSString*)javascript;

@end
