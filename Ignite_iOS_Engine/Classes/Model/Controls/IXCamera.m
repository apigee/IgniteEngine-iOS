//
//  IXCamera.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/24/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXCamera.h"

#import <AVFoundation/AVFoundation.h>

#import "IXAppManager.h"
#import "IXLogger.h"
#import "IXDeviceInfo.h"

#import "NSString+IXAdditions.h"

@interface IXCamera () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic,strong) UIView* cameraView;
@property (nonatomic,strong) UIImage* capturedImage;
@property (nonatomic,strong) AVCaptureSession* session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;

@end

static NSString* const kIXStart = @"start";
static NSString* const kIXStop = @"stop";

@implementation IXCamera

-(void)dealloc
{
    [_captureVideoPreviewLayer setDelegate:nil];
    [_session stopRunning];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [self.cameraView sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [self.cameraView setFrame:rect];
}

-(void)buildView
{
    [super buildView];

    _cameraView = [[UIImageView alloc] initWithFrame:CGRectZero];
}

-(void)applySettings
{
    [super applySettings];
    [self createCameraView];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    NSLog(@"function");
    if( [functionName isEqualToString:kIXStart] )
    {
        [_session startRunning];
    }
    else if( [functionName isEqualToString:kIXStop] )
    {
        [_session stopRunning];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)createCameraView
{
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetMedium;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
    else
        [_session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    
    //this sets the video preview to crop to bounds
    CGRect bounds = self.contentView.layer.bounds;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureVideoPreviewLayer.bounds = bounds;
    _captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [self.cameraView.layer addSublayer:_captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [self frontCamera];
    
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
            
            dispatch_queue_t layerQ = dispatch_queue_create("layerQ", NULL);
            dispatch_async(layerQ, ^{
                [_session startRunning];
                if ([_captureVideoPreviewLayer.connection isVideoOrientationSupported])
                {
                    [_captureVideoPreviewLayer.connection setVideoOrientation:[self videoOrientation]];
                }
                //to make sure were not modifying the UI on a thread other than the main thread, use dispatch_async w/ dispatch_get_main_queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.contentView addSubview:_cameraView];
                });
            });
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
