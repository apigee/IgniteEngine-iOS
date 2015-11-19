//
//  IXLocationManager.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/5/15.
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

#import "IXLocationManager.h"
#import "IXConstants.h"

@interface IXLocationManager () <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,strong) CLLocation* lastKnownLocation;

@property (nonatomic, strong) NSMutableArray *waypoints;
@property (nonatomic, strong) NSDictionary *start;
@property (nonatomic, strong) NSDictionary *stop;
@property (nonatomic, strong) NSMutableDictionary *tripData;
@property (nonatomic, assign) UIBackgroundTaskIdentifier locationTrackingTask;

@end

@implementation IXLocationManager

-(void)dealloc
{
    [_locationManager setDelegate:nil];
    [_locationManager stopUpdatingLocation];
}

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
        _shouldTrackTripData = NO;
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationManager setDistanceFilter:kCLDistanceFilterNone];
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

-(NSString*)tripDataJSON
{
    if( self.tripData != nil && [NSJSONSerialization isValidJSONObject:self.tripData] ) {
        NSError* err;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self.tripData options:0 error:&err];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

-(void)beginLocationTracking
{
    self.start = nil;
    self.stop = nil;
    self.waypoints = [NSMutableArray array];
    self.tripData = nil;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    [[self locationManager] startUpdatingLocation];
}

-(void)stopTrackingLocation
{
    [[self locationManager] stopUpdatingLocation];

    if( [self shouldTrackTripData] ) {
        if (self.waypoints != nil) {
            [self.waypoints removeLastObject];
        }

        if (self.tripData == nil) {
            self.tripData = [[NSMutableDictionary alloc]init];
        }
        if (self.start!=nil) {
            [self.tripData setObject:self.start forKey:@"start"];
        }
        if (self.waypoints!=nil) {
            [self.tripData setObject:self.waypoints forKey:@"waypoints"];
        }
        if (self.stop!=nil) {
            [self.tripData setObject:self.stop forKey:@"stop"];
        }
    }
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

    self.locationTrackingTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.locationTrackingTask];
        self.locationTrackingTask = UIBackgroundTaskInvalid;
    }];

    if( [self shouldTrackTripData] ) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
        [formatter setMaximumFractionDigits:0];

        NSDictionary *locationDict = @{@"latitude":[NSNumber numberWithDouble:mostRecentLocation.coordinate.latitude],
                                       @"longitude":[NSNumber numberWithDouble:mostRecentLocation.coordinate.longitude],
                                       @"timestamp":@([[NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970] * 1000] integerValue])};
        

        if (self.start == nil) {
            self.start = locationDict;
        } else {
            [self.waypoints addObject:locationDict];
        }
        self.stop = locationDict;

    }

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
