#import "LocationPin.h"


@interface LocationPin () {
}

@end


@implementation LocationPin


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
- (CLLocationCoordinate2D)coordinate
{
    return self.actualCoordinate;
}

- (NSString *)actualName
{
    if (!_actualName && _place) {
        _actualName = _place.name;
    }
    return _actualName;
}


#pragma mark - Class's public methods


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


@implementation LocationPin (LocationPinCreation)


#pragma mark - Class's static constructors


#pragma mark - Class's constructors


@end
