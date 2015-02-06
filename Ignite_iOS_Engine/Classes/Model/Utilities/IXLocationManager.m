//
//  IXLocationManager.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/5/15.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

#import "IXLocationManager.h"
#import "IXConstants.h"

@interface IXLocationManager () <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,strong) CLLocation* lastKnownLocation;

@end

@implementation IXLocationManager

+(instancetype)sharedLocationManager
{
    static IXLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IXLocationManager alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init
{
    self = [super init];
    if( self != nil )
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return self;
}

-(CLLocationAccuracy)desiredAccuracy
{
    return [[self locationManager] desiredAccuracy];
}

-(void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy
{
    [[self locationManager] setDesiredAccuracy:desiredAccuracy];
}

-(BOOL)isAuthorized
{
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    return (currentStatus != kCLAuthorizationStatusDenied && currentStatus != kCLAuthorizationStatusRestricted && currentStatus != kCLAuthorizationStatusNotDetermined);
}

-(BOOL)requestAccessToLocation
{
    BOOL didHaveAKey = YES;
    BOOL hasAlwaysKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
    BOOL hasWhenInUseKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
    if (hasAlwaysKey) {
        [self.locationManager requestAlwaysAuthorization];
    } else if (hasWhenInUseKey) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        didHaveAKey = NO;
        IX_LOG_DEBUG(@"To use location services, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.");
    }
    return didHaveAKey;
}

-(void)beginLocationTracking
{
    if( [self isAuthorized] )
    {
        [[self locationManager] startUpdatingLocation];
    }
}

-(void)stopTrackingLocation
{
    [[self locationManager] stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if( [[self delegate] respondsToSelector:@selector(locationManagerAuthStatusChanged:)] )
    {
        [[self delegate] locationManagerAuthStatusChanged:status];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *mostRecentLocation = [locations lastObject];
    CLLocationDistance distance = [[self lastKnownLocation] distanceFromLocation:mostRecentLocation];
    if( [self lastKnownLocation] == nil || distance != 0 )
    {
        [self setLastKnownLocation:mostRecentLocation];
        if( [[self delegate] respondsToSelector:@selector(locationManagerDidUpdateLocation:)] )
        {
            [[self delegate] locationManagerDidUpdateLocation:mostRecentLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    
}

@end
