//
//  IXOAuthWebAuthViewController.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 4/2/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXOAuthWebAuthViewController.h"
#import "IXLogger.h"

@interface IXOAuthWebAuthViewController () <UIWebViewDelegate>

@property (nonatomic,strong) UIWebView* webView;

@end

@implementation IXOAuthWebAuthViewController

- (void)dealloc
{
    [_webView setDelegate:nil];
}

- (instancetype)initWithDelegate:(id<IXOAuthWebAuthViewControllerDelegate>)delegate
                   accessCodeURL:(NSURL*)accessCodeURL
                     redirectURI:(NSURL*)redirectURI
{
    self = [super initWithNibName:nil bundle:nil];
    if( self )
    {
        _delegate = delegate;
        _accessCodeURL = [accessCodeURL copy];
        _redirectURI = [redirectURI copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:[[self view] frame]];
    [webView setDelegate:self];
    [[self view] addSubview:webView];
    
    DDLogVerbose(@"Trying authentication to OAuth2.0 Access Code URL : %@",[[self accessCodeURL] absoluteString]);

    [webView loadRequest:[NSURLRequest requestWithURL:[self accessCodeURL]]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if( [[self delegate] respondsToSelector:@selector(ixOAuthWebAuthViewController:didFailWithError:)] )
    {
        [[self delegate] ixOAuthWebAuthViewController:self didFailWithError:error];
    }
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
            NSString* queryParamStringAllTogether = [requestURLString stringByReplacingCharactersInRange:NSMakeRange(0, rangeOfQuestionMarkInURL.location) withString:@""];
            NSArray *queryParamsStrings = [queryParamStringAllTogether componentsSeparatedByString:@"&"];
            
            if( [queryParamsStrings count] > 0 )
            {
                for( NSString* paramString in queryParamsStrings )
                {
                    NSArray* paramStringComponents = [paramString componentsSeparatedByString:@"="];
                    if( [[paramStringComponents firstObject] isEqualToString:@"code"] )
                    {
                        oauthCode = [[paramStringComponents lastObject] copy];
                    }
                }
            }
            
        }
        
        if( [oauthCode length] > 0 )
        {
            if( [[self delegate] respondsToSelector:@selector(ixOAuthWebAuthViewController:didRecieveOAuthCode:)] )
            {
                [[self delegate] ixOAuthWebAuthViewController:self didRecieveOAuthCode:oauthCode];
            }
        }
        else
        {
            if( [[self delegate] respondsToSelector:@selector(ixOAuthWebAuthViewController:didFailWithError:)] )
            {
                [[self delegate] ixOAuthWebAuthViewController:self didFailWithError:[NSError errorWithDomain:@"No access code found in query params." code:0 userInfo:nil]];
            }
        }
        
        return NO;
    }
	return YES;
}

@end
