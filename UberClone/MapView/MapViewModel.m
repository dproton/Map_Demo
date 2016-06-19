#import "MapViewModel.h"


@interface MapViewModel () {
}

@end


@implementation MapViewModel


#pragma mark - Class's constructors
- (id)init {
    self = [super init];
    if (self) {
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
// Inherited in sub class

- (BOOL)mapInitialized
{
    return NO;
}

- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(nullable UIView *)view
{
    return kCLLocationCoordinate2DInvalid;
}

- (MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)region
{
    return MKCoordinateRegionMake(kCLLocationCoordinate2DInvalid, MKCoordinateSpanMake(0, 0));
}

- (MKCoordinateRegion)region
{
    return MKCoordinateRegionMake(kCLLocationCoordinate2DInvalid, MKCoordinateSpanMake(0, 0));

}

- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated
{
    
}
- (void)addAnnotation:(id <MKAnnotation>)annotation
{
}
- (void)addAnnotations:(NSArray<id<MKAnnotation>> *)annotations
{
}
- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
}
- (CLLocationCoordinate2D) centerCoordinate
{
    return kCLLocationCoordinate2DInvalid;

}
- (void)drawRouteFromLocation:(LocationPin *)source toLocation:(LocationPin *)destination
{
    
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


@implementation MapViewModel (MapViewModelCreation)


#pragma mark - Class's static constructors


#pragma mark - Class's constructors
- (instancetype)initWithMapView:(id)mapView
{
    return [super init];
}

@end
