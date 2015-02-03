//
//  IXBrowserControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     42034
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/**
 
  A basic UIWebView that allows you to render a HTML string or a URL.
 

 <div id="container">
<a href="../images/IXBrowser.png" data-imagelightbox="c"><img src="../images/IXBrowser.png" alt=""></a>
</div>
 
 
*/

/*
 *      /Docs
 *
*/


#import "IXBrowser.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

#import "SVWebViewController.h"

// IXBrowser Attributes
IX_STATIC_CONST_STRING kIXUrl = @"url";
IX_STATIC_CONST_STRING kIXHTMLString = @"html.string";
IX_STATIC_CONST_STRING kIXHTMLBaseURL = @"html.base_url";

// IXBrowser Events
IX_STATIC_CONST_STRING kIXStarted = @"started";
IX_STATIC_CONST_STRING kIXFailed = @"failed";
IX_STATIC_CONST_STRING kIXFinished = @"finished";

@interface  IXBrowser() <UIWebViewDelegate>

@property (nonatomic,strong) SVWebViewController *webViewController;

@property UIWebView *webview;

@end

@interface SVWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation IXBrowser

/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

    @param url The URL to load<br>*(string)*
    @param html.string Load string of HTML<br>*(string)*
    @param html.base_url Base URL when using HTML string<br>*(string)*

*/

-(void)attributes
{
}
/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-info">
 <i class="ti-loop"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Returns</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>
*/

-(void)returns
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-success">
 <i class="ti-pulse"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Events</h3>
 <p>This control fires the following events:</p>
 </div>
 </div>


    @param started Page load initiated.
    @param failed Page failed to load.
    @param finished Page loaded successfully.

*/

-(void)events
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-danger">
 <i class="ti-direction"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Functions</h3>
 <p>This control supports the following functions:</p>
 </div>
 </div>


*/

-(void)functions
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-primary">
 <i class="ti-shortcode"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Example</h3>
 <p>Go on, try it out!</p>
 </div>
 </div>

 <pre class="brush: js; toolbar: false;">

{
  "_id": "browserTest",
  "_type": "Browser",
  "attributes": {
    "height": "100%",
    "width": "100%",
    "url": "http://apigee.com"
  }
}
 </pre>

*/

-(void)example
{
}

/***************************************************************/

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

    [[self webview] setOpaque:NO];
    [[self webview] setBackgroundColor:[[self contentView] backgroundColor]];

    NSString* urlString = [[self propertyContainer] getPathPropertyValue:kIXUrl basePath:nil defaultValue:nil];
    NSString* htmlString = [[self propertyContainer] getStringPropertyValue:kIXHTMLString defaultValue:nil];

    if( [urlString length] > 0 )
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

        [[self webview] loadRequest:request];
    }
    else if( [htmlString length] > 0 )
    {
        NSString* htmlBaseURLString = [[self propertyContainer] getStringPropertyValue:kIXHTMLBaseURL defaultValue:nil];
        NSURL* baseURL = nil;
        if( [htmlBaseURLString length] > 0 ) {
            baseURL = [NSURL URLWithString:htmlBaseURLString];
        }

        [[self webview] loadHTMLString:htmlString baseURL:baseURL];
    }
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
