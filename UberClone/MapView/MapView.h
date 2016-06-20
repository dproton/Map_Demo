//  Project name: UberClone
//  File name   : MapView.h
//
//  Author      : Dung Le
//  Created date: 6/17/16
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2016 Dung Le. All rights reserved.
//  --------------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MapViewModel.h"
#import "LocationPin.h"


IB_DESIGNABLE



typedef NS_ENUM(NSInteger, MapType) {
    AppleMapType,
    GoogleMapType
};


NS_ASSUME_NONNULL_BEGIN

@interface MapView : UIView {
    
@private
}

@property (nonatomic) BOOL showsUserLocation;
@property (weak, nonatomic) id<MapViewModelDelegate> delegate;

- (BOOL)mapInitialized;
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(nullable UIView *)view;
- (MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)region;
- (MKCoordinateRegion)region;
- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated;
- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)addAnnotations:(NSArray<id<MKAnnotation>> *)annotations;
- (void)removeAnnotation:(id <MKAnnotation>)annotation;
- (CLLocationCoordinate2D) centerCoordinate;
- (void)drawRouteFromLocation:(LocationPin *)source toLocation:(LocationPin *)destination;
- (void)removeCurrentRouteDrawing;

@end


@interface MapView (MapViewCreation)

// Class's static constructors

// Class's constructors
- (instancetype)initWithMapType:(MapType)mapType;

NS_ASSUME_NONNULL_END


@end