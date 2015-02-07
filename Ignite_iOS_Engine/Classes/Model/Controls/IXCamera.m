//
//  IXCamera.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/24/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
// 

// todo: This will probably break if we try and add two Camera controls <running> at the same time.
// Need to find a graceful way of deallocating previously started IXCameras.

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     	1/28/2015
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/** Calls upon the device camera to capture an image.
*/

#import "IXCamera.h"

@import AVFoundation;
@import ImageIO;

#import "IXAppManager.h"
#import "IXLogger.h"
#import "IXDeviceInfo.h"
#import "UIImage+IXAdditions.h"
#import "UIImage+ResizeMagick.h"
#import "NSString+IXAdditions.h"

// Temp properties
static NSString* const kIXWidth = @"size.w";
static NSString* const kIXHeight = @"size.h";

// Functions
static NSString* const kIXStart = @"start";
static NSString* const kIXRestart = @"restart";
static NSString* const kIXStop = @"stop";
static NSString* const kIXAutoStart = @"autoStart.enabled";
static NSString* const kIXCaptureImage = @"capture";

// Properties
static NSString* const kIXCamera = @"cameraSource";
static NSString* const kIXFront = @"front";
static NSString* const kIXRear = @"rear";
static NSString* const kIXCaptureResize = @"resizeMask";
static NSString* const kIXCaptureDelay = @"captureDelay";
static NSString* const kIXCapturedImage = @"capturedImage";
static NSString* const kIXAutoSaveToCameraRoll = @"autoSave.enabled";

// Events
static NSString* const kIXDidCaptureImage = @"didCaptureImage";
static NSString* const kIXDidFinishSavingCapture = @"didSaveImage";

@interface IXCamera ()

@property (nonatomic,strong) UIView* cameraView;
@property (nonatomic,strong) UIImage* capturedImage;

@property (nonatomic,strong) AVCaptureSession* session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,strong) AVCaptureDevice *device;

@end

@implementation IXCamera : IXBaseControl

/*
* Docs
*
*/

/***************************************************************/

/** This control has the following attributes: 
    @param width Width of Camera preview<br>*(integer)*
    @param height Height of Camera preview<br>*(integer)*
    @param camera Which Camera to use<br>*frontrear*
    @param capture.resize Resize captured image<br>*(string)*
    @param capture.delay Delay image capture<br>*(float)*
    @param captured_image Captured Image<br>*(string)*
    @param auto_start Automatically present the Camera view controller<br>*(bool)*
    @param auto_save_to_camera_roll Automatically save captured image to camera roll<br>*(bool)* 
 
*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:
*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param did_capture_image Image captured successfully
    @param did_finish_saving_capture Image saved successfully 
 
*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


 @param start Presents the Camera view controller
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "cameraTest",
    "function_name": "start"
  }
}
 </pre>

 @param restart Restarts the Camera view controller
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "cameraTest",
    "function_name": "restart"
  }
}
 </pre>
 
  @param stop Dismisses the Camera view controller
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "cameraTest",
    "function_name": "stop"
  }
}
 </pre>

  @param capture_image Captures + saves the image.
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "cameraTest",
    "function_name": "capture_image"
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
 
{
  "_id": "cameraTest",
  "_type": "Camera",
  "actions": [
    {
      "on": "did_capture_image",
      "_type": "Alert",
      "attributes": {
        "title": "did_capture_image"
      }
    },
    {
      "on": "did_finish_saving_capture",
      "_type": "Alert",
      "attributes": {
        "title": "did_finish_saving_capture"
      }
    }
  ],
  "attributes": {
    "camera": "rear",
    "height": "100%",
    "width": "100%"
  }
}
 
 </pre>
 

*/

-(void)Example
{
}

/***************************************************************/

/*
* /Docs
*
*/

-(void)dealloc
{
    AVCaptureInput* input = [_session.inputs firstObject];
    if( input )
    {
        [_session removeInput:input];
    }
    AVCaptureVideoDataOutput* output = [_session.outputs firstObject];
    if( output )
    {
        [_session removeOutput:output];
    }
    [_session stopRunning];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [_cameraView sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [_cameraView setFrame:rect];
    [_cameraView sizeToFit];
}

-(void)buildView
{
    [super buildView];
    
    _cameraView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_cameraView];
}

-(void)applySettings
{
    [super applySettings];
    [self createCameraView];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXStart] )
    {
        [_session startRunning];
    }
    else if( [functionName isEqualToString:kIXStop] )
    {
        [_session stopRunning];
    }
    else if( [functionName isEqualToString:kIXRestart] )
    {
        [_session stopRunning];
        [self createCameraView];
        [_session startRunning];
    }
    else if( [functionName isEqualToString:kIXCaptureImage] )
    {
        CGFloat captureDelay = [self.propertyContainer getFloatPropertyValue:kIXCaptureDelay defaultValue:0.0f];
        if (captureDelay > 0)
        {
            [self performSelector:@selector(captureStillImage) withObject:self afterDelay:captureDelay ];
        }
        else
        {
            [self captureStillImage];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)createCameraView
{
    AVCaptureInput* input = [_session.inputs firstObject];
    if( input )
    {
        [_session removeInput:input];
    }
    AVCaptureVideoDataOutput* output = [_session.outputs firstObject];
    if( output )
    {
        [_session removeOutput:output];
    }
    [_session stopRunning];
    
    _session = [AVCaptureSession new];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        _session.sessionPreset = AVCaptureSessionPreset640x480;
    else
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];

    // Need to fix this; currently it takes the defined size - percentage size is not calculated based on parent size. Need it to grab contentView.bounds on viewDidLoad...?
    CGFloat width = [self.propertyContainer getSizeValue:kIXWidth maximumSize:[[IXDeviceInfo screenWidth] floatValue] defaultValue:320.0f];
    CGFloat height = [self.propertyContainer getSizeValue:kIXHeight maximumSize:[[IXDeviceInfo screenHeight] floatValue] defaultValue:320.0f];
    
    //this sets the video preview to crop to bounds
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    //bounds = self.contentView.bounds;
    //Here you can see the bounds is 0,0,0,0. If you comment the line above out, it will define the bounds to whatever rect you set it to.
    //NSLog(NSStringFromCGRect(bounds));
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureVideoPreviewLayer.frame = bounds;
    _captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [_cameraView.layer addSublayer:_captureVideoPreviewLayer];
    
    NSString* camera = [self.propertyContainer getStringPropertyValue:kIXCamera defaultValue:kIXRear];
    if ([camera isEqualToString:kIXFront])
    {
         _device = [self frontCamera];
    }
    else
    {
        _device = [self rearCamera];
    }
    
    NSError *error = nil;
    if ([[IXDeviceInfo deviceType] containsSubstring:@"simulator" options:NSCaseInsensitiveSearch])
    {
        IX_LOG_ERROR(@"ERROR: trying to open camera on simulator");
    }
    else
    {
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        
        // Still image output stuff - we'll want to expand on this later to allow for video capture and other things
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [_stillImageOutput setOutputSettings:outputSettings];
        
        if (!input) {
            // Handle the error appropriately.
            IX_LOG_ERROR(@"ERROR: trying to open camera: %@", error);
        }
        else
        {
            if([_session canAddInput:input])
                [_session addInput:input];
            
            if([_session canAddOutput:_stillImageOutput])
                [_session addOutput:_stillImageOutput];
            
            
            
            BOOL autoStart = [self.propertyContainer getBoolPropertyValue:kIXAutoStart defaultValue:NO];
            if (autoStart)
            {
                [_session startRunning];
            }
            
            if ([_captureVideoPreviewLayer.connection isVideoOrientationSupported])
            {
                [_captureVideoPreviewLayer.connection setVideoOrientation:[self videoOrientation]];
            }
        }
    }
}

-(AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

-(AVCaptureDevice *)rearCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            return device;
        }
    }
    return nil;
}

-(AVCaptureVideoOrientation)videoOrientation
{
    if ([IXAppManager currentInterfaceOrientation] == UIInterfaceOrientationLandscapeLeft)
    {
        return AVCaptureVideoOrientationLandscapeLeft;
    }
    else if ([IXAppManager currentInterfaceOrientation] == UIInterfaceOrientationLandscapeRight)
    {
        return AVCaptureVideoOrientationLandscapeRight;
    }
    else if ([IXAppManager currentInterfaceOrientation] == UIInterfaceOrientationPortraitUpsideDown)
    {
        return AVCaptureVideoOrientationPortraitUpsideDown;
    }
    else
    {
        return AVCaptureVideoOrientationPortrait;
    }
}

- (void)showShutter
{
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    overlay.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    overlay.layer.opacity = 0.6f;
    [UIView transitionWithView:self.contentView duration:0.1
                       options:UIViewAnimationOptionCurveEaseIn //change to whatever animation you like
                    animations:^ { [_cameraView addSubview: overlay]; }
                    completion:^(BOOL finished) {
                        [UIView transitionWithView:self.contentView duration:0.5
                                           options:UIViewAnimationOptionCurveEaseIn //change to whatever animation you like
                                        animations:^ { overlay.alpha = 0; }
                                        completion:^(BOOL finished) {
                                            [overlay removeFromSuperview];
                                        }];
                    }];
}

- (void)captureStillImage
{
    @try {
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in _stillImageOutput.connections){
            for (AVCaptureInputPort *port in [connection inputPorts]){
                
                if ([[port mediaType] isEqual:AVMediaTypeVideo]){
                    
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) {
                break;
            }
        }
        [self showShutter];
        IX_LOG_DEBUG(@"About to request a capture from: %@", [self stillImageOutput]);
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                             completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                                 
                                                                 // This is here for when we need to implement Exif stuff. 
                                                                 //CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                                 
                                                                 NSString* resizeMask = [[self propertyContainer] getStringPropertyValue:kIXCaptureResize defaultValue:nil];
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];

                                                                 // Create a UIImage from the sample buffer data
                                                                 if (resizeMask)
                                                                     _capturedImage = [[[UIImage alloc] initWithData:imageData] resizedImageByMagick:resizeMask];
                                                                 else
                                                                     _capturedImage = [[UIImage alloc] initWithData:imageData];
                                                                 
                                                                 [self.actionContainer executeActionsForEventNamed:kIXDidCaptureImage];
                                                                 
                                                                 // Hack for storing image in photo library. We need to fix this later on to be more robust and either cache it or have the image accessible to IXImage.
                                                                 BOOL autoSave = [[self propertyContainer] getBoolPropertyValue:kIXAutoSaveToCameraRoll defaultValue:YES];
                                                                 if (autoSave)
                                                                 {
                                                                     UIImageWriteToSavedPhotosAlbum(_capturedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                                                                 }

                                                             }];
    }
    @catch (NSException *exception) {
        IX_LOG_ERROR(@"ERROR: Unable to capture still image from IXCamera: %@", exception);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    [self.actionContainer executeActionsForEventNamed:kIXDidFinishSavingCapture];
}

// trololol it looks like we don't need this at all!

// Create a UIImage from sample buffer data
//-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
//{
//    // Get a CMSampleBuffer's Core Video image buffer for the media data
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    // Lock the base address of the pixel buffer
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
//    
//    // Get the number of bytes per row for the pixel buffer
//    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
//    
//    // Get the number of bytes per row for the pixel buffer
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//    // Get the pixel buffer width and height
//    size_t width = CVPixelBufferGetWidth(imageBuffer);
//    size_t height = CVPixelBufferGetHeight(imageBuffer);
//    
//    // Create a device-dependent RGB color space
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    
//    // Create a bitmap graphics context with the sample buffer data
//    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
//                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//    // Create a Quartz image from the pixel data in the bitmap graphics context
//    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
//    // Unlock the pixel buffer
//    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
//    
//    // Free up the context and color space
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    
//    // Create an image object from the Quartz image
//    UIImage *image = [UIImage imageWithCGImage:quartzImage];
//    
//    // Release the Quartz image
//    CGImageRelease(quartzImage);
//    
//    return (image);
//}

@end
