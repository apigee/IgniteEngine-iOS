//
//  IXMediaControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 /--------------------/
 - Example
 /--------------------/

 {
     "_id": "mediasourceLibrary",
     "_type": "MediaSource",
     "attributes": {
         "source": "library",
     }
 }
 
 And to fire:
 
 {
     "_type": "Function",
     "attributes": {
         "function_name": "present_picker",
         "_id": "mediasourceLibrary"
     },
     "on": "touch_up"
 }
 
 And after loaded:
 
 {
     "_type": "Modify",
     "attributes": {
        "_target": "session"
     },
    "on": "did_load_media",
    "set": {
        "selected_media": "[[$self.selected_media]]"
     }
 }
 
 
 /--------------------/
 - Changelog
 /--------------------/
 
 /--------------------/
 */

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

/*
* Docs
*
*/

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

    @param urce Style of controls to use<br>*cameralibrary*
    @param camera Color of the player UI<br>*frontrear*
    @param show_camera_controls Height of the player UI<br>*(float)*

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

 @param selected_media The value the knob has been set to<br>*(string)*

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


    @param did_load_media Fires when the media loads successfully
    @param failed_load_media Fires when the media fails to load

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

   
 @param present_picker Present the media picker view controller.
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "mediaSourceTest",
    "function_name": "present_picker"
  }
}
 
 </pre>
 
 @param dismiss_picker Dismiss the media picker view controller.
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "mediaSourceTest",
    "function_name": "dismiss_picker"
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
 
{
  "_id": "mediaSourceTest",
  "_type": "MediaSource",
  "actions": [
    {
      "on": "did_load_media",
      "_type": "Alert",
      "attributes": {
        "title": "did_load_media: [[$self.selected_media]]"
      }
    }
  ],
  "attributes": {
    "source": "library"
  }
}
 
 </pre>



*/

-(void)example
{
}

/***************************************************************/

/*
* /Docs
*
*/


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
