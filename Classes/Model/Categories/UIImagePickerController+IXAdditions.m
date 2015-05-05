//
//  UIImagePickerController+IXAdditions.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/25/13.
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

#import "UIImagePickerController+IXAdditions.h"

@implementation UIImagePickerController (IXAdditions)

+(UIImagePickerControllerSourceType)stringToSourceType:(NSString*)sourceTypeString
{
    UIImagePickerControllerSourceType returnSourceType = UIImagePickerControllerSourceTypeCamera;
    if( [sourceTypeString isEqualToString:@"camera"] || [sourceTypeString isEqualToString:@"video"] )
    {
        returnSourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if( [sourceTypeString isEqualToString:@"library"] )
    {
        returnSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if( [sourceTypeString isEqualToString:@"saved_photos"] )
    {
        returnSourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    return returnSourceType;
}

+(UIImagePickerControllerCameraDevice)stringToCameraDevice:(NSString*)cameraDeviceString
{
    UIImagePickerControllerCameraDevice returnCameraDevice = UIImagePickerControllerCameraDeviceRear;
    if ( [cameraDeviceString isEqualToString:@"front"] )
        returnCameraDevice = UIImagePickerControllerCameraDeviceFront;
    if ( [cameraDeviceString isEqualToString:@"rear"] )
        returnCameraDevice = UIImagePickerControllerCameraDeviceRear;
    return returnCameraDevice;
}

@end
