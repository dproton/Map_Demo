//  Project name: UberClone
//  File name   : MapViewModel.h
//
//  Author      : Dung Le
//  Created date: 6/17/16
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2016 Dung Le. All rights reserved.
//  --------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "LocationPin.h"
@import MapKit;

NS_ASSUME_NONNULL_BEGIN

@protocol MapViewModelDelegate <NSObject>

- (void)mapView:(id)mapView regionWillChangeAnimated:(BOOL)animated;
- (void)mapView:(id)mapView regionDidChangeAnimated:(BOOL)animated;
- (void)mapViewDidFinishLoadingMap:(id)mapView;

@optional
// For Apple Map only
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;

@end


@protocol MapViewModelProtocol <NSObject>

- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(nullable UIView *)view;
- (MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)region;
- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated;
- (MKCoordinateRegion)region;
- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)addAnnotations:(NSArray<id<MKAnnotation>> *)annotations;
- (void)removeAnnotation:(id <MKAnnotation>)annotation;
- (CLLocationCoordinate2D) centerCoordinate;
- (void)drawRouteFromLocation:(LocationPin *)source toLocation:(LocationPin *)destination;
- (void)removeCurrentRouteDrawing;

@optional
// For Apple Map only
- (void)showUserLocation:(BOOL)show;

@end

@interface MapViewModel : NSObject<NSCoding, MapViewModelProtocol>
{
    
}


@property (weak, nonatomic) id<MapViewModelDelegate> delegate;
@property (assign, nonatomic) BOOL mapInitialized;

@end


@interface MapViewModel (MapViewModelCreation)

// Class's static constructors

// Class's constructors
- (instancetype)initWithMapView:(id)mapView;

NS_ASSUME_NONNULL_END


@end
