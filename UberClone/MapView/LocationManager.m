#import "LocationManager.h"


@interface LocationManager () <CLLocationManagerDelegate>
{
    
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *recentLocation;
@property (nonatomic, strong) NSMutableArray *callbacks;

@end


@implementation LocationManager


#pragma mark - Class's constructors
- (id)init {
    self = [super init];
    if (self)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        self.locationManager.delegate =  self;
        
        self.callbacks = [[NSMutableArray alloc] init];

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


+ (instancetype)sharedManager {
    static LocationManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

+ (BOOL)authorized
{
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locations.count > 0)
    {
        CLLocation *location = (CLLocation *)[locations firstObject];;
        self.recentLocation = location;
        
        for (LocationManagerCallback callback in self.callbacks)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(location);
            });
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)subscribeCurrentLocationUpdates:(LocationManagerCallback)callback
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.callbacks addObject:callback];
    });
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


@implementation LocationManager (LocationManagerCreation)


#pragma mark - Class's static constructors


#pragma mark - Class's constructors


@end
