//  Project name: UberClone
//  File name   : LocationManager.h
//
//  Author      : Dung Le
//  Created date: 6/19/16
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2016 Dung Le. All rights reserved.
//  --------------------------------------------------------------

#import <Foundation/Foundation.h>
@import CoreLocation;

typedef void (^LocationManagerCallback)(CLLocation *);


@interface LocationManager : NSObject<NSCoding>
{
}

+ (instancetype)sharedManager;
+ (BOOL)authorized;

@property (strong, nonatomic, readonly) CLLocationManager *locationManager;
@property (strong, nonatomic, readonly) CLLocation *recentLocation;

- (void)subscribeCurrentLocationUpdates:(LocationManagerCallback)callback;

@end


@interface LocationManager (LocationManagerCreation)

// Class's static constructors

// Class's constructors

@end
