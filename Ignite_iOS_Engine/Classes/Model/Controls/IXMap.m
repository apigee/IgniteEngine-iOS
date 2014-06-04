//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 
 CONTROL
 
 - TYPE : "Map"
 
 
 - PROPERTIES
 
 * name="placemark.latitude"            default=37.331789               type="Float"
 * name="placemark.longitude"           default=37.331789               type="Float"
 * name="placemark.title"               default=""                      type="String"
 * name="placemark.subtitle"            default=""                      type="String"

 
 */

#import "IXMap.h"

@import MapKit;

#import "MKMapView+IXAdditions.h"

#import "IXBaseDataProvider.h"

#import "SVPulsingAnnotationView.h"
#import "SVAnnotation.h"

// IXMap Attributes
static NSString* const kIXDataProviderID = @"dataprovider_id";
static NSString* const kIXShowsUserLocation = @"shows_user_location";
static NSString* const kIXShowsPointsOfInterest = @"shows_points_of_interest";
static NSString* const kIXShowsBuildings = @"shows_buildings";
static NSString* const kIXMapType = @"map_type";
static NSString* const kIXZoomLevel = @"zoom_level";

static NSString* const kIXAnnotationImage = @"annotation.image";
static NSString* const kIXAnnotationTitle = @"annotation.title";
static NSString* const kIXAnnotationSubTitle = @"annotation.subtitle";
static NSString* const kIXAnnotationLatitude = @"annotation.latitude";
static NSString* const kIXAnnotationLongitude = @"annotation.longitude";

static NSString* const kIXAnnoationPinColor = @"annotation.pin.color";
static NSString* const kIXAnnoationPinAnimatesDrop = @"annotation.pin.animates_drop";

// kIXMapType Accepted Values
static NSString* const kIXMapTypeStandard = @"standard";
static NSString* const kIXMapTypeSatellite = @"satellite";
static NSString* const kIXMapTypeHybrid = @"hybrid";

// kIXAnnoationPinColor Accepted Values
static NSString* const kIXAnnoationPinColorRed = @"red";
static NSString* const kIXAnnoationPinColorGreen = @"green";
static NSString* const kIXAnnoationPinColorPurple = @"purple";

// IXMap Functions
static NSString* const kIXReloadAnnotations = @"reload_annotations";
static NSString* const kIXShowAllAnnotations = @"show_all_annotations";

// IXMap Events
static NSString* const kIXTouch = @"touch";
static NSString* const kIXTouchUp = @"touch_up";

// Reuseable Annotation Ident
static NSString* const kIXMapPinAnnotationIdentifier = @"kIXMapPinAnnotationIdentifier";
static NSString* const kIXMapImageAnnotationIdentifier = @"kIXMapImageAnnotationIdentifier";

@implementation SVAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if(self = [super init])
        self.coordinate = coordinate;
    return self;
}

@end

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

@property (nonatomic,weak) IXBaseDataProvider* dataProvider;
@property (nonatomic,assign) BOOL usesDataProviderForAnnotationData;

@property (nonatomic,strong) MKMapView* mapView;
@property (nonatomic,strong) NSMutableArray* annotations;

@end

@implementation IXMap

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
        [self setDataProvider:[[self sandbox] getDataProviderWithID:dataProviderID]];
        
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
    
    if( [self usesDataProviderForAnnotationData] && [[self dataProvider] rowCount] > 0 )
    {
        // Save off the Map controls original index path and dataprovider for the row data so we can reset it after we set up the annotations.
        NSIndexPath* currentSandboxIndexPath = [[self sandbox] indexPathForRowData];
        IXBaseDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];
        
        [[self sandbox] setDataProviderForRowData:[self dataProvider]];
        for( int i = 0; i < [[self dataProvider] rowCount]; i++ )
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
    else
    {
        IXMapAnnotation* annotation = [IXMapAnnotation mapAnnotationWithPropertyContainer:[self propertyContainer]
                                                                             rowIndexPath:nil];
        if( annotation )
        {
            [[self annotations] addObject:annotation];
        }
    }
    
    [self zoomToFitAnnotationsAndZoomLevel];
}

-(void)zoomToFitAnnotationsAndZoomLevel
{
    if( [[self propertyContainer] propertyExistsForPropertyNamed:kIXZoomLevel] )
    {
        int mapsZoomLevel = (int)[[self mapView] ix_zoomLevel];
        int zoomLevel = [[self propertyContainer] getIntPropertyValue:kIXZoomLevel defaultValue:mapsZoomLevel];
        
        [[self mapView] showAnnotations:[self annotations] animated:NO];
        [[self mapView] ix_setCenterCoordinate:[[self mapView] centerCoordinate]
                                     zoomLevel:zoomLevel
                                      animated:YES];
    }
    else
    {
        [[self mapView] showAnnotations:[self annotations] animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* annotationView = nil;
    if( [annotation isKindOfClass:[IXMapAnnotation class]] )
    {
        // Save off the Map controls original index path and dataprovider for the row data so we can reset it after we set up the annotations views.
        NSIndexPath* currentSandboxIndexPath = [[self sandbox] indexPathForRowData];
        IXBaseDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];

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
        
        if( [self usesDataProviderForAnnotationData] )
        {
            // Reset the Map controls sandbox values.
            [[self sandbox] setIndexPathForRowData:currentSandboxIndexPath];
            [[self sandbox] setDataProviderForRowData:currentSandboxDataProvider];
        }
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
            IXBaseDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];
            
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
