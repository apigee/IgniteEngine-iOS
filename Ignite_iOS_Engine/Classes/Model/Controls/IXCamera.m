//
//  IXCamera.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/24/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

// todo: This will probably break if we try and add two Camera controls <running> at the same time.
// Need to find a graceful way of deallocating previously started IXCameras.

#import "IXCamera.h"

static NSString* const kIXWidth = @"width";
static NSString* const kIXHeight = @"height";

static NSString* const kIXStart = @"start";
static NSString* const kIXStop = @"stop";

static NSString* const kIXCamera = @"camera";
static NSString* const kIXFront = @"front";
static NSString* const kIXRear = @"rear";

@implementation IXCamera : IXBaseControl

-(void)dealloc
{
    [_captureVideoPreviewLayer setDelegate:nil];
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
    _cameraView = [[UIScrollView alloc] initWithFrame:CGRectZero];
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
        NSLog(@"started");
        [_session startRunning];
    }
    else if( [functionName isEqualToString:kIXStop] )
    {
        NSLog(@"started");
        [_session stopRunning];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)createCameraView
{
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
    CGRect bounds = CGRectMake(0, 0, 400, 400);
    
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureVideoPreviewLayer.frame = bounds;
    _captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [_cameraView.layer addSublayer:_captureVideoPreviewLayer];
    
    NSString* camera = [self.propertyContainer getStringPropertyValue:kIXCamera defaultValue:kIXRear];
    AVCaptureDevice *device;
    if ([camera isEqualToString:kIXFront])
    {
         device = [self frontCamera];
    }
    else
    {
        device = [self rearCamera];
    }
    
    NSError *error = nil;
    if ([NSString ix_string:[IXDeviceInfo deviceType] containsSubstring:@"simulator" options:NSCaseInsensitiveSearch])
    {
        DDLogError(@"ERROR: trying to open camera on simulator");
    }
    else
    {
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        AVCaptureMovieFileOutput *output = [[AVCaptureMovieFileOutput alloc] init];

        if (!input) {
            // Handle the error appropriately.
            DDLogError(@"ERROR: trying to open camera: %@", error);
        }
        else
        {
            if([_session canAddInput:input])
                [_session addInput:input];
            
            if([_session canAddOutput:output])
                [_session addOutput:output];
            
            [_session startRunning];
            
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

-(void)captureStillImage
{
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"poutput");
}

@end
