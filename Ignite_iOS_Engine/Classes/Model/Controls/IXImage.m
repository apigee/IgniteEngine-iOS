//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXImage.h"

#import "NSString+IXAdditions.h"
#import "UIImageView+IXAdditions.h"

#import "IXWeakTimerTarget.h"
#import "IXGIFImageView.h"
#import "IXControlLayoutInfo.h"

#import "UIImage+ResizeMagick.h"
#import "UIImage+IXAdditions.h"

#import "IXLogger.h"


// IXImage Properties
static NSString* const kIXImagesDefault = @"images.default";
static NSString* const kIXImagesTouch = @"images.touch";
static NSString* const kIXImagesDefaultTintColor = @"images.default.tintColor";
static NSString* const kIXImagesTouchTintColor = @"images.touch.tintColor";
static NSString* const kIXImagesHeightMax = @"images.height.max";
static NSString* const kIXImagesWidthMax = @"images.width.max";
static NSString* const kIXGIFDuration = @"gif_duration";
static NSString* const kIXFlipHorizontal = @"flip_horizontal";
static NSString* const kIXFlipVertical = @"flip_vertical";
static NSString* const kIXRotate = @"rotate";
static NSString* const kIXImageBinary = @"image.binary";

// IXImage Manipulation -- use a resizedImageByMagick mask for these
static NSString* const kIXImagesDefaultResize = @"images.default.resize";
static NSString* const kIXImagesTouchResize = @"images.touch.resize";

// IXImage Read-Only Properties
static NSString* const kIXIsAnimating = @"is_animating";
static NSString* const kIXImageHeight = @"image.height";
static NSString* const kIXImageWidth = @"image.width";

// IXImage Events
static NSString* const kIXImagesDefaultLoaded = @"images_default_loaded";
static NSString* const kIXImagesTouchLoaded = @"images_touch_loaded";
static NSString* const kIXImagesDefaultFailed = @"images_default_failed";
static NSString* const kIXImagesTouchFailed = @"images_touch_failed";

// IXImage Functions
static NSString* const kIXStartAnimation = @"start_animation";
static NSString* const kIXRestartAnimation = @"restart_animation";
static NSString* const kIXStopAnimation = @"stop_animation";
static NSString* const kIXLoadLastPhoto = @"load_last_photo";

@interface IXImage ()

@property (nonatomic,strong) IXGIFImageView* imageView;

@property (nonatomic,strong) UIImage* defaultImage;
@property (nonatomic,strong) UIImage* touchedImage;

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
        
        [[self imageView] setHidden:!(![[self contentView] isHidden] && [[self contentView] alpha] > 0.0f)];
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        
        NSString* resizeDefault = [self.propertyContainer getStringPropertyValue:kIXImagesDefaultResize defaultValue:nil];
        NSString* resizeTouch = [self.propertyContainer getStringPropertyValue:kIXImagesTouchResize defaultValue:nil];
        NSString* touchImage = [self.propertyContainer getStringPropertyValue:kIXImagesTouch defaultValue:nil];
        UIColor *defaultTintColor = [self.propertyContainer getColorPropertyValue:kIXImagesDefaultTintColor defaultValue:nil];
        UIColor *touchTintColor = [self.propertyContainer getColorPropertyValue:kIXImagesTouchTintColor defaultValue:nil];
        
        [[self propertyContainer] getImageProperty:kIXImagesDefault
                                      successBlock:^(UIImage *image) {
                                          
                                          // if default image is to be resized, do that first
                                          if (resizeDefault)
                                              image = [image resizedImageByMagick:resizeDefault];
                                          
                                          if (defaultTintColor)
                                              image = [image tintedImageUsingColor:defaultTintColor];
                                          
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
                                      }];
        //Only load an image here if we've actually defined a touch image
        if (touchImage)
        {
            [[self propertyContainer] getImageProperty:kIXImagesTouch
                                          successBlock:^(UIImage *image) {
                                              
                                              // if touch image is to be resized, do that first
                                              if (resizeTouch)
                                                  image = [image resizedImageByMagick:resizeTouch];
                                              if (touchTintColor)
                                                  image = [image tintedImageUsingColor:touchTintColor];
                                              
                                              // Contingency that if resize or colored touch isn't defined, we're still
                                              // going to want to resize the touch image to the default.
                                              if (resizeDefault)
                                                  image = [image resizedImageByMagick:resizeDefault];
                                              if (defaultTintColor)
                                                  image = [image tintedImageUsingColor:defaultTintColor];
                                              
                                              weakSelf.touchedImage = image;
                                              [[weakSelf actionContainer] executeActionsForEventNamed:kIXImagesTouchLoaded];
                                          } failBlock:^(NSError *error) {
                                              [[weakSelf actionContainer] executeActionsForEventNamed:kIXImagesTouchFailed];
                                          }];
        }
        
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

-(void)controlViewTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesBegan:touches withEvent:event];
    if( ![self isAnimatedGIF] && [self touchedImage] )
    {
        [[self imageView] setImage:[self touchedImage]];
    }
}

-(void)controlViewTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesCancelled:touches withEvent:event];
    if( ![self isAnimatedGIF] && [self defaultImage] )
    {
        [[self imageView] setImage:[self defaultImage]];
    }
}

-(void)controlViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesEnded:touches withEvent:event];
    if( ![self isAnimatedGIF] && [self defaultImage] )
    {
        [[self imageView] setImage:[self defaultImage]];
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
