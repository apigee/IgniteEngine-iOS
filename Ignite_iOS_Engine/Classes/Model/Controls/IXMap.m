//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     42034
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
 */

/**
 
 Displays a native iOS Map. Can display a single annotation, or, point to a Data Provider to display a whole heap of pins.
 

 <div id="container">
<ul>
<li><a href="../images/IXMap_0.png" data-imagelightbox="c"><img src="../images/IXMap_0.png"></a></li>
<li><a href="../images/IXMap_1.png" data-imagelightbox="c"><img src="../images/IXMap_1.png"></a></li>
<li><a href="../images/IXMap_2.png" data-imagelightbox="c"><img src="../images/IXMap_2.png"></a></li>
</ul>
</div>
 
 */

/*
 *      /Docs
 *
 */

#import "IXMap.h"

@import MapKit;

#import "MKMapView+IXAdditions.h"

#import "IXDataRowDataProvider.h"

#import "SVPulsingAnnotationView.h"

// IXMap Attributes
IX_STATIC_CONST_STRING kIXDataProviderID = @"dataprovider_id";
IX_STATIC_CONST_STRING kIXShowsUserLocation = @"shows_user_location";
IX_STATIC_CONST_STRING kIXShowsPointsOfInterest = @"shows_points_of_interest";
IX_STATIC_CONST_STRING kIXShowsBuildings = @"shows_buildings";
IX_STATIC_CONST_STRING kIXMapType = @"map_type";
IX_STATIC_CONST_STRING kIXZoomLevel = @"zoom_level";
IX_STATIC_CONST_STRING kIXCenterLatitude = @"center.latitude";
IX_STATIC_CONST_STRING kIXCenterLongitude = @"center.longitude";

IX_STATIC_CONST_STRING kIXAnnotationImage = @"annotation.image";
IX_STATIC_CONST_STRING kIXAnnotationImageCenterOffsetX = @"annotation.image.center.offset.x";
IX_STATIC_CONST_STRING kIXAnnotationImageCenterOffsetY = @"annotation.image.center.offset.y";
IX_STATIC_CONST_STRING kIXAnnotationTitle = @"annotation.title";
IX_STATIC_CONST_STRING kIXAnnotationSubTitle = @"annotation.subtitle";
IX_STATIC_CONST_STRING kIXAnnotationLatitude = @"annotation.latitude";
IX_STATIC_CONST_STRING kIXAnnotationLongitude = @"annotation.longitude";
IX_STATIC_CONST_STRING kIXAnnoationAccessoryLeftImage = @"annotation.accessory.left.image";
IX_STATIC_CONST_STRING kIXAnnoationPinColor = @"annotation.pin.color";
IX_STATIC_CONST_STRING kIXAnnoationPinAnimatesDrop = @"annotation.pin.animates_drop";

// kIXMapType Accepted Values
IX_STATIC_CONST_STRING kIXMapTypeStandard = @"standard";
IX_STATIC_CONST_STRING kIXMapTypeSatellite = @"satellite";
IX_STATIC_CONST_STRING kIXMapTypeHybrid = @"hybrid";

// kIXAnnoationPinColor Accepted Values
IX_STATIC_CONST_STRING kIXAnnoationPinColorRed = @"red";
IX_STATIC_CONST_STRING kIXAnnoationPinColorGreen = @"green";
IX_STATIC_CONST_STRING kIXAnnoationPinColorPurple = @"purple";

// IXMap Functions
IX_STATIC_CONST_STRING kIXReloadAnnotations = @"reload_annotations";
IX_STATIC_CONST_STRING kIXShowAllAnnotations = @"show_all_annotations";

// IXMap Events
IX_STATIC_CONST_STRING kIXTouch = @"touch";
IX_STATIC_CONST_STRING kIXTouchUp = @"touch_up";

// Reuseable Annotation Ident
IX_STATIC_CONST_STRING kIXMapPinAnnotationIdentifier = @"kIXMapPinAnnotationIdentifier";
IX_STATIC_CONST_STRING kIXMapImageAnnotationIdentifier = @"kIXMapImageAnnotationIdentifier";

@interface IXMapAnnotation : NSObject <MKAnnotation>

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString*)title
                          subtitle:(NSString*)subTitle
                  dataRowIndexPath:(NSIndexPath*)dataRowIndexPath;

+(instancetype)mapAnnotationWithPropertyContainer:(IXPropertyContainer*)propertyContainer
                                     rowIndexPath:(NSIndexPath*)rowIndexPath;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSIndexPath *dataRowIndexPath;

@end

@implementation IXMapAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString*)title
                          subtitle:(NSString*)subTitle
                  dataRowIndexPath:(NSIndexPath*)dataRowIndexPath
{
    self = [super init];
    if( self )
    {
        _coordinate = coordinate;
        _title = [title copy];
        _subtitle = [subTitle copy];
        _dataRowIndexPath = dataRowIndexPath;
    }
    return self;
}

+(instancetype)mapAnnotationWithPropertyContainer:(IXPropertyContainer*)propertyContainer
                                     rowIndexPath:(NSIndexPath*)rowIndexPath
{
    CGFloat annotationLatitude = [propertyContainer getFloatPropertyValue:kIXAnnotationLatitude defaultValue:0.0f];
    CGFloat annotationLongitude = [propertyContainer getFloatPropertyValue:kIXAnnotationLongitude defaultValue:0.0f];
    
    IXMapAnnotation *annotation = [[[self class] alloc] initWithCoordinate:CLLocationCoordinate2DMake(annotationLatitude, annotationLongitude)
                                                                     title:[propertyContainer getStringPropertyValue:kIXAnnotationTitle
                                                                                                                  defaultValue:nil]
                                                                  subtitle:[propertyContainer getStringPropertyValue:kIXAnnotationSubTitle
                                                                                                                  defaultValue:nil]
                                                          dataRowIndexPath:rowIndexPath];
    
    return annotation;
}

@end

@interface IXMap () <MKMapViewDelegate>

@property (nonatomic,weak) IXDataRowDataProvider* dataProvider;
@property (nonatomic,assign) BOOL usesDataProviderForAnnotationData;

@property (nonatomic,strong) MKMapView* mapView;
@property (nonatomic,strong) NSMutableArray* annotations;
@property (nonatomic,assign) CGPoint imageCenterOffset;

@end

@implementation IXMap


/*
* Docs
*
*/

/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

    @param dataprovider_id Data Provider ID<br>*(string)*
    @param shows_user_location Display user's location *(default: FALSE)*<br>*(bool)*
    @param shows_points_of_interest Show points of interest *(default: TRUE)*<br>*(bool)*
    @param shows_buildings Show buildings *(default: TRUE)*<br>*(bool)*
    @param map_type Map type *(default: standard)*<br>*standard, satellite, hybrid*
    @param zoom_level Default zoom level<br>*(int)*
    @param center.latitude Center map on this latitude<br>*(float)*
    @param center.longitude Center map on this longitude<br>*(float)*
    @param annotation.image Custom pin image<br>*(string)*
    @param annotation.image.center.offset.x Custom pin image offset X<br>*(float)*
    @param annotation.image.center.offset.y Custom pin image offset Y<br>*(float)*
    @param annotation.title Annotation title<br>*(string)*
    @param annotation.subtitle Annotation subtitle<br>*(string)*
    @param annotation.latitude Annotation latitude<br>*(float)*
    @param annotation.longitude Annotation longitude<br>*(float)*
    @param annotation.accessory.left.image Map type *(default: standard)*<br>*standard, satellite, hybrid*
    @param annotation.pin.color Annotation pin color (when not using custom pin image) *(default: red)*<br>*red, green, purple*
    @param annotation.pin.animates_drop Animate pins dropping from the sky *(default: TRUE)*<br>*(bool)*

*/

-(void)attributes
{
}
/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-info">
 <i class="ti-loop"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Returns</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>





*/

-(void)returns
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-success">
 <i class="ti-pulse"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Events</h3>
 <p>This control fires the following events:</p>
 </div>
 </div>


    @param touch Fires when an annotation is touched
    @param touch_up Fires on annotation touch up inside

*/

-(void)events
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-danger">
 <i class="ti-direction"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Functions</h3>
 <p>This control supports the following functions:</p>
 </div>
 </div>


    @param reload_annotations 
<pre class="brush: js; toolbar: false;">

</pre>
    @param show_all_annotations 
<pre class="brush: js; toolbar: false;">

</pre>
*/

-(void)functions
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-primary">
 <i class="ti-shortcode"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Example</h3>
 <p>Go on, try it out!</p>
 </div>
 </div>

<pre class="brush: js; toolbar: false;">

</pre>
*/

-(void)example
{
}

/***************************************************************/

/*
* /Docs
*
*/


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
    [_mapView setDelegate:nil];
}

-(void)buildView
{
    [super buildView];
    
    _annotations = [[NSMutableArray alloc] init];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
    [_mapView setDelegate:self];
    
    [[self contentView] addSubview:_mapView];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [[self mapView] sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self mapView] setFrame:rect];
}

-(void)applySettings
{
    [super applySettings];

    float centerOffsetX = [[self propertyContainer] getFloatPropertyValue:kIXAnnotationImageCenterOffsetX defaultValue:0.0f];
    float centerOffsetY = [[self propertyContainer] getFloatPropertyValue:kIXAnnotationImageCenterOffsetY defaultValue:0.0f];
    [self setImageCenterOffset:CGPointMake(centerOffsetX, centerOffsetY)];

    [[self mapView] setShowsUserLocation:[[self propertyContainer] getBoolPropertyValue:kIXShowsUserLocation defaultValue:NO]];
    [[self mapView] setShowsPointsOfInterest:[[self propertyContainer] getBoolPropertyValue:kIXShowsPointsOfInterest defaultValue:YES]];
    [[self mapView] setShowsBuildings:[[self propertyContainer] getBoolPropertyValue:kIXShowsBuildings defaultValue:YES]];

    NSString* mapType = [[self propertyContainer] getStringPropertyValue:kIXMapType defaultValue:kIXMapTypeStandard];
    if( [mapType isEqualToString:kIXMapTypeSatellite] ) {
        [[self mapView] setMapType:MKMapTypeSatellite];
    } else if( [mapType isEqualToString:kIXMapTypeHybrid] ) {
        [[self mapView] setMapType:MKMapTypeHybrid];
    } else {
        [[self mapView] setMapType:MKMapTypeStandard];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
    
    NSString* dataProviderID = [[self propertyContainer] getStringPropertyValue:kIXDataProviderID defaultValue:nil];
    [self setUsesDataProviderForAnnotationData:([dataProviderID length] > 0)];
    
    if( [self usesDataProviderForAnnotationData] )
    {
        [self setDataProvider:[[self sandbox] getDataRowDataProviderWithID:dataProviderID]];
        
        if( [self dataProvider] )
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(dataProviderNotification:)
                                                         name:IXBaseDataProviderDidUpdateNotification
                                                       object:[self dataProvider]];
        }
    }
    
    [self reloadMapAnnotations];
}

-(void)dataProviderNotification:(NSNotification*)notification
{
    [self reloadMapAnnotations];
}

-(void)reloadMapAnnotations
{
    [[self mapView] removeAnnotations:[self annotations]];
    [[self annotations] removeAllObjects];
    
    if( [self usesDataProviderForAnnotationData] && [[self dataProvider] rowCount:nil] > 0 )
    {
        // Save off the Map controls original index path and dataprovider for the row data so we can reset it after we set up the annotations.
        NSIndexPath* currentSandboxIndexPath = [[self sandbox] indexPathForRowData];
        IXDataRowDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];
        
        [[self sandbox] setDataProviderForRowData:[self dataProvider]];
        for( int i = 0; i < [[self dataProvider] rowCount:nil]; i++ )
        {
            NSIndexPath* rowIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [[self sandbox] setIndexPathForRowData:rowIndexPath];
            
            IXMapAnnotation* annotation = [IXMapAnnotation mapAnnotationWithPropertyContainer:[self propertyContainer]
                                                                                 rowIndexPath:rowIndexPath];
            if( annotation )
            {
                [[self annotations] addObject:annotation];
            }
        }
        
        // Reset the Map controls sandbox values.
        [[self sandbox] setIndexPathForRowData:currentSandboxIndexPath];
        [[self sandbox] setDataProviderForRowData:currentSandboxDataProvider];
    }
    else if( [self dataProvider] == nil )
    {
        IXMapAnnotation* annotation = [IXMapAnnotation mapAnnotationWithPropertyContainer:[self propertyContainer]
                                                                             rowIndexPath:nil];
        if( annotation )
        {
            [[self annotations] addObject:annotation];
        }
    }

    if( [[self annotations] count] > 0 )
    {
        [self zoomToFitAnnotationsAndZoomLevel];
    }
}

-(void)zoomToFitAnnotationsAndZoomLevel
{
    [[self mapView] showAnnotations:[self annotations] animated:NO];

    int zoomLevel = [[self propertyContainer] getIntPropertyValue:kIXZoomLevel
                                                     defaultValue:(int)[[self mapView] ix_zoomLevel]];

    CLLocationCoordinate2D centerCoord = [[self mapView] centerCoordinate];

    CGFloat centerCoordinateLat = [[self propertyContainer] getFloatPropertyValue:kIXCenterLatitude
                                                                     defaultValue:centerCoord.latitude];

    CGFloat centerCoordinateLong = [[self propertyContainer] getFloatPropertyValue:kIXCenterLongitude
                                                                      defaultValue:centerCoord.longitude];

    [[self mapView] ix_setCenterCoordinate:CLLocationCoordinate2DMake(centerCoordinateLat, centerCoordinateLong)
                                 zoomLevel:zoomLevel
                                  animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* annotationView = nil;
    if( [annotation isKindOfClass:[IXMapAnnotation class]] )
    {
        // Save off the Map controls original index path and dataprovider for the row data so we can reset it after we set up the annotations views.
        NSIndexPath* currentSandboxIndexPath = [[self sandbox] indexPathForRowData];
        IXDataRowDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];

        IXMapAnnotation* mapAnnotation = (IXMapAnnotation*)annotation;
        NSIndexPath* indexPathForAnnotation = [mapAnnotation dataRowIndexPath];
        
        if( [self usesDataProviderForAnnotationData] )
        {
            [[self sandbox] setIndexPathForRowData:indexPathForAnnotation];
            [[self sandbox] setDataProviderForRowData:[self dataProvider]];
        }
        
        NSString* imageLocation = [[self propertyContainer] getStringPropertyValue:kIXAnnotationImage defaultValue:nil];
        if( [imageLocation length] > 0 )
        {
            annotationView = [[self mapView] dequeueReusableAnnotationViewWithIdentifier:kIXMapImageAnnotationIdentifier];
            
            if( annotationView == nil )
            {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kIXMapImageAnnotationIdentifier];
                [annotationView setCanShowCallout:YES];
            }
            
            if( annotationView )
            {
                [[self propertyContainer] getImageProperty:kIXAnnotationImage
                                              successBlock:^(UIImage *image) {
                                                  [annotationView setImage:image];
                                              } failBlock:^(NSError *error) {
                                                  [annotationView setImage:nil];
                                              }];
            }
        }
        else
        {
            annotationView = (MKPinAnnotationView*)[[self mapView] dequeueReusableAnnotationViewWithIdentifier:kIXMapPinAnnotationIdentifier];
            
            if( annotationView == nil )
            {
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kIXMapPinAnnotationIdentifier];
                [annotationView setCanShowCallout:YES];
                
                BOOL animatesDrop = [[self propertyContainer] getBoolPropertyValue:kIXAnnoationPinAnimatesDrop defaultValue:YES];
                [(MKPinAnnotationView*)annotationView setAnimatesDrop:animatesDrop];
                
                NSString* pinColor = [[self propertyContainer] getStringPropertyValue:kIXAnnoationPinColor defaultValue:kIXAnnoationPinColorRed];
                if( [pinColor isEqualToString:kIXAnnoationPinColorGreen] ) {
                    [(MKPinAnnotationView*)annotationView setPinColor:MKPinAnnotationColorGreen];
                } else if( [pinColor isEqualToString:kIXAnnoationPinColorPurple] ) {
                    [(MKPinAnnotationView*)annotationView setPinColor:MKPinAnnotationColorPurple];
                } else {
                    [(MKPinAnnotationView*)annotationView setPinColor:MKPinAnnotationColorRed];
                }
            }
        }
        
        if( [[self actionContainer] hasActionsForEvent:kIXTouch] || [[self actionContainer] hasActionsForEvent:kIXTouchUp] )
        {
            [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        }
        else
        {
            [annotationView setRightCalloutAccessoryView:nil];
        }

        NSString* leftAccessoryImage = [[self propertyContainer] getStringPropertyValue:kIXAnnoationAccessoryLeftImage defaultValue:nil];
        if( [leftAccessoryImage length] > 0 )
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
            [annotationView setLeftCalloutAccessoryView:imageView];
            [[self propertyContainer] getImageProperty:kIXAnnoationAccessoryLeftImage
                                          successBlock:^(UIImage *image) {
                                              [imageView setImage:image];
                                          } failBlock:^(NSError *error) {
                                              [imageView setImage:nil];
                                          }];
        }
        else
        {
            [annotationView setLeftCalloutAccessoryView:nil];
        }

        if( [self usesDataProviderForAnnotationData] )
        {
            // Reset the Map controls sandbox values.
            [[self sandbox] setIndexPathForRowData:currentSandboxIndexPath];
            [[self sandbox] setDataProviderForRowData:currentSandboxDataProvider];
        }
    }

    if( !CGPointEqualToPoint([self imageCenterOffset], CGPointZero) ) {
        [annotationView setCenterOffset:[self imageCenterOffset]];
    }

    return annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if( [control isEqual:[view rightCalloutAccessoryView]] && [[view annotation] isKindOfClass:[IXMapAnnotation class]] )
    {
        if( [self usesDataProviderForAnnotationData] )
        {
            // Save off the Map controls original index path and dataprovider for the row data so we can reset it after we fire the actions on the annotations.
            NSIndexPath* currentSandboxIndexPath = [[self sandbox] indexPathForRowData];
            IXDataRowDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];
            
            IXMapAnnotation* mapAnnotation = (IXMapAnnotation*)[view annotation];
            NSIndexPath* indexPathForAnnotation = [mapAnnotation dataRowIndexPath];
            
            [[self sandbox] setIndexPathForRowData:indexPathForAnnotation];
            [[self sandbox] setDataProviderForRowData:[self dataProvider]];
            
            [[self actionContainer] executeActionsForEventNamed:kIXTouch];
            [[self actionContainer] executeActionsForEventNamed:kIXTouchUp];
            
            // Reset the Map controls sandbox values.
            [[self sandbox] setIndexPathForRowData:currentSandboxIndexPath];
            [[self sandbox] setDataProviderForRowData:currentSandboxDataProvider];
        }
        else
        {
            [[self actionContainer] executeActionsForEventNamed:kIXTouch];
            [[self actionContainer] executeActionsForEventNamed:kIXTouchUp];
        }
    }
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXReloadAnnotations] )
    {
        [self reloadMapAnnotations];
    }
    else if( [functionName isEqualToString:kIXShowAllAnnotations] )
    {
        BOOL animated = (parameterContainer == nil) ? YES : [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:YES];
        [[self mapView] showAnnotations:[self annotations]
                               animated:animated];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)processEndTouch:(BOOL)fireTouchActions
{
    // Map doesnt need to fire any touch actions.
}
-(void)processBeginTouch:(BOOL)fireTouchActions
{
    // Map doesnt need to fire any touch actions.
}

@end
