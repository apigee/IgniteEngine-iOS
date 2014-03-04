//
//  IXMediaControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 
 CONTROL
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
@property (nonatomic,assign) UIImagePickerControllerSourceType pickerSourceType;
@property (nonatomic,strong) UIImagePickerController* imagePickerController;
@property (nonatomic,strong) NSURL* selectedMedia;

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
    [self setPickerSourceType:[UIImagePickerController stringToSourceType:[self sourceTypeString]]];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:@"present_picker"] )
    {
        if( [[self imagePickerController] presentingViewController] == nil )
        {
            [self configurePickerController];
            [self presentPickerController:[parameterContainer getBoolPropertyValue:@"animated" defaultValue:YES]];
        }
    }
    else if( [functionName isEqualToString:@"dismiss_picker"] )
    {
        [self dismissPickerController:[parameterContainer getBoolPropertyValue:@"animated" defaultValue:YES]];
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
                                                                         animated:animated
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
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a movie capture
//    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
//        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
//            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self, nil, nil);
//        }
//    }

    self.selectedMedia = info[UIImagePickerControllerReferenceURL];
    
    [[[IXAppManager sharedAppManager] rootViewController] dismissViewControllerAnimated:YES completion:nil];
    
    DDLogInfo(@"Successfully loaded media at %@", info[UIImagePickerControllerReferenceURL]);
    
    if(info != nil)
    {
        [self.actionContainer executeActionsForEventNamed:@"did_load_media"];
    }
    
    //Here's the image!  [info objectForKey:@"UIImagePickerControllerOriginalImage"];
}



@end
