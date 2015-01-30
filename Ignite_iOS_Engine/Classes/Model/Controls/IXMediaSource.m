//
//  IXMediaControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
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
 
 ###    Native iOS UI control to select image from device Library or Camera.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name                              | Type                | Description                         | Default |
 |-----------------------------------|---------------------|-------------------------------------|---------|
 | source                            | *camera<br>library* | Style of controls to use            |         |
 | camera                            | *front<br>rear*     | Color of the player UI              |         |
 | show_camera_controls              | *(float)*           | Height of the player UI             |         |
 

 ##  <a name="readonly">Read Only Attributes</a>
 
 | Name           | Type       | Description                        |
 |----------------|------------|------------------------------------|
 | selected_media | *(string)* | The value the knob has been set to |
 |                |            |                                    |
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

 | Name                  | Description                             |
 |-----------------------|-----------------------------------------|
 | did_load_media        | Fires when the media loads successfully |
 | failed_load_media     | Fires when the media fails to load      |
 

 ##  <a name="functions">Functions</a>
 
Present media picker: *present_picker*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "mediaSourceTest",
        "function_name": "present_picker"
      }
    }

Present media picker: *dismiss_picker*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "mediaSourceTest",
        "function_name": "dismiss_picker"
      }
    }

 
 ##  <a name="example">Example JSON</a> 
 
 
 */
//
//  [/Documentation]
/*  -----------------------------  */


#import "IXMediaSource.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "IXLogger.h"

#import "UIImagePickerController+IXAdditions.h"
#import "UIViewController+IXAdditions.h"

#import <MobileCoreServices/MobileCoreServices.h>

// IXMediaSource Read-Only Properties
static NSString* const kIXSelectedMedia = @"selected_media";

@interface  IXMediaSource() <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) NSString* sourceTypeString;
@property (nonatomic,strong) NSString* cameraDeviceString;
@property (nonatomic,assign) UIImagePickerControllerSourceType pickerSourceType;
@property (nonatomic,assign) UIImagePickerControllerCameraDevice pickerDevice;
@property (nonatomic,strong) UIImagePickerController* imagePickerController;
@property (nonatomic,strong) NSURL* selectedMedia;
@property (nonatomic) BOOL showCameraControls;

@end

@implementation IXMediaSource

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
    
    [self setSourceTypeString:[[self propertyContainer] getStringPropertyValue:@"source" defaultValue:@"camera"]];
    [self setCameraDeviceString:[[self propertyContainer] getStringPropertyValue:@"camera" defaultValue:@"rear"]];
    [self setShowCameraControls:[[self propertyContainer] getBoolPropertyValue:@"show_camera_controls" defaultValue:YES]];
    
    [self setPickerSourceType:[UIImagePickerController stringToSourceType:[self sourceTypeString]]];
    [self setPickerDevice:[UIImagePickerController stringToCameraDevice:[self cameraDeviceString]]];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:@"present_picker"] )
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
    else if( [functionName isEqualToString:@"dismiss_picker"] )
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
        [self.actionContainer executeActionsForEventNamed:@"did_load_media"];
    }
    else
    {
        [self.actionContainer executeActionsForEventNamed:@"failed_load_media"];
    }
}



@end
