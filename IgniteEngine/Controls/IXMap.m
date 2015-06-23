//
//  IXMap.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/15/13.
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

@import MapKit;
#import "IXMap.h"
#import "MKMapView+IXAdditions.h"
#import "IXDataRowDataProvider.h"
#import "SVPulsingAnnotationView.h"

// IXMap Attributes
IX_STATIC_CONST_STRING kIXDataProviderID = @"datasource.id";
IX_STATIC_CONST_STRING kIXShowsUserLocation = @"userLocation.enabled";
IX_STATIC_CONST_STRING kIXShowsPointsOfInterest = @"pointsOfInterest.enabled";
IX_STATIC_CONST_STRING kIXShowsBuildings = @"buildings.enabled";
IX_STATIC_CONST_STRING kIXMapType = @"mapType";
IX_STATIC_CONST_STRING kIXZoomLevel = @"zoom";
IX_STATIC_CONST_STRING kIXCenterLatitude = @"center.lat";
IX_STATIC_CONST_STRING kIXCenterLongitude = @"center.long";

IX_STATIC_CONST_STRING kIXAnnotationImage = @"pin.image";
IX_STATIC_CONST_STRING kIXAnnotationImageCenterOffsetX = @"pin.centerOffset.x";
IX_STATIC_CONST_STRING kIXAnnotationImageCenterOffsetY = @"pin.centerOffset.y";
IX_STATIC_CONST_STRING kIXAnnotationTitle = @"pin.title";
IX_STATIC_CONST_STRING kIXAnnotationSubTitle = @"pin.subtitle";
IX_STATIC_CONST_STRING kIXAnnotationLatitude = @"pin.lat";
IX_STATIC_CONST_STRING kIXAnnotationLongitude = @"pin.long";
IX_STATIC_CONST_STRING kIXAnnoationAccessoryLeftImage = @"pin.leftImage";
IX_STATIC_CONST_STRING kIXAnnoationPinColor = @"pin.color";
IX_STATIC_CONST_STRING kIXAnnoationPinAnimatesDrop = @"animatePinDrop.enabled";

// kIXMapType Accepted Values
IX_STATIC_CONST_STRING kIXMapTypeStandard = @"standard";
IX_STATIC_CONST_STRING kIXMapTypeSatellite = @"satellite";
IX_STATIC_CONST_STRING kIXMapTypeHybrid = @"hybrid";

// kIXAnnoationPinColor Accepted Values
IX_STATIC_CONST_STRING kIXAnnoationPinColorRed = @"red";
IX_STATIC_CONST_STRING kIXAnnoationPinColorGreen = @"green";
IX_STATIC_CONST_STRING kIXAnnoationPinColorPurple = @"purple";

// IXMap Functions
IX_STATIC_CONST_STRING kIXReloadAnnotations = @"refreshPins";
IX_STATIC_CONST_STRING kIXShowAllAnnotations = @"showAllPins";

// IXMap Events
IX_STATIC_CONST_STRING kIXTouch = @"touch";
IX_STATIC_CONST_STRING kIXTouchUp = @"touchUp";

// Reuseable Annotation Ident
IX_STATIC_CONST_STRING kIXMapPinAnnotationIdentifier = @"kIXMapPinAnnotationIdentifier";
IX_STATIC_CONST_STRING kIXMapImageAnnotationIdentifier = @"kIXMapImageAnnotationIdentifier";

@interface IXMapAnnotation : NSObject <MKAnnotation>

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString*)title
                          subtitle:(NSString*)subTitle
                  dataRowIndexPath:(NSIndexPath*)dataRowIndexPath;

+(instancetype)mapAnnotationWithPropertyContainer:(IXAttributeContainer*)propertyContainer
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

+(instancetype)mapAnnotationWithPropertyContainer:(IXAttributeContainer*)propertyContainer
                                     rowIndexPath:(NSIndexPath*)rowIndexPath
{
    CGFloat annotationLatitude = [propertyContainer getFloatValueForAttribute:kIXAnnotationLatitude defaultValue:0.0f];
    CGFloat annotationLongitude = [propertyContainer getFloatValueForAttribute:kIXAnnotationLongitude defaultValue:0.0f];
    
    IXMapAnnotation *annotation = [[[self class] alloc] initWithCoordinate:CLLocationCoordinate2DMake(annotationLatitude, annotationLongitude)
                                                                     title:[propertyContainer getStringValueForAttribute:kIXAnnotationTitle
                                                                                                                  defaultValue:nil]
                                                                  subtitle:[propertyContainer getStringValueForAttribute:kIXAnnotationSubTitle
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

    float centerOffsetX = [[self attributeContainer] getFloatValueForAttribute:kIXAnnotationImageCenterOffsetX defaultValue:0.0f];
    float centerOffsetY = [[self attributeContainer] getFloatValueForAttribute:kIXAnnotationImageCenterOffsetY defaultValue:0.0f];
    [self setImageCenterOffset:CGPointMake(centerOffsetX, centerOffsetY)];

    [[self mapView] setShowsUserLocation:[[self attributeContainer] getBoolValueForAttribute:kIXShowsUserLocation defaultValue:NO]];
    [[self mapView] setShowsPointsOfInterest:[[self attributeContainer] getBoolValueForAttribute:kIXShowsPointsOfInterest defaultValue:YES]];
    [[self mapView] setShowsBuildings:[[self attributeContainer] getBoolValueForAttribute:kIXShowsBuildings defaultValue:YES]];

    NSString* mapType = [[self attributeContainer] getStringValueForAttribute:kIXMapType defaultValue:kIXMapTypeStandard];
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
    
    NSString* dataProviderID = [[self attributeContainer] getStringValueForAttribute:kIXDataProviderID defaultValue:nil];
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
            
            IXMapAnnotation* annotation = [IXMapAnnotation mapAnnotationWithPropertyContainer:[self attributeContainer]
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
        IXMapAnnotation* annotation = [IXMapAnnotation mapAnnotationWithPropertyContainer:[self attributeContainer]
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

    int zoomLevel = [[self attributeContainer] getIntValueForAttribute:kIXZoomLevel
                                                     defaultValue:(int)[[self mapView] ix_zoomLevel]];

    CLLocationCoordinate2D centerCoord = [[self mapView] centerCoordinate];

    CGFloat centerCoordinateLat = [[self attributeContainer] getFloatValueForAttribute:kIXCenterLatitude
                                                                     defaultValue:centerCoord.latitude];

    CGFloat centerCoordinateLong = [[self attributeContainer] getFloatValueForAttribute:kIXCenterLongitude
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
        
        NSString* imageLocation = [[self attributeContainer] getStringValueForAttribute:kIXAnnotationImage defaultValue:nil];
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
                [[self attributeContainer] getImageAttribute:kIXAnnotationImage
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
                
                BOOL animatesDrop = [[self attributeContainer] getBoolValueForAttribute:kIXAnnoationPinAnimatesDrop defaultValue:YES];
                [(MKPinAnnotationView*)annotationView setAnimatesDrop:animatesDrop];
                
                NSString* pinColor = [[self attributeContainer] getStringValueForAttribute:kIXAnnoationPinColor defaultValue:kIXAnnoationPinColorRed];
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

        NSString* leftAccessoryImage = [[self attributeContainer] getStringValueForAttribute:kIXAnnoationAccessoryLeftImage defaultValue:nil];
        if( [leftAccessoryImage length] > 0 )
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
            [annotationView setLeftCalloutAccessoryView:imageView];
            [[self attributeContainer] getImageAttribute:kIXAnnoationAccessoryLeftImage
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXReloadAnnotations] )
    {
        [self reloadMapAnnotations];
    }
    else if( [functionName isEqualToString:kIXShowAllAnnotations] )
    {
        BOOL animated = (parameterContainer == nil) ? YES : [parameterContainer getBoolValueForAttribute:kIX_ANIMATED defaultValue:YES];
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
