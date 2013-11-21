//
//  IxAppManager.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/8.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class IxBaseControl;
@class IxSandbox;
@class IxViewController;
@class IxPropertyContainer;
@class IxNavigationViewController;
@class JASidePanelController;

@interface IxAppManager : NSObject

@property (nonatomic,strong) IxBaseControl* testControl;

@property (nonatomic,strong) JASidePanelController* sidePanelController;
@property (nonatomic,strong) IxNavigationViewController* rootViewController;
@property (nonatomic,strong) IxViewController* rightPanel;
@property (nonatomic,strong) IxViewController* leftPanel;

@property (nonatomic,copy) NSString* appConfigPath;
@property (nonatomic,copy) NSString* appDefaultViewPath;
@property (nonatomic,copy) NSString* appMode;

@property (nonatomic,strong) IxPropertyContainer* appProperties;
@property (nonatomic,strong) IxPropertyContainer* sessionProperties;

@property (nonatomic,strong) NSString* appID;
@property (nonatomic,strong) NSString* bundleID;
@property (nonatomic,strong) NSString* versionNumberMajor;
@property (nonatomic,strong) NSString* versionNumberMinor;

@property (nonatomic,strong) IxSandbox* applicationSandbox;

@property (nonatomic,assign,getter = isLayoutDebuggingEnabled) BOOL layoutDebuggingEnabled;

+(IxAppManager*)sharedInstance;
-(void)startApplication;
-(IxViewController*)currentIxViewController;

-(void)runAlertTest;

+(UIInterfaceOrientation)currentInterfaceOrientation;
-(NSString*)evaluateJavascript:(NSString*)javascript;

@end
