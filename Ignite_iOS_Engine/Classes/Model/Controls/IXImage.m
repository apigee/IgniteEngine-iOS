//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

//
//  IXActionSheet.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 7/18/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

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
 
 | Name         | Type     | Description            |
 |--------------|----------|------------------------|
 | is_animating | *(bool)* | Is it animating?       |
 | image.height | *(int)*  | Actual height of image |
 | image.width  | *(int)*  | Actual width of image  |
 
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
IX_STATIC_CONST_STRING kIXImagesDefault = @"images.default";
IX_STATIC_CONST_STRING kIXImagesDefaultTintColor = @"images.default.tintColor";
IX_STATIC_CONST_STRING kIXImagesDefaultBlurRadius = @"images.default.blur.radius";
IX_STATIC_CONST_STRING kIXImagesDefaultBlurTintColor = @"images.default.blur.tintColor";
IX_STATIC_CONST_STRING kIXImagesDefaultBlurSaturation = @"images.default.blur.saturation";
IX_STATIC_CONST_STRING kIXImagesDefaultForceRefresh = @"images.default.force_refresh";
IX_STATIC_CONST_STRING kIXImagesHeightMax = @"images.height.max";
IX_STATIC_CONST_STRING kIXImagesWidthMax = @"images.width.max";
IX_STATIC_CONST_STRING kIXGIFDuration = @"gif_duration";
IX_STATIC_CONST_STRING kIXFlipHorizontal = @"flip_horizontal";
IX_STATIC_CONST_STRING kIXFlipVertical = @"flip_vertical";
IX_STATIC_CONST_STRING kIXRotate = @"rotate";
IX_STATIC_CONST_STRING kIXImageBinary = @"image.binary";

// IXImage Manipulation -- use a resizedImageByMagick mask for these
IX_STATIC_CONST_STRING kIXImagesDefaultResize = @"images.default.resize";

// IXImage Read-Only Properties
IX_STATIC_CONST_STRING kIXIsAnimating = @"is_animating";
IX_STATIC_CONST_STRING kIXImageHeight = @"image.height";
IX_STATIC_CONST_STRING kIXImageWidth = @"image.width";

// IXImage Events
IX_STATIC_CONST_STRING kIXImagesDefaultLoaded = @"images_default_loaded";
IX_STATIC_CONST_STRING kIXImagesDefaultFailed = @"images_default_failed";

// IXImage Functions
IX_STATIC_CONST_STRING kIXStartAnimation = @"start_animation";
IX_STATIC_CONST_STRING kIXRestartAnimation = @"restart_animation";
IX_STATIC_CONST_STRING kIXStopAnimation = @"stop_animation";
IX_STATIC_CONST_STRING kIXLoadLastPhoto = @"load_last_photo";

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
        
        float maxWidth = fminf(imageSize.width,[[self propertyContainer] getSizeValue:kIXImagesWidthMax
                                                                          maximumSize:size.width
                                                                         defaultValue:CGFLOAT_MAX]);
        
        float maxHeight = fminf(imageSize.height,[[self propertyContainer] getSizeValue:kIXImagesHeightMax
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
    
    NSURL* imageURL = [[self propertyContainer] getURLPathPropertyValue:kIXImagesDefault basePath:nil defaultValue:nil];
    [self setAnimatedGif:[[imageURL pathExtension] isEqualToString:kIX_GIF_EXTENSION]];

    if( [self isAnimatedGIF] )
    {
        if( ![[self animatedGIFURL] isEqual:imageURL] )
        {
            [self setAnimatedGIFURL:imageURL];
            
            float gifDuration = [[self propertyContainer] getFloatPropertyValue:kIXGIFDuration defaultValue:0.0f];
            [[self imageView] setAnimatedGIFDuration:gifDuration];
            [[self imageView] setAnimatedGIFURL:[self animatedGIFURL]];
        }
        
        [[self imageView] setHidden:!([self isContentViewVisible])];
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        
        NSString* resizeDefault = [self.propertyContainer getStringPropertyValue:kIXImagesDefaultResize defaultValue:nil];
        UIColor *defaultTintColor = [self.propertyContainer getColorPropertyValue:kIXImagesDefaultTintColor defaultValue:nil];
        BOOL forceRefresh = [self.propertyContainer getBoolPropertyValue:kIXImagesDefaultForceRefresh defaultValue:NO];

        [[self propertyContainer] getImageProperty:kIXImagesDefault
                                      successBlock:^(UIImage *image) {
                                          
                                          // if default image is to be resized, do that first
                                          if (resizeDefault)
                                              image = [image resizedImageByMagick:resizeDefault];
                                          
                                          if (defaultTintColor)
                                              image = [image tintedImageUsingColor:defaultTintColor];

                                          BOOL needsToApplyBlur = [[self propertyContainer] propertyExistsForPropertyNamed:kIXImagesDefaultBlurRadius];
                                          if( needsToApplyBlur )
                                          {
                                              CGFloat blurRadius = [[self propertyContainer] getFloatPropertyValue:kIXImagesDefaultBlurRadius defaultValue:20.0f];
                                              UIColor* tintColor = [[self propertyContainer] getColorPropertyValue:kIXImagesDefaultBlurTintColor defaultValue:nil];
                                              CGFloat saturation = [[self propertyContainer] getFloatPropertyValue:kIXImagesDefaultBlurSaturation defaultValue:1.8f];

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

        BOOL flipHorizontal = [[self propertyContainer] getBoolPropertyValue:kIXFlipHorizontal defaultValue:NO];
        BOOL flipVertical = [[self propertyContainer] getBoolPropertyValue:kIXFlipVertical defaultValue:NO];
        CGFloat rotate = [[self propertyContainer] getFloatPropertyValue:kIXRotate defaultValue:0.0f];
        
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
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
