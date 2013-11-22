//
//  IXBrowserControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16.
//  Copyright (c) 2013 All rights reserved.
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


@interface  IXBrowser()

@property UIWebView *webview;

@property (nonatomic,strong) SVModalWebViewController *modalWebViewController;

@end

@implementation IXBrowser



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
    
    NSString* displayMode = [[self propertyContainer] getStringPropertyValue:@"mode" defaultValue:@"default"];
    
    _webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [[self propertyContainer] getFloatPropertyValue:@"width" defaultValue:320.0f], [[self propertyContainer] getFloatPropertyValue:@"height" defaultValue:180.0f])];
    NSString *url=[[self propertyContainer] getStringPropertyValue:@"url" defaultValue:nil];
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [_webview loadRequest:nsrequest];
    
    [[self contentView] addSubview:_webview];
    
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    
    NSLog(@"modal, bitches!");

}



//-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
//{
//    
//    if( [functionName compare:@"modal"] == NSOrderedSame )
//    {
//        NSLog(@"modal, bitches!");
//        NSString* url = [parameterContainer getStringPropertyValue:@"url" defaultValue:nil];
//        NSURL *URL = [NSURL URLWithString:url];
//        //
//        _modalWebViewController = [[SVModalWebViewController alloc] initWithURL:URL];
//        [[[IXAppManager sharedInstance] rootViewController] presentViewController:_modalWebViewController animated:YES completion:NULL];
//    }
//    
//}

@end
