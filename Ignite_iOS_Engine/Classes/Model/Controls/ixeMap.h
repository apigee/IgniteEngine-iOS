//
//  ixeImageControl.h
//  Ignite iOS Engine (ixe)
//
//  Created by Jeremy Anticouni on 11/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeBaseControl.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface ixeMap : ixeBaseControl
{
    MKMapView* _mapView;
}
@property (nonatomic, strong) NSArray *mixetemList;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

