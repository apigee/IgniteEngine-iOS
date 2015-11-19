//
//  IXBeaconManager.h
//  IgniteEngineStarterKit
//
//  Created by Robert Walsh on 10/7/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

@import Foundation;
@import CoreLocation;
@import UIKit;

@class IXBeaconManager;

@protocol IXBeaconManagerDelegate <NSObject>

@required
-(void)beaconManagerEnteredRegion:(IXBeaconManager*)beaconManager;
-(void)beaconManagerExitedRegion:(IXBeaconManager*)beaconManager;

@end

@interface IXBeaconManager : NSObject

@property (weak,nonatomic) id<IXBeaconManagerDelegate> delegate;

@property (nonatomic,readonly) BOOL canMonitorBeacons;

+(IXBeaconManager*)sharedManager;

-(void)setRegionUUIDsToMonitor:(NSArray*)regionUUIDs;

-(void)startMonitoring;
-(void)stopMonitoring;

@end