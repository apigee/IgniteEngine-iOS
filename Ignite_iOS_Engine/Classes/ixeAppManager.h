//
//  ixeAppManager.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/8.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class ixeBaseControl;
@class ixeSandbox;
@class ixeViewController;
@class ixePropertyContainer;
@class ixeNavigationViewController;
@class JASidePanelController;

@interface ixeAppManager : NSObject

@property (nonatomic,strong) ixeBaseControl* testControl;

@property (nonatomic,strong) JASidePanelController* sidePanelController;
@property (nonatomic,strong) ixeNavigationViewController* rootViewController;
@property (nonatomic,strong) ixeViewController* rightPanel;
@property (nonatomic,strong) ixeViewController* leftPanel;

@property (nonatomic,copy) NSString* appConfigPath;
@property (nonatomic,copy) NSString* appDefaultViewPath;
@property (nonatomic,copy) NSString* appMode;

@property (nonatomic,strong) ixePropertyContainer* appProperties;
@property (nonatomic,strong) ixePropertyContainer* sessionProperties;

@property (nonatomic,strong) NSString* appID;
@property (nonatomic,strong) NSString* bundleID;
@property (nonatomic,strong) NSString* versionNumberMajor;
@property (nonatomic,strong) NSString* versionNumberMinor;

@property (nonatomic,strong) ixeSandbox* applicationSandbox;

@property (nonatomic,assign,getter = isLayoutDebuggingEnabled) BOOL layoutDebuggingEnabled;

+(ixeAppManager*)sharedInstance;
-(void)startApplication;
-(ixeViewController*)currentixeViewController;

-(void)runAlertTest;

+(UIInterfaceOrientation)currentInterfaceOrientation;
-(NSString*)evaluateJavascript:(NSString*)javascript;

@end
