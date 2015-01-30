//
//  IXScannerControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/17/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Native iOS UI control that displays a menu from the bottom of the screen.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name       | Type     | Description                                                | Default |
 |------------|----------|------------------------------------------------------------|---------|
 | auto_close | *(bool)* | Automatically close the Scanner view controller upon scan? | true    |
 

 ##  <a name="readonly">Read Only Attributes</a>
 
 | Name                 | Type       | Description                                                      |
 |----------------------|------------|------------------------------------------------------------------|
 | data                 | *(string)* | Data contained in the scanned code                               |
 
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

 | Name                 | Description                                         |
 |----------------------|-----------------------------------------------------|
 | scanned              | Fires when a code is scanned successfully           |
 

 ##  <a name="functions">Functions</a>
 
Present Scanner view controller: *present_reader*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "scannerTest",
        "function_name": "start_animation"
      }
    }

Dismiss Scanner view controller: *dismiss_reader*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "scannerTest",
        "function_name": "dismiss_reader"
      }
    }
 
 ##  <a name="example">Example JSON</a> 
 
   
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXScanner.h"
#import "ZBarSDK.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

IX_STATIC_CONST_STRING kIXScannedData = @"data";

static ZBarReaderViewController* sReaderViewController = nil;

@interface  IXScanner() <ZBarReaderDelegate>

@property (nonatomic,assign,getter = shouldAutoClose) BOOL autoClose;
@property (nonatomic,copy) NSString* scannedData;

@end

@implementation IXScanner

-(void)dealloc
{
    [self closeReader:NO];
}

-(void)buildView
{
    // Overriden without super call because we don't want/need a view for this widget.

    if( !sReaderViewController )
    {
        sReaderViewController = [ZBarReaderViewController new];
        [sReaderViewController setTakesPicture:NO];
        [sReaderViewController setTracksSymbols:YES];
        [sReaderViewController setShowsZBarControls:YES];
        [sReaderViewController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
        [[sReaderViewController scanner] setSymbology:ZBAR_I25
                                               config:ZBAR_CFG_ENABLE
                                                   to:0];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    [self setAutoClose:[[self propertyContainer] getBoolPropertyValue:@"auto_close" defaultValue:YES]];
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    if( [functionName isEqualToString:@"present_reader"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [self presentReader:animated];
    }
    else if( [functionName isEqualToString:@"dismiss_reader"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [self closeReader:animated];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString *)getReadOnlyPropertyValue:(NSString *)propertyName
{
    if([propertyName isEqualToString:kIXScannedData]) {
        return [[self scannedData] copy];
    } else {
        return [super getReadOnlyPropertyValue:propertyName];
    }
}

-(void)closeReader:(BOOL)animated
{
    if( [sReaderViewController readerDelegate] == self )
    {
        [sReaderViewController setReaderDelegate:nil];
        if( ![sReaderViewController isBeingPresented] && ![sReaderViewController isBeingDismissed] && [sReaderViewController presentingViewController] )
        {
            [sReaderViewController dismissViewControllerAnimated:animated completion:nil];
        }
    }
}

-(void)presentReader:(BOOL)animated
{
    if( ![sReaderViewController isBeingPresented] && ![sReaderViewController isBeingDismissed] && ![sReaderViewController presentingViewController] )
    {
        [sReaderViewController setReaderDelegate:self];
        [[[IXAppManager sharedAppManager] rootViewController] presentViewController:sReaderViewController animated:animated completion:nil];
    }
}

- (void)imagePickerController: (UIImagePickerController*)reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    if(info != nil)
    {
        id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for (symbol in results)
            break;

        [self setScannedData:[symbol data]];
        [[self actionContainer] executeActionsForEventNamed:@"scanned"];
    }
    
    if([self shouldAutoClose])
    {
        [self closeReader:YES];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [self closeReader:YES];
}

@end
