//
//  IXBrowserControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//
 //
/*
 
 CONTROL
 /--------------------/
 - TYPE : "IXBrowserControl"
 - DESCRIPTION: "IXBrowserControl Description."
 /--------------------/
 - PROPERTIES
 /--------------------/
 * name=""        default=""               type="___"
 /--------------------/
 - EVENTS
 /--------------------/
 * name="share_done"
 * name="share_cancelled"
 /--------------------/
 - Example
 /--------------------/

 {
    "type": "Media",
    "properties": {
        "id": "myMedia",
        "source": "library"
    }
 }
 
 /--------------------/
 - Changelog
 /--------------------/
 
 /--------------------/
 */



#import "IXBrowser.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

#import "SVWebViewController.h"


@interface  IXBrowser() <UIWebViewDelegate>


@property (nonatomic,strong) SVWebViewController *webViewController;

@property UIWebView *webview;

@end

@interface SVWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation IXBrowser

IX_STATIC_CONST_STRING kIXUrl = @"url";

-(void)buildView
{
    [super buildView];
    
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)applySettings
{
    [super applySettings];
    
    
 
//    NSString* displayMode = [[self propertyContainer] getStringPropertyValue:@"mode" defaultValue:@"default"];
    
    _webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [[self propertyContainer] getFloatPropertyValue:@"width" defaultValue:320.0f], [[self propertyContainer] getFloatPropertyValue:@"height" defaultValue:180.0f])];
   
    [_webview setDelegate:self];
    
    //NSString *url=[[self propertyContainer] getStringPropertyValue:@"url" defaultValue:nil];
    
    
    
    //NSURL *nsurl=[NSURL URLWithString:url];
    
    NSURL* nsurl = [[self propertyContainer] getURLPathPropertyValue:kIXUrl basePath:nil defaultValue:nil];
    
//    NSString* jsonRootPath = nil;
//    if( [IXPathHandler pathIsLocal:url] ) {
//        jsonRootPath = [url stringByDeletingLastPathComponent];
//    } else {
//        jsonRootPath = [[[NSURL URLWithString:url] URLByDeletingLastPathComponent] absoluteString];
//    }
    
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    _webview.opaque = NO;
    [_webview setBackgroundColor:[UIColor clearColor]];
    [_webview loadRequest:nsrequest];
    
    [[self contentView] addSubview:_webview];
    
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    

}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[self webViewController] webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[self webViewController] webViewDidFinishLoad:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[self webViewController] webView:webView didFailLoadWithError:error];
}


@end
