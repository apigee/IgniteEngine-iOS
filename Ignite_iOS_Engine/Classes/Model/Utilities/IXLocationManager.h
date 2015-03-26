//
//  IXLocationManager.h
//  Ignite Engine
//
//  Created by Robert Walsh on 2/5/15.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@protocol IXLocationManagerDelegate <NSObject>

@required
-(void)locationManagerAuthStatusChanged:(CLAuthorizationStatus)status;
-(void)locationManagerDidUpdateLocation:(CLLocation*)location;

@end

@interface IXLocationManager : NSObject

@property (nonatomic,weak) id<IXLocationManagerDelegate> delegate;
@property (nonatomic,assign) CLLocationAccuracy desiredAccuracy;

@property (nonatomic,assign,readonly) BOOL isAuthorized;
@property (nonatomic,strong,readonly) CLLocation* lastKnownLocation;

+(instancetype)sharedLocationManager;

-(BOOL)requestAccessToLocation;
-(void)beginLocationTracking;
-(void)stopTrackingLocation;

@end
