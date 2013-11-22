//
//  IXImageControl.h
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseControl.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface IXMap : IXBaseControl
{
    MKMapView* _mapView;
}
@property (nonatomic, strong) NSArray *mIXtemList;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

