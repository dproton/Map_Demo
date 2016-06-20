#import "AppleMapViewModel.h"
#import <MapKit/MapKit.h>

@interface AppleMapViewModel () <MKMapViewDelegate>
{
    
}

@property (strong, nonatomic) MKMapView *mkMapView;


@end


@implementation AppleMapViewModel

@synthesize mapInitialized = _mapInitialized;

#pragma mark - Class's constructors
- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithMapView:(id)mapView
{
    if (![mapView isKindOfClass:[MKMapView class]])
    {
        return nil;
    }
    
    self = [super init];
    {
        _mkMapView = mapView;
        _mkMapView.delegate = self;

    }
    
    return self;
}


#pragma mark - Cleanup memory
- (void)dealloc {
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}


#pragma mark - Class's properties


#pragma mark - Class's public methods
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(nullable UIView *)view
{
    return [self.mkMapView convertPoint:point toCoordinateFromView:view];
    
}

- (CLLocationCoordinate2D)centerCoordinate
{
    return self.mkMapView.centerCoordinate;
}

- (MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)region
{
    return [self.mkMapView regionThatFits:region];
}

- (MKCoordinateRegion)region
{
    return self.mkMapView.region;
}

- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated
{
    [self.mkMapView setRegion:region animated:animated];
}
- (void)addAnnotation:(id <MKAnnotation>)annotation
{
    [self.mkMapView addAnnotation:annotation];
}

- (void)addAnnotations:(NSArray<id<MKAnnotation>> *)annotations
{
    [self.mkMapView addAnnotations:annotations];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
    [self.mkMapView removeAnnotation:annotation];
}

- (void)showUserLocation:(BOOL)show
{
    self.mkMapView.showsUserLocation = show;
}

- (void)drawRouteFromLocation:(LocationPin *)source toLocation:(LocationPin *)destination
{
    [self removeCurrentRouteDrawing];
    
    MKPlacemark *sourcePlaceMark = [[MKPlacemark alloc]initWithCoordinate:source.actualCoordinate addressDictionary:nil];
    MKPlacemark *destinationPlaceMark = [[MKPlacemark alloc]initWithCoordinate:destination.actualCoordinate addressDictionary:nil];

    
//    MKPlacemark *sourcePlaceMark;
//    if (![source.place isKindOfClass:[MKPlacemark class]])
//    {
//        sourcePlaceMark = [[MKPlacemark alloc] initWithPlacemark:source.place];
//    }
//    else
//    {
//        sourcePlaceMark = (MKPlacemark *)source.place;
//    }
//    
//    MKPlacemark *destinationPlaceMark;
//
//    if (![destination.place isKindOfClass:[MKPlacemark class]])
//    {
//        destinationPlaceMark = [[MKPlacemark alloc] initWithPlacemark:destination.place];
//    }
//    else
//    {
//        destinationPlaceMark = (MKPlacemark *)destination.place;
//    }
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlaceMark];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlaceMark];
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error)
         {
             // Handle Error
         }
         else
         {
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.mkMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
//        for (MKRouteStep *step in route.steps)
//        {
//            DEBUG_LOG(@"%@", step.instructions);
//        }

    }
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
//    DEBUG_LOG(@"region Will Change");
    
    if ([self.delegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)])
    {
        [self.delegate mapView:mapView regionWillChangeAnimated:animated];
    }

}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    DEBUG_LOG(@"region Did Change");
    
    if ([self.delegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)])
    {
        [self.delegate mapView:mapView regionDidChangeAnimated:animated];
    }
    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    DEBUG_LOG(@"mapView Did Finish Loading Map");
    self.mapInitialized = YES;
    
    if ([self.delegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)])
    {
        [self.delegate mapViewDidFinishLoadingMap:mapView];
    }
}

//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
//{
//    if ([overlay isKindOfClass: [MKPolyline class]])
//    {
//        // This is for a dummy overlay to work around a problem with overlays
//        // not getting removed by the map view even though we asked for it to
//        // be removed.
//        MKOverlayView * dummyView = [[MKOverlayView alloc] init];
//        dummyView.alpha = 0.0;
//        return dummyView;
//    }
//    else
//    {
//        return nil;
//    }
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([self.delegate respondsToSelector:@selector(mapView:viewForAnnotation:)])
    {
        return [self.delegate mapView:mapView viewForAnnotation:annotation];
    }

    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *renderer = [[ MKPolylineRenderer alloc]initWithOverlay:overlay];
        renderer.lineWidth = 10;
        renderer.strokeColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [self _zoomToPolyLine:self.mkMapView polyLine:overlay animated:YES];
        return renderer;
    }
    else
    {
        return nil;
    }
}


#pragma mark - Utils

-(void)_zoomToPolyLine:(MKMapView*)map polyLine:(MKPolyline*)polyLine animated:(BOOL)animated
{
//    MKPolygon* polygon =
//    [MKPolygon polygonWithPoints:polyLine.points count:polyLine.pointCount];
//    
//    [self.mkMapView setRegion:MKCoordinateRegionForMapRect([polygon boundingMapRect])
//          animated:animated];
    
    [map setVisibleMapRect:[polyLine boundingMapRect] edgePadding:UIEdgeInsetsMake(35.0, 35.0, 35.0, 35.0) animated:animated];
}

- (void)removeCurrentRouteDrawing
{
    if (self.mkMapView.overlays.count)
    {
        [self.mkMapView removeOverlays:self.mkMapView.overlays];

    }
}



#pragma mark - Class's private methods


#pragma mark - NSCoding's members
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self && aDecoder) {
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (!aCoder) return;
}


@end


@implementation AppleMapViewModel (AppleMapViewModelCreation)


#pragma mark - Class's static constructors


#pragma mark - Class's constructors




@end
