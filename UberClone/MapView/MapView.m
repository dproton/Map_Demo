#import "MapView.h"
#import <MapKit/MapKit.h>
#import "MapViewModel.h"
#import "AppleMapViewModel.h"
#import "GoogleMapViewModel.h"


@interface MapView () <MKMapViewDelegate, MapViewModelDelegate>
{
    
}

@property (assign, nonatomic) MapType mapType;
@property (strong, nonatomic) MKMapView *mkMapView;
@property (strong, nonatomic) MapViewModel *mapViewModel;


/** Initialize class's private variables. */
- (void)_init;
/** Visualize all view's components. */
- (void)_visualize;

@end


@implementation MapView


#pragma mark - Class's constructors
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
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
- (instancetype)initWithMapType:(MapType)mapType
{
    self = [super init];
    if (self)
    {
        _mapType = mapType;

        switch (mapType) {
            case AppleMapType:
            {
                _mkMapView = [[MKMapView alloc] init];
                _mkMapView.translatesAutoresizingMaskIntoConstraints = NO;
                _mkMapView.rotateEnabled = NO;
                [self addSubview:_mkMapView];
                
                _mapViewModel = [[AppleMapViewModel alloc] initWithMapView:_mkMapView];
//                _mapViewModel.delegate = self;
            }
                break;
            
            case GoogleMapType:
            {
                // Google map
                // Not implement
            }
                
            default:
                break;
        }
    }
    
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self _visualize];
}
//- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    
//    CGContextRestoreGState(context);
//}

- (void)setDelegate:(id<MapViewModelDelegate>)delegate
{
    if ([delegate conformsToProtocol:@protocol(MapViewModelDelegate)] && _delegate != delegate)
    {
        _delegate = delegate;
        _mapViewModel.delegate = _delegate;
    }
}

- (BOOL)mapInitialized
{
    return self.mapViewModel.mapInitialized;
}

- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(nullable UIView *)view
{
    return [self.mapViewModel convertPoint:point toCoordinateFromView:view];
    
}

- (CLLocationCoordinate2D)centerCoordinate
{
    return self.mapViewModel.centerCoordinate;
}

- (MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)region
{
    return [self.mapViewModel regionThatFits:region];
}
- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated
{
    [self.mapViewModel setRegion:region animated:animated];
}

- (MKCoordinateRegion)region
{
    return self.mapViewModel.region;
}

- (void)addAnnotation:(id <MKAnnotation>)annotation
{
    [self.mapViewModel addAnnotation:annotation];
}

- (void)addAnnotations:(NSArray<id<MKAnnotation>> *)annotations
{
    [self.mapViewModel addAnnotations:annotations];

}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
    [self.mapViewModel removeAnnotation:annotation];
}

- (void)setShowsUserLocation:(BOOL)showsUserLocation
{
    if (_showsUserLocation != showsUserLocation)
    {
        [self.mapViewModel showUserLocation:showsUserLocation];
    }
}

- (void)drawRouteFromLocation:(LocationPin *)source toLocation:(LocationPin *)destination
{
    [self.mapViewModel drawRouteFromLocation:source toLocation:destination];
}

- (void)removeCurrentRouteDrawing
{
    [self.mapViewModel removeCurrentRouteDrawing];
}

#pragma mark - Class's private methods
- (void)_init
{
    
}
- (void)_visualize
{
    switch (self.mapType)
    {
        case AppleMapType:
        {
            NSDictionary *views = NSDictionaryOfVariableBindings(_mkMapView);
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mkMapView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mkMapView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];

        }
            break;
            
        default:
            break;
    }
    
}


@end
