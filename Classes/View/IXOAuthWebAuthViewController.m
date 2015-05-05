//
//  IXOAuthWebAuthViewController.m
//  Ignite Engine
//
//  Created by Robert Walsh on 4/2/14.
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

#import "IXOAuthWebAuthViewController.h"
#import "IXLogger.h"
#import "SVWebViewController.h"

@interface IXSVWebViewController : SVWebViewController

@end

@interface IXOAuthWebAuthViewController ()

-(void)doneButtonClicked:(id)sender;

@end

@interface SVWebViewController ()

- (void)doneButtonClicked:(id)sender;

@end

@interface IXSVWebViewController ()

@end

@implementation IXSVWebViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)doneButtonClicked:(id)sender {
    [((IXOAuthWebAuthViewController*)[self navigationController]) doneButtonClicked:sender];
}

@end

@interface SVModalWebViewController ()

@property (nonatomic, strong) SVWebViewController *webViewController;

@end

@interface SVWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@interface IXOAuthWebAuthViewController () <UIWebViewDelegate>

@property (nonatomic,strong) UIWebView* webView;

@end

@implementation IXOAuthWebAuthViewController

- (void)dealloc
{
    [_webView setDelegate:nil];
}

- (id)initWithURL:(NSURL *)URL {
    self.webViewController = [[IXSVWebViewController alloc] initWithURL:URL];
    if (self = [super initWithRootViewController:self.webViewController]) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                    target:self.webViewController
                                                                                    action:@selector(doneButtonClicked:)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.webViewController.navigationItem.leftBarButtonItem = doneButton;
        else
            self.webViewController.navigationItem.rightBarButtonItem = doneButton;
    }
    return self;
}

- (instancetype)initWithDelegate:(id<IXOAuthWebAuthViewControllerDelegate>)ixOAuthDelegate
                   accessCodeURL:(NSURL*)accessCodeURL
                     redirectURI:(NSURL*)redirectURI
{
    self = [self initWithURL:accessCodeURL];
    if( self )
    {
        _ixOAuthDelegate = ixOAuthDelegate;
        _accessCodeURL = [accessCodeURL copy];
        _redirectURI = [redirectURI copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webViewController.webView.delegate = self;
    
    IX_LOG_VERBOSE(@"Trying authentication to OAuth2.0 Access Code URL : %@",[[self accessCodeURL] absoluteString]);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[self webViewController] webView:webView didFailLoadWithError:error];
//    if( [[self ixOAuthDelegate] respondsToSelector:@selector(ixOAuthWebAuthViewController:didFailWithError:)] )
//    {
//        [[self ixOAuthDelegate] ixOAuthWebAuthViewController:self didFailWithError:error];
//    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[self webViewController] webViewDidStartLoad:webView];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[self webViewController] webViewDidFinishLoad:webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] absoluteString] hasPrefix:[[self redirectURI] absoluteString]] )
    {
        NSString* requestURLString = [[request URL] absoluteString];
        NSArray* queryParamsStrings = nil;

        NSRange rangeOfQuestionMarkInURL = [requestURLString rangeOfString:@"?"];
        if( rangeOfQuestionMarkInURL.location != NSNotFound )
        {
            NSString* queryParamStringAllTogether = [requestURLString stringByReplacingCharactersInRange:NSMakeRange(0, rangeOfQuestionMarkInURL.location + 1) withString:@""];
            queryParamsStrings = [queryParamStringAllTogether componentsSeparatedByString:@"&"];
        }
        else
        {
            NSRange rangeOfPoundSignInURL = [requestURLString rangeOfString:@"#"];
            if( rangeOfPoundSignInURL.location != NSNotFound )
            {
                NSString* queryParamStringAllTogether = [requestURLString stringByReplacingCharactersInRange:NSMakeRange(0, rangeOfPoundSignInURL.location + 1) withString:@""];
                queryParamsStrings = [queryParamStringAllTogether componentsSeparatedByString:@"&"];
            }
        }

        NSMutableDictionary* paramDictionary = nil;
        if( [queryParamsStrings count] > 0 )
        {
            paramDictionary = [NSMutableDictionary dictionary];
            for( NSString* paramString in queryParamsStrings )
            {
                NSArray* paramStringComponents = [paramString componentsSeparatedByString:@"="];
                [paramDictionary setObject:[paramStringComponents lastObject] forKey:[paramStringComponents firstObject]];
            }
        }

        NSString* oauthCode = paramDictionary[@"code"];
        NSString* oauthToken = paramDictionary[@"access_token"];

        if( [oauthCode length] > 0 )
        {
            if( [[self ixOAuthDelegate] respondsToSelector:@selector(ixOAuthWebAuthViewController:didRecieveOAuthCode:)] )
            {
                [[self ixOAuthDelegate] ixOAuthWebAuthViewController:self didRecieveOAuthCode:oauthCode];
            }
        }
        else if( [oauthToken length] > 0 )
        {        
            if( [[self ixOAuthDelegate] respondsToSelector:@selector(ixOAuthWebAuthViewController:didRecieveOAuthToken:tokenType:expires:refreshToken:)] )
            {
                NSDate* expirationDate = nil;
                NSString* expiresInString = paramDictionary[@"expires_in"];
                if( [expiresInString length] > 0 ) {
                    expirationDate = [NSDate dateWithTimeIntervalSinceNow:[expiresInString doubleValue]];
                }
                [[self ixOAuthDelegate] ixOAuthWebAuthViewController:self
                                                didRecieveOAuthToken:oauthToken
                                                           tokenType:paramDictionary[@"token_type"]
                                                             expires:expirationDate
                                                        refreshToken:paramDictionary[@"refresh_token"]];
            }
        }
        else
        {
            if( [[self ixOAuthDelegate] respondsToSelector:@selector(ixOAuthWebAuthViewController:didFailWithError:)] )
            {
                [[self ixOAuthDelegate] ixOAuthWebAuthViewController:self didFailWithError:[NSError errorWithDomain:@"No access code found in query params." code:0 userInfo:nil]];
            }
        }
        
        return NO;
    }
	return YES;
}

-(void)doneButtonClicked:(id)sender
{
    if( [[self ixOAuthDelegate] respondsToSelector:@selector(ixOAuthWebAuthViewController:didFailWithError:)] )
    {
        [[self ixOAuthDelegate] ixOAuthWebAuthViewController:self didFailWithError:[NSError errorWithDomain:@"User pressed the done button" code:0 userInfo:nil]];
    }
}

@end
