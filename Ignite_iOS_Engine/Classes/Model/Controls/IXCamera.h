//
//  IXCamera.h
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/24/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseControl.h"

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

#import "IXAppManager.h"
#import "IXLogger.h"
#import "IXDeviceInfo.h"
#import "UIImage+IXAdditions.h"
#import "UIImage+ResizeMagick.h"

#import "NSString+IXAdditions.h"

@interface IXCamera : IXBaseControl

@property (nonatomic,strong) UIView* cameraView;
@property (nonatomic,strong) UIImage* capturedImage;
@property (nonatomic) AVCaptureSession* session;
@property (nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) AVCaptureDevice *device;

@end