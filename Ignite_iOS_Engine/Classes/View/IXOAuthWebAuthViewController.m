//
//  IXOAuthWebAuthViewController.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 4/2/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
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
        NSString* oauthCode = nil;
        NSString* requestURLString = [[request URL] absoluteString];
        NSRange rangeOfQuestionMarkInURL = [requestURLString rangeOfString:@"?"];
        if( rangeOfQuestionMarkInURL.location != NSNotFound )
        {
            NSString* queryParamStringAllTogether = [requestURLString stringByReplacingCharactersInRange:NSMakeRange(0, rangeOfQuestionMarkInURL.location + 1) withString:@""];
            NSArray *queryParamsStrings = [queryParamStringAllTogether componentsSeparatedByString:@"&"];
            
            if( [queryParamsStrings count] > 0 )
            {
                for( NSString* paramString in queryParamsStrings )
                {
                    NSArray* paramStringComponents = [paramString componentsSeparatedByString:@"="];
                    if( [[paramStringComponents firstObject] isEqualToString:@"code"] )
                    {
                        oauthCode = [[paramStringComponents lastObject] copy];
                        break;
                    }
                }
            }
            
        }
        
        if( [oauthCode length] > 0 )
        {
            if( [[self ixOAuthDelegate] respondsToSelector:@selector(ixOAuthWebAuthViewController:didRecieveOAuthCode:)] )
            {
                [[self ixOAuthDelegate] ixOAuthWebAuthViewController:self didRecieveOAuthCode:oauthCode];
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
