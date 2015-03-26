//
//  IXMediaControl.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXMediaPicker.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "IXLogger.h"

#import "UIImagePickerController+IXAdditions.h"
#import "UIViewController+IXAdditions.h"

#import <MobileCoreServices/MobileCoreServices.h>

// IXMediaSource Attributes
IX_STATIC_CONST_STRING kIXCameraSource = @"cameraSource";
IX_STATIC_CONST_STRING kIXCameraControlsEnabled = @"cameraControls.enabled";
IX_STATIC_CONST_STRING kIXSource = @"source";

// IXMediaSource Attribute Options
IX_STATIC_CONST_STRING kIXSourceCamera = @"camera";
IX_STATIC_CONST_STRING kIXSourceLibrary = @"library";
IX_STATIC_CONST_STRING kIXCameraFront = @"front";
IX_STATIC_CONST_STRING kIXCameraRear = @"rear";

// IXMediaSource Events
IX_STATIC_CONST_STRING kIXDidLoadMedia = @"didLoadMedia";
IX_STATIC_CONST_STRING kIXError = @"error";
IX_STATIC_CONST_STRING kIXSuccess = @"success";

// IXMediaSource Functions
IX_STATIC_CONST_STRING kIXDismiss = @"dismiss";
IX_STATIC_CONST_STRING kIXPresent = @"present";

// IXMediaSource Returns
IX_STATIC_CONST_STRING kIXSelectedMedia = @"selectedMedia";

@interface  IXMediaPicker() <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) NSString* sourceTypeString;
@property (nonatomic,strong) NSString* cameraDeviceString;
@property (nonatomic,assign) UIImagePickerControllerSourceType pickerSourceType;
@property (nonatomic,assign) UIImagePickerControllerCameraDevice pickerDevice;
@property (nonatomic,strong) UIImagePickerController* imagePickerController;
@property (nonatomic,strong) NSURL* selectedMedia;
@property (nonatomic) BOOL showCameraControls;

@end

@implementation IXMediaPicker

-(void)dealloc
{
    [_imagePickerController setDelegate:nil];
    [self dismissPickerController:NO];
}

-(void)buildView
{
    _imagePickerController = [[UIImagePickerController alloc] init];
    [_imagePickerController setDelegate:self];
}

-(void)applySettings
{
    [super applySettings];
    
    [self setSourceTypeString:[[self propertyContainer] getStringPropertyValue:kIXSource defaultValue:kIXSourceCamera]];
    [self setCameraDeviceString:[[self propertyContainer] getStringPropertyValue:kIXSource defaultValue:kIXCameraRear]];
    [self setShowCameraControls:[[self propertyContainer] getBoolPropertyValue:kIXCameraControlsEnabled defaultValue:YES]];
    
    [self setPickerSourceType:[UIImagePickerController stringToSourceType:[self sourceTypeString]]];
    [self setPickerDevice:[UIImagePickerController stringToCameraDevice:[self cameraDeviceString]]];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXPresent] )
    {
        if( [[self imagePickerController] presentingViewController] == nil )
        {
            [self configurePickerController];
            
            BOOL animated = YES;
            if( parameterContainer ) {
                animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
            }
            
            [self presentPickerController:animated];
        }
    }
    else if( [functionName isEqualToString:kIXDismiss] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        
        [self dismissPickerController:animated];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)configurePickerController
{
    if( [UIImagePickerController isSourceTypeAvailable:[self pickerSourceType]] && [[self imagePickerController] presentingViewController] == nil )
    {
        [[self imagePickerController] setSourceType:[self pickerSourceType]];
        
        if (self.showCameraControls == NO)
            self.imagePickerController.showsCameraControls = NO;
        
        if( [[self sourceTypeString] isEqualToString:@"video"] )
        {
            //deprecated in 3.1, why do we need this?
            //[[self imagePickerController] setAllowsEditing:NO];
            [[self imagePickerController] setMediaTypes:@[(NSString*)kUTTypeMovie]];
        }
    }
}

-(void)presentPickerController:(BOOL)animated
{
    if( [UIViewController isOkToPresentViewController:[self imagePickerController]] )
    {
        [[[IXAppManager sharedAppManager] rootViewController] presentViewController:self.imagePickerController
                                                                         animated:UIViewAnimationOptionAllowAnimatedContent
                                                                       completion:nil];
    }
}

-(void)dismissPickerController:(BOOL)animated
{
    if( [UIViewController isOkToDismissViewController:self.imagePickerController] )
    {
        [_imagePickerController dismissViewControllerAnimated:animated completion:nil];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXSelectedMedia] )
    {
        if( self.selectedMedia )
        {
            returnValue = [NSString stringWithFormat:@"%@", self.selectedMedia];
        }
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.selectedMedia = info[UIImagePickerControllerReferenceURL];
    
    [[[IXAppManager sharedAppManager] rootViewController] dismissViewControllerAnimated:YES completion:nil];
    IX_LOG_VERBOSE(@"Successfully loaded media at %@", info[UIImagePickerControllerReferenceURL]);
    
    if(info != nil)
    {
        [self.actionContainer executeActionsForEventNamed:kIXSuccess];
    }
    else
    {
        [self.actionContainer executeActionsForEventNamed:kIXError];
    }
}



@end
