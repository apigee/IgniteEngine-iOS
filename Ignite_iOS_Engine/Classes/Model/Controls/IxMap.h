//
//  IxImageControl.h
//  Ignite iOS Engine (Ix)
//
//  Created by Jeremy Anticouni on 11/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxBaseControl.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface IxMap : IxBaseControl
{
    MKMapView* _mapView;
}
@property (nonatomic, strong) NSArray *mIxtemList;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

