//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/15.
//  Copyright (c) 2013 All rights reserved.
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
#import "SVPulsingAnnotationView.h"
#import "SVAnnotation.h"


@interface IXMap ()

@property (nonatomic,strong) MKMapView* mapView;


@end
@implementation SVAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if(self = [super init])
        self.coordinate = coordinate;
    return self;
}

@end
@implementation IXMap

-(void)buildView
{
    [super buildView];
    _mapView = [[MKMapView alloc] initWithFrame: CGRectZero];
}

-(void)applySettings
{
    [super applySettings];

    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [[self propertyContainer] getFloatPropertyValue:@"width" defaultValue:0],
                                                           [[self propertyContainer] getFloatPropertyValue:@"height" defaultValue:0])];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[self propertyContainer] getFloatPropertyValue:@"placemark.latitude" defaultValue:37.331789],
                                                                   [[self propertyContainer] getFloatPropertyValue:@"placemark.longitude" defaultValue:-122.029620]);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:region animated:NO];
    
    SVAnnotation *annotation = [[SVAnnotation alloc] initWithCoordinate:coordinate];
    annotation.title = [[self propertyContainer] getStringPropertyValue:@"placemark.title" defaultValue:@"title"];
    annotation.subtitle = [[self propertyContainer] getStringPropertyValue:@"placemark.subtitle" defaultValue:@"subtitle"];
    [self.mapView addAnnotation:annotation];
    [[self contentView] addSubview:_mapView];
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[SVAnnotation class]]) {
        static NSString *identifier = @"currentLocation";
		SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if(pulsingView == nil) {
			pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationColor = [UIColor colorWithRed:0.678431 green:0 blue:0 alpha:1];
            pulsingView.canShowCallout = YES;
        }
		
		return pulsingView;
    }
    
    return nil;
}



@end



