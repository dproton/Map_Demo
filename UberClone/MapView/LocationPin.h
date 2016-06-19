//  Project name: UberClone
//  File name   : LocationPin.h
//
//  Author      : Dung Le
//  Created date: 6/18/16
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2016 Dung Le. All rights reserved.
//  --------------------------------------------------------------

#import <Foundation/Foundation.h>
@import MapKit;


@interface LocationPin : NSObject<MKAnnotation> {
}

@property (nonatomic, assign) CLLocationCoordinate2D actualCoordinate;
@property (nonatomic, strong) NSString *actualName;
@property (nonatomic, strong) CLPlacemark *place;

@end

@interface LocationPin (LocationPinCreation)

// Class's static constructors

// Class's constructors

@end
