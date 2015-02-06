//
//  IXScannerControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/17/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     	1/28/2015
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/** A menu that is presented from the bottom of the screen and gives the user the ability to select from several buttons.
*/

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

/***************************************************************/

/** This control has the following attributes:
 
 @param auto_close Automatically close the Scanner view controller upon scan? *(default: TRUE)*<br>*(bool)*
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:
 
 @param data Data contained in the scanned code<br>*(string)*
 
 */

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:

 
 @param scanned Fires when a code is scanned successfully
 
*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:

 
 @param present_reader Present Scanner view controller
 
<pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "scannerTest",
    "function_name": "present_reader"
  }
}

</pre>
 
 @param dismiss_reader Dismiss Scanner view controller
 
  <pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "scannerTest",
    "function_name": "dismiss_reader"
  }
}
 </pre>
 
 */

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!

  <pre class="brush: js; toolbar: false;">
 
 </pre>

*/

-(void)Example
{
}

/***************************************************************/




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
