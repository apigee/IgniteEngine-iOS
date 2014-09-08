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

// IXBrowser Events
IX_STATIC_CONST_STRING kIXStarted = @"started";
IX_STATIC_CONST_STRING kIXFailed = @"failed";
IX_STATIC_CONST_STRING kIXFinished = @"finished";


-(void)dealloc
{
    [_webview setDelegate:nil];
}

-(void)buildView
{
    [super buildView];

    _webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 100,100)];
    [_webview setDelegate:self];
    [[self contentView] addSubview:_webview];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [_webview setFrame:rect];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)applySettings
{
    [super applySettings];
    
    
 
//    NSString* displayMode = [[self propertyContainer] getStringPropertyValue:@"mode" defaultValue:@"default"];

    //NSString *url=[[self propertyContainer] getStringPropertyValue:@"url" defaultValue:nil];
    
    
    
    //NSURL *nsurl=[NSURL URLWithString:url];

    _webview.opaque = NO;
    [_webview setBackgroundColor:[[self contentView] backgroundColor]];

    NSString* urlString = [[self propertyContainer] getPathPropertyValue:kIXUrl basePath:nil defaultValue:nil];
    NSURL* url = [NSURL URLWithString:urlString];
    
//    NSString* jsonRootPath = nil;
//    if( [IXPathHandler pathIsLocal:url] ) {
//        jsonRootPath = [url stringByDeletingLastPathComponent];
//    } else {
//        jsonRootPath = [[[NSURL URLWithString:url] URLByDeletingLastPathComponent] absoluteString];
//    }
    
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:url];
    [_webview loadRequest:nsrequest];
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    

}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[self webViewController] webViewDidStartLoad:webView];
    [[self actionContainer] executeActionsForEventNamed:kIXStarted];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[self webViewController] webViewDidFinishLoad:webView];
    [[self actionContainer] executeActionsForEventNamed:kIXFinished];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [[self webViewController] webView:webView didFailLoadWithError:error];
    [[self actionContainer] executeActionsForEventNamed:kIXFinished];
}


@end
