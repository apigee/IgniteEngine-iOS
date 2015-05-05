//
//  IXBrowserControl.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/16/13.
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
//

#import "IXBrowser.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

#import "SVWebViewController.h"

// Attributes
IX_STATIC_CONST_STRING kIXUrl = @"url";
IX_STATIC_CONST_STRING kIXHTMLString = @"html";
IX_STATIC_CONST_STRING kIXHTMLBaseURL = @"html.baseUrl";

// Events
IX_STATIC_CONST_STRING kIXStarted = @"started";
IX_STATIC_CONST_STRING kIXFailed = @"error";
IX_STATIC_CONST_STRING kIXFinished = @"done";

@interface  IXBrowser() <UIWebViewDelegate>

@property (nonatomic,strong) SVWebViewController *webViewController;

@property UIWebView *webview;

@end

@interface SVWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation IXBrowser

/***************************************************************/

/** This control has the following attributes:

    @param url The URL to load<br>*(string)*
    @param html.string Load string of HTML<br>*(string)*
    @param html.base_url Base URL when using HTML string<br>*(string)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:
*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:

    @param started Page load initiated.
    @param failed Page failed to load.
    @param finished Page loaded successfully.

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


*/

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!

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

-(void)Example
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

    NSString* urlString = [[self attributeContainer] getPathValueForAttribute:kIXUrl basePath:nil defaultValue:nil];
    NSString* htmlString = [[self attributeContainer] getStringValueForAttribute:kIXHTMLString defaultValue:nil];

    if( [urlString length] > 0 )
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

        [[self webview] loadRequest:request];
    }
    else if( [htmlString length] > 0 )
    {
        NSString* htmlBaseURLString = [[self attributeContainer] getStringValueForAttribute:kIXHTMLBaseURL defaultValue:nil];
        NSURL* baseURL = nil;
        if( [htmlBaseURLString length] > 0 ) {
            baseURL = [NSURL URLWithString:htmlBaseURLString];
        }

        [[self webview] loadHTMLString:htmlString baseURL:baseURL];
    }
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXAttributeContainer*)parameterContainer
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
