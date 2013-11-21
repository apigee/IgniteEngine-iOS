//
//  IxScannerControl.m
//  Ignite iOS Engine (Ix)
//
//  Created by Jeremy Anticouni on 11/17.
//  Copyright (c) 2013 All rights reserved.
//

/*
 
 WIDGET
 /--------------------/
 - TYPE : "___"
 - DESCRIPTION: "___ Description."
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
 
 /--------------------/
 - Changelog
 /--------------------/
 
 /--------------------/
 */

#import "IxScanner.h"
#import "ZBarSDK.h"
#import "IxAppManager.h"
#import "IxNavigationViewController.h"
#import "IxViewController.h"





static ZBarReaderViewController* readerView = nil;
static ZBarCameraSimulator *cameraSim;

@interface  IxScanner() <ZBarReaderDelegate>

@end

@implementation IxScanner

-(void)buildView
{
    [super buildView];
    // the delegate receives decode results
    readerView.readerDelegate = self;
    
    // you can use this to support the simulator
    if(TARGET_IPHONE_SIMULATOR) {
        cameraSim = [[ZBarCameraSimulator alloc]
                     initWithViewController: self];
        cameraSim.readerView = readerView;
    }
}


+(void)load
{
    if(readerView == nil)
    {
        
        
        readerView = [ZBarReaderViewController new];
        readerView.tracksSymbols = YES;
        readerView.takesPicture = NO;
        readerView.showsZBarControls = YES;
        readerView.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [readerView.scanner setSymbology: ZBAR_I25
                               config: ZBAR_CFG_ENABLE
                                   to: 0];
//        // you can use this to support the simulator
//        if(TARGET_IPHONE_SIMULATOR) {
//            cameraSim = [[ZBarCameraSimulator alloc]
//                         initWithViewController: self];
//            cameraSim.readerView = readerView;
//        }
        
    }
}

-(void)closeReader
{
    if(readerView != nil)
    {
        if( ![readerView isBeingDismissed] )
            [readerView dismissViewControllerAnimated:YES completion:nil];
    }
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeZero;
}

-(void)applySettings
{
    [super applySettings];
    
    
    // the delegate receives decode results
    readerView.readerDelegate = self;
    
    // ensure initial camera orientation is correctly set
    UIApplication *app = [UIApplication sharedApplication];
    [readerView willRotateToInterfaceOrientation: app.statusBarOrientation
                                        duration: 0];
    
   

    [readerView setReaderDelegate:self];
//    [readerView setCameraOverlayView:[self overlayControl]];
    
    [[[IxAppManager sharedInstance] rootViewController] presentViewController:readerView animated:YES completion:nil];

    
//    [self.window.rootViewController presentViewController:readerView animated:YES completion:nil];
//    [readerView start];
}

- (void)imagePickerController: (UIImagePickerController*)reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    if(info != nil)
    {
        ZBarSymbolSet* symbols = [info objectForKey:ZBarReaderControllerResults];
        
        if(symbols != nil)
        {
            for(ZBarSymbol *symbol in symbols)
            {
                /* 
                 
                 Set the code type and returned data here.
                 
                 */
                break;
            }
            
            [[self actionContainer] executeActionsForEventNamed:@"scanned"];
        }
    }
    
    if([[self propertyContainer] getBoolPropertyValue:@"auto_close" defaultValue:YES])
    {
        [self closeReader];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [self closeReader];
}

/**
 The dogs current trackPosition
 */

-(void)applyFunction:(NSString*)functionName withParameters:(IxPropertyContainer*)parameterContainer
{
    
    if( [functionName compare:@"start"] == NSOrderedSame )
    {
        NSLog(@"start, bitches!");
        
    }
}


@end
