//
//  MKMapView+IXAdditions.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (IXAdditions)

-(NSUInteger)ix_zoomLevel;

- (void)ix_setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                     zoomLevel:(NSUInteger)zoomLevel
                      animated:(BOOL)animated;

-(MKCoordinateRegion)ix_coordinateRegionWithMapView:(MKMapView *)mapView
                                   centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                       andZoomLevel:(NSUInteger)zoomLevel;
@end
