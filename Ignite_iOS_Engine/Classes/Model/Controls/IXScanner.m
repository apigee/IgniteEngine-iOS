//
//  IXScannerControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/17/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
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
    
    [self setAutoClose:[[self propertyContainer] getBoolPropertyValue:kIXAutoClose defaultValue:YES]];
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    if( [functionName isEqualToString:kIXPresent] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [self presentReader:animated];
    }
    else if( [functionName isEqualToString:kIXDismiss] )
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
