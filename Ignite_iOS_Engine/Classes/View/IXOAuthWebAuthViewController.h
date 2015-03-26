//
//  IXOAuthWebAuthViewController.h
//  Ignite Engine
//
//  Created by Robert Walsh on 4/2/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVModalWebViewController.h"

@class IXOAuthWebAuthViewController;
@class AFOAuthCredential;

@protocol IXOAuthWebAuthViewControllerDelegate <NSObject>

@optional

- (void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                 didRecieveOAuthCode:(NSString *)accessCode;

- (void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                didRecieveOAuthToken:(NSString *)accessToken
                           tokenType:(NSString *)tokenType
                             expires:(NSDate *)expires
                        refreshToken:(NSString *)refresh_token;

- (void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                    didFailWithError:(NSError *)error;

@end

@interface IXOAuthWebAuthViewController : SVModalWebViewController

@property (nonatomic,weak,readonly) id<IXOAuthWebAuthViewControllerDelegate> ixOAuthDelegate;
@property (nonatomic,copy,readonly) NSURL* accessCodeURL;
@property (nonatomic,copy,readonly) NSURL* redirectURI;

- (instancetype)initWithDelegate:(id<IXOAuthWebAuthViewControllerDelegate>)ixOAuthDelegate
                   accessCodeURL:(NSURL*)accessCodeURL
                     redirectURI:(NSURL*)redirectURI;

@end
