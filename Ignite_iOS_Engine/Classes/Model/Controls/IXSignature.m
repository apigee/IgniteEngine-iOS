//
//  IXSignature.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 3/7/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//


/*  -----------------------------  */
//  *** WTF?
/*  -----------------------------  */


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
 
 | Name                           | Type        | Description                                | Default |
 |--------------------------------|-------------|--------------------------------------------|---------|
 | images.default                 | *(string)*  | /path/to/image.png                         |         |
 | images.default.tintColor       | *(color)*   | Color to overlay transparent png           |         |
 | images.default.blur.radius     | *(float)*   | Blur image                                 |         |
 | images.default.blur.tintColor  | *(color)*   | Blur tint                                  |         |
 | images.default.blur.saturation | *(float)*   | Blur saturation                            |         |
 | images.default.force_refresh   | *(bool)*    | Force image to reload when enters view     |         |
 | images.height.max              | *(int)*     | Maximum height of image                    |         |
 | images.width.max               | *(int)*     | Maximum width of image                     |         |
 | gif_duration                   | *(float)*   | Duration of GIF (pronounced JIF) animation |         |
 | flip_horizontal                | *(bool)*    | Flip image horizontally                    | false   |
 | flip_vertical                  | *(bool)*    | Flip image vertically                      | false   |
 | rotate                         | *(int)*     | Rotate image in degrees                    |         |
 | image.binary                   | *(string)*  | Binary data of image file                  |         |
 | images.default.resize          | *(special)* | Dynamically resize image using imageMagick |         |
 

 ##  <a name="readonly">Read Only Attributes</a>
 
 | Name            | Type       | Description                |
 |-----------------|------------|----------------------------|
 | has_signature   | *(bool)*   | Have we captured anything? |
 | last_save_error | *(string)* | Whoopsie.                  |
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

 | Name                  | Description                             |
 |-----------------------|-----------------------------------------|
 | images_default_loaded | Fires when the image loads successfully |
 | images_default_failed | Fires when the image fails to load      |
 

 ##  <a name="functions">Functions</a>
 
Start GIF animation: *start_animation*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "imageTest",
        "function_name": "start_animation"
      }
    }

Restart GIF animation: *restart_animation*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "imageTest",
        "function_name": "restart_animation"
      }
    }
 
Stop GIF animation: *stop_animation*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "imageTest",
        "function_name": "stop_animation"
      }
    }

 Not really sure: *load_last_photo*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "imageTest",
        "function_name": "load_last_photo"
      }
    }


 
 ##  <a name="example">Example JSON</a> 
 
    {
      "_id": "imageTest",
      "_type": "Image",
      "attributes": {
        "height": 100,
        "width": 100,
        "horizontal_alignment": "center",
        "vertical_alignment": "middle",
        "images.default": "/images/btn_notifications_25x25.png",
        "images.default.tintColor": "#a9d5c7"
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXSignature.h"

//#import "PPSSignatureView.h"

#import "NSString+IXAdditions.h"

// IXSignature Read-Only Properties
static NSString* const kIXHasSignature = @"has_signature";
static NSString* const kIXLastSaveError = @"last_save_error";

// IXSignature Events
// kIX_SUCCESS -> Fires when the "save_signature" function finishes successfully.
// kIX_FAILED  -> Fires when the "save_signature" function fails to save the signature.

// IXSignature Functions
static NSString* const kIXSaveSignature = @"save_signature";
static NSString* const kIXTo = @"to"; // Parameter of the "save_signature" function.

@interface IXSignature ()
//
//@property (nonatomic,strong) PPSSignatureView* signatureView;
//@property (nonatomic,strong) NSString* lastErrorMessage;
//
//@end
//
//@implementation IXSignature
//
//-(void)buildView
//{
//    [super buildView];
//    
//    _signatureView = [[PPSSignatureView alloc] initWithFrame:CGRectZero context:nil];
//    [[self contentView] addSubview:_signatureView];
//}
//
//-(void)layoutControlContentsInRect:(CGRect)rect
//{
//    [[self signatureView] setFrame:rect];
//}
//
//-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
//{
//    NSString* returnValue = nil;
//    if( [propertyName isEqualToString:kIXHasSignature] )
//    {
//        returnValue = [NSString ix_stringFromBOOL:[[self signatureView] hasSignature]];
//    }
//    else if( [propertyName isEqualToString:kIXLastSaveError] )
//    {
//        returnValue = [self lastErrorMessage];
//    }
//    else
//    {
//        returnValue = [super getReadOnlyPropertyValue:propertyName];
//    }
//    return returnValue;
//}
//
//-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
//{
//    if( [functionName isEqualToString:kIXSaveSignature] )
//    {
//        BOOL didSaveSignature = NO;
//        if( [[self signatureView] hasSignature] )
//        {
//            NSString* saveToLocation = [parameterContainer getPathPropertyValue:kIXTo basePath:nil defaultValue:nil];
//            if( saveToLocation.length > 0 )
//            {
//                UIImage* signatureImage = [[self signatureView] signatureImage];
//                if( signatureImage )
//                {
//                    // Update the cache with the newly created image.
//                    [IXPropertyContainer storeImageInCache:signatureImage
//                                              withImageURL:[NSURL fileURLWithPath:saveToLocation]
//                                                    toDisk:NO];
//                    
//                    NSData* imageData = UIImagePNGRepresentation(signatureImage);
//                    if( imageData )
//                    {
//                        NSFileManager* fileManager = [NSFileManager defaultManager];
//                        NSError* __autoreleasing error = nil;
//                        [fileManager createDirectoryAtPath:[saveToLocation stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
//                        if( !error )
//                        {
//                            didSaveSignature = [fileManager createFileAtPath:saveToLocation contents:imageData attributes:nil];
//                        }
//                        else
//                        {
//                            [self setLastErrorMessage:[error description]];
//                        }
//                    }
//                    else
//                    {
//                        [self setLastErrorMessage:@"Problem converting image data for signature image."];
//                    }
//                }
//            }
//            else
//            {
//                [self setLastErrorMessage:@"Save signature function needs a valid \"to\" parameter."];
//            }
//        }
//        else
//        {
//            [self setLastErrorMessage:@"Signature control doesn't have signature image."];
//        }
//        
//        if( didSaveSignature )
//        {
//            [[self actionContainer] executeActionsForEventNamed:kIX_SUCCESS];
//        }
//        else
//        {
//            [[self actionContainer] executeActionsForEventNamed:kIX_FAILED];
//        }
//    }
//    else
//    {
//        [super applyFunction:functionName withParameters:parameterContainer];
//    }
//}

@end
