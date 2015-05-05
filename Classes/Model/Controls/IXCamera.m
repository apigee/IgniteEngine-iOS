//
//  IXCamera.m
//  Ignite Engine
//
//  Created by Brandon on 3/24/14.
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

//TODO: This will probably break if we try and add two Camera controls <running> at the same time. Need to find a graceful way of deallocating previously started IXCameras.
//TODO: Todo: requires a read only accessor for the image. Would properly require a function to add to IXImage to update image with UIImage


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
IX_STATIC_CONST_STRING kIXWidth = @"size.w";
IX_STATIC_CONST_STRING kIXWidthX = @"size.width";
IX_STATIC_CONST_STRING kIXHeight = @"size.h";
IX_STATIC_CONST_STRING kIXSize = @"size";

// Functions
IX_STATIC_CONST_STRING kIXStart = @"start";
IX_STATIC_CONST_STRING kIXRestart = @"restart";
IX_STATIC_CONST_STRING kIXStop = @"stop";
IX_STATIC_CONST_STRING kIXAutoStart = @"autoStart.enabled";
IX_STATIC_CONST_STRING kIXCaptureImage = @"capture";

// Properties
IX_STATIC_CONST_STRING kIXCamera = @"cameraSource";
IX_STATIC_CONST_STRING kIXFront = @"front";
IX_STATIC_CONST_STRING kIXRear = @"rear";
IX_STATIC_CONST_STRING kIXCaptureResize = @"resizeMask";
IX_STATIC_CONST_STRING kIXCaptureDelay = @"captureDelay";
//IX_STATIC_CONST_STRING kIXCapturedImage = @"capturedImage";
IX_STATIC_CONST_STRING kIXAutoSaveToCameraRoll = @"autoSave.enabled";

// Events
IX_STATIC_CONST_STRING kIXDidCaptureImage = @"didCaptureImage";
IX_STATIC_CONST_STRING kIXDidFinishSavingCapture = @"didSaveImage";

@interface IXCamera ()

@property (nonatomic,strong) UIView* cameraView;
@property (nonatomic,strong) UIImage* capturedImage;

@property (nonatomic,strong) AVCaptureSession* session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,strong) AVCaptureDevice *device;

@end

@implementation IXCamera : IXBaseControl

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

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
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
        CGFloat captureDelay = [self.attributeContainer getFloatValueForAttribute:kIXCaptureDelay defaultValue:0.0f];
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

//TODO: Need to fix this; currently it takes the defined size - percentage size is not calculated based on parent size. Need it to grab contentView.bounds on viewDidLoad...?
    CGFloat width = [self.attributeContainer getSizeValueForAttribute:kIXWidth maximumSize:[[IXDeviceInfo screenWidth] floatValue] defaultValue:320.0f];
    CGFloat height = [self.attributeContainer getSizeValueForAttribute:kIXHeight maximumSize:[[IXDeviceInfo screenHeight] floatValue] defaultValue:320.0f];
    
    //this sets the video preview to crop to bounds
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    //bounds = self.contentView.bounds;
    //Here you can see the bounds is 0,0,0,0. If you comment the line above out, it will define the bounds to whatever rect you set it to.
    //NSLog(NSStringFromCGRect(bounds));
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureVideoPreviewLayer.frame = bounds;
    _captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [_cameraView.layer addSublayer:_captureVideoPreviewLayer];
    
    NSString* camera = [self.attributeContainer getStringValueForAttribute:kIXCamera defaultValue:kIXRear];
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
            
            
            
            BOOL autoStart = [self.attributeContainer getBoolValueForAttribute:kIXAutoStart defaultValue:NO];
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
                                                                 
                                                                 NSString* resizeMask = [[self attributeContainer] getStringValueForAttribute:kIXCaptureResize defaultValue:nil];
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];

                                                                 // Create a UIImage from the sample buffer data
                                                                 if (resizeMask)
                                                                     _capturedImage = [[[UIImage alloc] initWithData:imageData] resizedImageByMagick:resizeMask];
                                                                 else
                                                                     _capturedImage = [[UIImage alloc] initWithData:imageData];
                                                                 
                                                                 [self.actionContainer executeActionsForEventNamed:kIXDidCaptureImage];
                                                                 
                                                                 // Hack for storing image in photo library. We need to fix this later on to be more robust and either cache it or have the image accessible to IXImage.
                                                                 BOOL autoSave = [[self attributeContainer] getBoolValueForAttribute:kIXAutoSaveToCameraRoll defaultValue:YES];
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

@end
