//
//  IXColorPicker.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/24/15.
//  Copyright (c) 2015 Ignite. All rights reserved.
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

@interface IXColorPicker ()

@property (nonatomic,strong) HRColorMapView* colorMapView;

@end

@implementation IXColorPicker

-(void)buildView
{
    [super buildView];

    _colorMapView = [[HRColorMapView alloc] init];
    _colorMapView.saturationUpperLimit = @1;
    _colorMapView.tileSize = @3;
    _colorMapView.brightness = 1.0;
    _colorMapView.color = [UIColor colorWithString:@"#FFFFFF"];
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

    float brightness = [[self propertyContainer] getFloatPropertyValue:kIXBrightness defaultValue:1.0f];
    if( [[self colorMapView] brightness] != brightness )
    {
        [[self colorMapView] setBrightness:brightness];
    }

    float saturation = [[self propertyContainer] getFloatPropertyValue:kIXSaturation defaultValue:1.0f];
    if( [[[self colorMapView] saturationUpperLimit] floatValue] != saturation )
    {
        [[self colorMapView] setSaturationUpperLimit:[NSNumber numberWithFloat:saturation]];
    }

    float tileSize = [[self propertyContainer] getFloatPropertyValue:kIXTileSize defaultValue:3.0f];
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
