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
 *      Date:     42034
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
 */

/**
 
 A menu that is presented from the bottom of the screen and gives the user the ability to select from several buttons.
 

 <div id="container">
 <ul>
 <li><a href="../images/IXScanner_0.png" data-imagelightbox="c"><img src="../images/IXScanner_0.png"></a></li>
 <li><a href="../images/IXScanner_1.png" data-imagelightbox="c"><img src="../images/IXScanner_1.png"></a></li>
 <li><a href="../images/IXScanner_2.png" data-imagelightbox="c"><img src="../images/IXScanner_2.png"></a></li>
 </ul>
</div>
 
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

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>
 
 @param auto_close Automatically close the Scanner view controller upon scan? *(default: TRUE)*<br>*(bool)*
 
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
 
 @param data Data contained in the scanned code<br>*(string)*
 
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

 
 @param scanned Fires when a code is scanned successfully
 
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
 
 </pre>

*/

-(void)example
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
