//
//  IXScannerControl.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/17/13.
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

#import "IXScanner.h"
#import "ZBarSDK.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

IX_STATIC_CONST_STRING kIXAutoClose = @"autoClose.enabled";
IX_STATIC_CONST_STRING kIXSuccess = @"success";
IX_STATIC_CONST_STRING kIXDismiss = @"dismiss";
IX_STATIC_CONST_STRING kIXPresent = @"present";
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
    
    [self setAutoClose:[[self attributeContainer] getBoolValueForAttribute:kIXAutoClose defaultValue:YES]];
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXAttributeContainer*)parameterContainer
{
    if( [functionName isEqualToString:kIXPresent] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolValueForAttribute:kIX_ANIMATED defaultValue:animated];
        }
        [self presentReader:animated];
    }
    else if( [functionName isEqualToString:kIXDismiss] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolValueForAttribute:kIX_ANIMATED defaultValue:animated];
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
        [[self actionContainer] executeActionsForEventNamed:kIXScannedData];
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
