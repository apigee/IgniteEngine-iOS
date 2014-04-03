//
//  IXOAuthWebAuthViewController.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 4/2/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXOAuthWebAuthViewController;

@protocol IXOAuthWebAuthViewControllerDelegate <NSObject>

@optional

- (void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                 didRecieveOAuthCode:(NSString *)accessToken;

- (void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                    didFailWithError:(NSError *)error;

@end

@interface IXOAuthWebAuthViewController : UIViewController

@property (nonatomic,weak,readonly) id<IXOAuthWebAuthViewControllerDelegate> delegate;
@property (nonatomic,copy,readonly) NSURL* accessCodeURL;
@property (nonatomic,copy,readonly) NSURL* redirectURI;

- (instancetype)initWithDelegate:(id<IXOAuthWebAuthViewControllerDelegate>)delegate
                   accessCodeURL:(NSURL*)accessCodeURL
                     redirectURI:(NSURL*)redirectURI;

@end
