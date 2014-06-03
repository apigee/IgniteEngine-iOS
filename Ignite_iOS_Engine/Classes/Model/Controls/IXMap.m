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

#import "IXBaseDataProvider.h"

#import "SVPulsingAnnotationView.h"
#import "SVAnnotation.h"

static NSString* const kIXDataProviderID = @"dataprovider_id";
static NSString* const kIXShowsUserLocation = @"shows_user_location";

static NSString* const kIXAnnotationImage = @"annotation.image";
static NSString* const kIXAnnotationTitle = @"annotation.title";
static NSString* const kIXAnnotationSubTitle = @"annotation.subtitle";
static NSString* const kIXAnnotationLatitude = @"annotation.latitude";
static NSString* const kIXAnnotationLongitude = @"annotation.longitude";

static NSString* const kIXTouch = @"touch";
static NSString* const kIXTouchUp = @"touch_up";

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

@end

@interface IXMap () <MKMapViewDelegate>

@property (nonatomic,strong) MKMapView* mapView;

@property (nonatomic, strong) NSString* dataProviderID;
@property (nonatomic,weak) IXBaseDataProvider* dataProvider;

@property (nonatomic,strong) NSMutableArray* annotations;

@property (nonatomic,copy) NSString* annotationImagePath;
@property (nonatomic,copy) NSString* annotationTitlePath;
@property (nonatomic,copy) NSString* annotationSubTitlePath;
@property (nonatomic,copy) NSString* annotationLatitudePath;
@property (nonatomic,copy) NSString* annotationLongitudePath;

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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
    
    [self setDataProviderID:[[self propertyContainer] getStringPropertyValue:kIXDataProviderID defaultValue:nil]];
    [self setDataProvider:[[self sandbox] getDataProviderWithID:[self dataProviderID]]];
    
    if( [self dataProvider] )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dataProviderNotification:)
                                                     name:IXBaseDataProviderDidUpdateNotification
                                                   object:[self dataProvider]];
    }
    
    [[self mapView] setShowsUserLocation:[[self propertyContainer] getBoolPropertyValue:kIXShowsUserLocation defaultValue:NO]];
    
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
    
    // Save off the Map controls original index path and dataprovider for the row data so we can reset it after we set up the annotations.
    NSIndexPath* currentSandboxIndexPath = [[self sandbox] indexPathForRowData];
    IXBaseDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];
    
    [[self sandbox] setDataProviderForRowData:[self dataProvider]];
    for( int i = 0; i < [[self dataProvider] rowCount]; i++ )
    {
        [[self sandbox] setIndexPathForRowData:[NSIndexPath indexPathForRow:i inSection:0]];
        
        CGFloat annotationLatitude = [[self propertyContainer] getFloatPropertyValue:kIXAnnotationLatitude defaultValue:0.0f];
        CGFloat annotationLongitude = [[self propertyContainer] getFloatPropertyValue:kIXAnnotationLongitude defaultValue:0.0f];
        
        IXMapAnnotation *annotation = [[IXMapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(annotationLatitude, annotationLongitude)
                                                                            title:[[self propertyContainer] getStringPropertyValue:kIXAnnotationTitle
                                                                                                                      defaultValue:nil]
                                                                         subtitle:[[self propertyContainer] getStringPropertyValue:kIXAnnotationSubTitle
                                                                                                                      defaultValue:nil]
                                                                 dataRowIndexPath:[[self sandbox] indexPathForRowData]];
        if( annotation )
        {
            [[self annotations] addObject:annotation];
        }
    }
    
    // Reset the Map controls sandbox values.
    [[self sandbox] setIndexPathForRowData:currentSandboxIndexPath];
    [[self sandbox] setDataProviderForRowData:currentSandboxDataProvider];
    
    [[self mapView] showAnnotations:[self annotations] animated:YES];
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
        
        [[self sandbox] setIndexPathForRowData:indexPathForAnnotation];
        [[self sandbox] setDataProviderForRowData:[self dataProvider]];
        
        NSString* imageLocation = [[self propertyContainer] getStringPropertyValue:kIXAnnotationImage defaultValue:nil];
        if( [imageLocation length] > 0 )
        {
            static NSString *kIXMapImageAnnotationIdentifier = @"kIXMapImageAnnotationIdentifier";
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
            static NSString *kIXMapPinAnnotationIdentifier = @"kIXMapPinAnnotationIdentifier";
            annotationView = (MKPinAnnotationView*)[[self mapView] dequeueReusableAnnotationViewWithIdentifier:kIXMapPinAnnotationIdentifier];
            
            if( annotationView == nil )
            {
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kIXMapPinAnnotationIdentifier];
                [annotationView setCanShowCallout:YES];
            }
        }
        
        if( [self actionContainer] != nil )
        {
            [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        }
        else
        {
            [annotationView setRightCalloutAccessoryView:nil];
        }
        
        // Reset the Map controls sandbox values.
        [[self sandbox] setIndexPathForRowData:currentSandboxIndexPath];
        [[self sandbox] setDataProviderForRowData:currentSandboxDataProvider];
    }
    return annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if( [control isEqual:[view rightCalloutAccessoryView]] && [[view annotation] isKindOfClass:[IXMapAnnotation class]] )
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
