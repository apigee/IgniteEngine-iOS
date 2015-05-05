//
//  IXImageControl.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/15/13.
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

#import "IXImage.h"

#import "NSString+IXAdditions.h"
#import "UIImageView+IXAdditions.h"

#import "IXWeakTimerTarget.h"
#import "IXGIFImageView.h"
#import "IXControlLayoutInfo.h"

#import "UIImage+ResizeMagick.h"
#import "UIImage+IXAdditions.h"
#import "UIImage+ImageEffects.h"

#import "IXLogger.h"


// IXImage Properties
IX_STATIC_CONST_STRING kIXImagesDefault = @"image";
IX_STATIC_CONST_STRING kIXImagesDefaultTintColor = @"tint";
IX_STATIC_CONST_STRING kIXImagesDefaultBlurRadius = @"blur.radius";
IX_STATIC_CONST_STRING kIXImagesDefaultBlurTintColor = @"blur.tint";
IX_STATIC_CONST_STRING kIXImagesDefaultBlurSaturation = @"blur.saturation";
IX_STATIC_CONST_STRING kIXImagesDefaultForceRefresh = @"forceRedraw.enabled";
IX_STATIC_CONST_STRING kIXImagesHeightMax = @"max.h";
IX_STATIC_CONST_STRING kIXImagesWidthMax = @"max.w";
IX_STATIC_CONST_STRING kIXGIFDuration = @"animatedGif.duration";
IX_STATIC_CONST_STRING kIXFlipHorizontal = @"transform.flip.h";
IX_STATIC_CONST_STRING kIXFlipVertical = @"transform.flip.v";
IX_STATIC_CONST_STRING kIXRotate = @"transform.rotate";
// should support loading a binary string into image (bool property?)
IX_STATIC_CONST_STRING kIXImageBinary = @"binaryString";

// IXImage Manipulation -- use a resizedImageByMagick mask for these
IX_STATIC_CONST_STRING kIXImagesDefaultResize = @"resizeMask";

// IXImage Read-Only Properties
IX_STATIC_CONST_STRING kIXIsAnimating = @"isAnimating";
IX_STATIC_CONST_STRING kIXImageHeight = @"source.size.h";
IX_STATIC_CONST_STRING kIXImageWidth = @"source.size.w";

// IXImage Events
IX_STATIC_CONST_STRING kIXImagesDefaultLoaded = @"success";
IX_STATIC_CONST_STRING kIXImagesDefaultFailed = @"error";

// IXImage Functions
IX_STATIC_CONST_STRING kIXStartAnimation = @"start";
IX_STATIC_CONST_STRING kIXRestartAnimation = @"restart";
IX_STATIC_CONST_STRING kIXStopAnimation = @"stop";
IX_STATIC_CONST_STRING kIXLoadLastPhoto = @"loadLatestPhoto";

@interface IXImage ()

@property (nonatomic,strong) IXGIFImageView* imageView;
@property (nonatomic,strong) UIImage* defaultImage;

@property (nonatomic,assign,getter = isAnimatedGIF) BOOL animatedGif;
@property (nonatomic,strong) NSURL* animatedGIFURL;

@end

@implementation IXImage

-(void)buildView
{
    [super buildView];
    
    _imageView = [[IXGIFImageView alloc] initWithFrame:CGRectZero];
    [[self contentView] addSubview:_imageView];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self imageView] setFrame:rect];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    CGSize returnSize = CGSizeZero;
    if( [[self imageView] image] != nil )
    {
        CGSize imageSize = [[[self imageView] image] size];
        
        float maxWidth = fminf(imageSize.width,[[self attributeContainer] getSizeValueForAttribute:kIXImagesWidthMax
                                                                          maximumSize:size.width
                                                                         defaultValue:CGFLOAT_MAX]);
        
        float maxHeight = fminf(imageSize.height,[[self attributeContainer] getSizeValueForAttribute:kIXImagesHeightMax
                                                                            maximumSize:size.height
                                                                           defaultValue:CGFLOAT_MAX]);

        returnSize = CGSizeMake((int)maxWidth,(int)maxHeight);
        
        if( imageSize.width > maxWidth || imageSize.height > maxHeight )
        {
            float widthScaleFactor = maxWidth/imageSize.width;
            float heightScaleFactor = maxHeight/imageSize.height;
            float minScaleFactor = fminf(heightScaleFactor, widthScaleFactor);

            returnSize.width = (int)(imageSize.width * minScaleFactor);
            returnSize.height = (int)(imageSize.height * minScaleFactor);
        }
    }
    return returnSize;
}

-(void)applySettings
{
    [super applySettings];
    
    NSURL* imageURL = [[self attributeContainer] getURLValueForAttribute:kIXImagesDefault basePath:nil defaultValue:nil];
    [self setAnimatedGif:[[imageURL pathExtension] isEqualToString:kIX_GIF_EXTENSION]];

    if( [self isAnimatedGIF] )
    {
        if( ![[self animatedGIFURL] isEqual:imageURL] )
        {
            [self setAnimatedGIFURL:imageURL];
            
            float gifDuration = [[self attributeContainer] getFloatValueForAttribute:kIXGIFDuration defaultValue:0.0f];
            [[self imageView] setAnimatedGIFDuration:gifDuration];
            [[self imageView] setAnimatedGIFURL:[self animatedGIFURL]];
        }
        
        [[self imageView] setHidden:!([self isContentViewVisible])];
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        
        NSString* resizeDefault = [self.attributeContainer getStringValueForAttribute:kIXImagesDefaultResize defaultValue:nil];
        UIColor *defaultTintColor = [self.attributeContainer getColorValueForAttribute:kIXImagesDefaultTintColor defaultValue:nil];
        BOOL forceRefresh = [self.attributeContainer getBoolValueForAttribute:kIXImagesDefaultForceRefresh defaultValue:NO];

        [[self attributeContainer] getImageAttribute:kIXImagesDefault
                                      successBlock:^(UIImage *image) {
                                          
                                          // if default image is to be resized, do that first
                                          if (resizeDefault)
                                              image = [image resizedImageByMagick:resizeDefault];
                                          
                                          if (defaultTintColor)
                                              image = [image tintedImageUsingColor:defaultTintColor];

                                          BOOL needsToApplyBlur = [[self attributeContainer] attributeExistsForName:kIXImagesDefaultBlurRadius];
                                          if( needsToApplyBlur )
                                          {
                                              CGFloat blurRadius = [[self attributeContainer] getFloatValueForAttribute:kIXImagesDefaultBlurRadius defaultValue:20.0f];
                                              UIColor* tintColor = [[self attributeContainer] getColorValueForAttribute:kIXImagesDefaultBlurTintColor defaultValue:nil];
                                              CGFloat saturation = [[self attributeContainer] getFloatValueForAttribute:kIXImagesDefaultBlurSaturation defaultValue:1.8f];

                                              image = [image applyBlurWithRadius:blurRadius tintColor:tintColor saturationDeltaFactor:saturation maskImage:nil];
                                          }

                                          weakSelf.defaultImage = image;
                                          
                                          BOOL needsToRefreshLayout = NO;
                                          if( ![[weakSelf layoutInfo] heightWasDefined] || ![[weakSelf layoutInfo] widthWasDefined] )
                                          {
                                              CGSize oldSize = [[[weakSelf imageView] image] size];
                                              CGSize newSize = [image size];
                                              if( !CGSizeEqualToSize(oldSize, newSize) )
                                              {
                                                  needsToRefreshLayout = YES;
                                              }
                                          }
                                          
                                          [[weakSelf imageView] setImage:image];
                                          if( needsToRefreshLayout )
                                          {
                                              [weakSelf layoutControl];
                                          }
                                          [[weakSelf actionContainer] executeActionsForEventNamed:kIXImagesDefaultLoaded];
                                          
                                      } failBlock:^(NSError *error) {
                                          [[weakSelf actionContainer] executeActionsForEventNamed:kIXImagesDefaultFailed];
                                      } shouldRefreshCachedImage:forceRefresh];

        BOOL flipHorizontal = [[self attributeContainer] getBoolValueForAttribute:kIXFlipHorizontal defaultValue:NO];
        BOOL flipVertical = [[self attributeContainer] getBoolValueForAttribute:kIXFlipVertical defaultValue:NO];
        CGFloat rotate = [[self attributeContainer] getFloatValueForAttribute:kIXRotate defaultValue:0.0f];
        
        if (flipHorizontal)
        {
            _imageView.transform = CGAffineTransformMakeScale(-1, 1);
        }
        if (flipVertical)
        {
            _imageView.transform = CGAffineTransformMakeScale(1, -1);
        }
        if (rotate != 0)
        {
            //todo: this only works with whole number rotations, 90, 180, 270 otherwise it squiches the resulting image.
            CGAffineTransform transform = CGAffineTransformIdentity;
            self.contentView.autoresizesSubviews = NO;
            _imageView.transform = CGAffineTransformRotate(transform, [UIImage degreesToRadians:rotate] );
        }
    }
}

//
// todo: get this "isAnimating" property working with keyframe pngs
-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXIsAnimating] )
    {
        returnValue = [NSString ix_stringFromBOOL:[[self imageView] isGIFAnimating]];
    }
    else if ([propertyName isEqualToString:kIXImageHeight])
    {
        returnValue = [NSString ix_stringFromFloat:self.imageView.image.size.height];
    }
    else if ([propertyName isEqualToString:kIXImageWidth])
    {
        returnValue = [NSString ix_stringFromFloat:self.imageView.image.size.width];
    }
    // Todo: Currently this is only going to spit out a .jpg; we need to figure out a way of getting it to return the proper format.
    // +(NSString *)contentTypeForImageData:(NSData *)data was added to IXAdditions, but still requires a binary data stream of either
    // JPEG or PNG.
    // see http://stackoverflow.com/questions/17475392/when-should-i-use-uiimagejpegrepresentation-and-uiimagepngrepresentation-for-upl
    else if ([propertyName isEqualToString:kIXImageBinary])
    {
        NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 1);
        returnValue = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(void)loadLastPhoto
{
    
    __weak typeof(self) weakSelf = self;
    // todo: Currently this is a bit of a hack - we need this function here, but it should be wrapped properly in the getImage function instead
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (nil != group) {
                                         // be sure to filter the group so you only get photos
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         
                                         [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                                                                 options:0
                                                              usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                                  if (nil != result) {
                                                                      ALAssetRepresentation *repr = [result defaultRepresentation];
                                                                      // this is the most recent saved photo
                                                                      
                                                                      /* Not using this currently
                                                                         NSURL *assetsUrl = repr.url; */
                                                                      
                                                                      UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                                                                      // we only need the first (most recent) photo -- stop the enumeration
                                                                      *stop = YES;
                                                                      
                                                                      weakSelf.defaultImage = img;
                                                                      [[self imageView] setImage:img];
                                                                  }
                                                              }];
                                     }
                                     
                                     *stop = NO;
                                 } failureBlock:^(NSError *error) {
                                     IX_LOG_ERROR(@"ERROR: %@", error);
                                 }];
    
    
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXStartAnimation] )
    {
        [[self imageView] startGIFAnimation:NO];
    }
    else if( [functionName isEqualToString:kIXRestartAnimation] )
    {
        [[self imageView] startGIFAnimation:YES];
    }
    else if( [functionName isEqualToString:kIXStopAnimation] )
    {
        [[self imageView] stopGIFAnimation:NO];
    }
    else if( [functionName isEqualToString:kIXLoadLastPhoto] )
    {
        [self loadLastPhoto];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
