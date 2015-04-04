//
//  IXColorPicker.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/24/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXColorPicker.h"
#import "HRColorMapView.h"
#import "ColorUtils.h"

// IXColorPicker Attributes
IX_STATIC_CONST_STRING kIXSaturation = @"saturation";
IX_STATIC_CONST_STRING kIXTileSize = @"tile.size";
IX_STATIC_CONST_STRING kIXBrightness = @"brightness";

// IXColorPicker ReadOnly Attributes
IX_STATIC_CONST_STRING kIXCurrentColor = @"color";

// IXColorPicker Events
IX_STATIC_CONST_STRING kIXColorUpdated = @"colorUpdated";

// Non property constants
IX_STATIC_CONST_FLOAT kIXSaturationDefault = 1.0f;
IX_STATIC_CONST_FLOAT kIXTileSizeDefault = 3.0f;
IX_STATIC_CONST_FLOAT kIXBrightnessDefault = 1.0f;
IX_STATIC_CONST_STRING kIXColorDefault = @"#FFFFFF"; // Note we can't change this.

@interface IXColorPicker ()

@property (nonatomic,strong) HRColorMapView* colorMapView;

@end

@implementation IXColorPicker

-(void)buildView
{
    [super buildView];

    _colorMapView = [[HRColorMapView alloc] init];
    _colorMapView.saturationUpperLimit = [NSNumber numberWithFloat:kIXSaturationDefault];
    _colorMapView.tileSize = [NSNumber numberWithFloat:kIXTileSizeDefault];
    _colorMapView.brightness = kIXBrightnessDefault;
    _colorMapView.color = [UIColor colorWithString:kIXColorDefault];
    [_colorMapView addTarget:self
                      action:@selector(colorMapColorChanged:)
            forControlEvents:UIControlEventValueChanged];

    [[self contentView] addSubview:_colorMapView];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self colorMapView] setFrame:rect];
}

-(void)applySettings
{
    [super applySettings];

    float brightness = [[self propertyContainer] getFloatPropertyValue:kIXBrightness defaultValue:kIXBrightnessDefault];
    if( [[self colorMapView] brightness] != brightness )
    {
        [[self colorMapView] setBrightness:brightness];
    }

    float saturation = [[self propertyContainer] getFloatPropertyValue:kIXSaturation defaultValue:kIXSaturationDefault];
    if( [[[self colorMapView] saturationUpperLimit] floatValue] != saturation )
    {
        [[self colorMapView] setSaturationUpperLimit:[NSNumber numberWithFloat:saturation]];
    }

    float tileSize = [[self propertyContainer] getFloatPropertyValue:kIXTileSize defaultValue:kIXTileSizeDefault];
    if( [[[self colorMapView] tileSize] floatValue] != tileSize )
    {
        [[self colorMapView] setTileSize:[NSNumber numberWithFloat:tileSize]];
    }
}

- (void)colorMapColorChanged:(UIControl <HRColorMapView> *)colorMapView {
    [[self actionContainer] executeActionsForEventNamed:kIXColorUpdated];
}

-(NSString *)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnString = nil;
    if( [propertyName isEqualToString:kIXCurrentColor] )
    {
        returnString = [[[self colorMapView] color] stringValue];
    }
    else
    {
        returnString = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnString;
}

@end
