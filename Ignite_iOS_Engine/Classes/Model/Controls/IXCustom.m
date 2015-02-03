//
//  IXCustom.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/28/2015
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
      "_id": "layoutTest",
      "_type": "Layout",
      "attributes": {
        "layout_type": "absolute",
        "height": 100,
        "width": 100,
        "background.color":"696969",
        "vertical_alignment":"middle",
        "horizontal_alignment":"middle"
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */


#import "IXCustom.h"

#import "IXAppManager.h"
#import "IXSandbox.h"
#import "IXPathHandler.h"
#import "IXBaseDataProvider.h"

// NSCoding Key Constants
static NSString* const kIXDataProvidersNSCodingKey = @"dataProviders";
static NSString* const kIXPathToJSONNSCodingKey = @"pathToJSON";

@interface IXSandbox ()

@property (nonatomic,strong) NSMutableDictionary* dataProviders;

@end

@interface IXCustom ()

@property (nonatomic,strong) IXSandbox* customControlSandox;

@end

@implementation IXCustom

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXCustom* customCopy = [super copyWithZone:zone];
    [customCopy setDataProviders:[self dataProviders]];
    [customCopy setPathToJSON:[self pathToJSON]];
    return customCopy;
}

-(void)buildView
{
    [super buildView];
    
    _firstLoad = YES;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self pathToJSON] forKey:kIXPathToJSONNSCodingKey];
    [aCoder encodeObject:[self dataProviders] forKey:kIXDataProvidersNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self setDataProviders:[aDecoder decodeObjectForKey:kIXDataProvidersNSCodingKey]];
        [self setPathToJSON:[aDecoder decodeObjectForKey:kIXPathToJSONNSCodingKey]];
    }
    return self;
}

-(void)setSandbox:(IXSandbox *)sandbox
{
    if( [self customControlSandox] == nil || [self customControlSandox] == sandbox )
    {
        [super setSandbox:sandbox];
    }
    else
    {
        [[self customControlSandox] setViewController:[sandbox viewController]];
        [[self customControlSandox] setContainerControl:[sandbox containerControl]];
        [[self customControlSandox] setDataProviderForRowData:[sandbox dataProviderForRowData]];
        [[self customControlSandox] setIndexPathForRowData:[sandbox indexPathForRowData]];
        
        [[self customControlSandox] setDataProviders:nil];
        if( [[[self sandbox] dataProviders] count] )
        {
            [[self customControlSandox] setDataProviders:[NSMutableDictionary dictionaryWithDictionary:[[self sandbox] dataProviders]]];
        }
        [[self customControlSandox] addDataProviders:[self dataProviders]];
    }
}

-(void)setPathToJSON:(NSString *)pathToJSON
{
    _pathToJSON = pathToJSON;
    
    NSString* jsonRootPath = nil;
    if( [IXPathHandler pathIsLocal:pathToJSON] ) {
        jsonRootPath = [pathToJSON stringByDeletingLastPathComponent];
    } else {
        jsonRootPath = [[[NSURL URLWithString:pathToJSON] URLByDeletingLastPathComponent] absoluteString];
    }
    [self setCustomControlSandox:[[IXSandbox alloc] initWithBasePath:nil rootPath:jsonRootPath]];
    [[self customControlSandox] setCustomControlContainer:self];
    [[self customControlSandox] setViewController:[[self sandbox] viewController]];
    [[self customControlSandox] setContainerControl:[[self sandbox] containerControl]];
    [[self customControlSandox] setDataProviderForRowData:[[self sandbox] dataProviderForRowData]];
    [[self customControlSandox] setIndexPathForRowData:[[self sandbox] indexPathForRowData]];
    if( [[[self sandbox] dataProviders] count] )
    {
        [[self customControlSandox] setDataProviders:[NSMutableDictionary dictionaryWithDictionary:[[self sandbox] dataProviders]]];
    }
    [[self customControlSandox] addDataProviders:[self dataProviders]];
    [self setSandbox:[self customControlSandox]];
}

-(void)applySettings
{
    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        
        // Only on firstLoad load only the data providers that are specific for this custom control.
        for( IXBaseDataProvider* dataProvider in [self dataProviders] )
        {
            [dataProvider applySettings];
            if( [dataProvider shouldAutoLoad] )
            {
                [dataProvider loadData:YES];
            }
        }
    }
    
    [super applySettings];
}

@end
