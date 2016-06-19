#import "LocationSuggestionManager.h"


@interface LocationSuggestionManager () {
}

@property (nonatomic, strong) MKLocalSearch *localSearch;

@end


@implementation LocationSuggestionManager


#pragma mark - Class's constructors

+ (instancetype)sharedManager
{
    static LocationSuggestionManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

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

- (void)suggestLocationWithSearchString:(NSString *)string region:(MKCoordinateRegion)region completion:(void (^)(MKLocalSearchResponse *response, NSError *error))completionBlock
{
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = string;
    searchRequest.region = region;
    
    if (self.localSearch)
    {
        [self.localSearch cancel];
    }
    
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        completionBlock(response, error);
    }];

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


@implementation LocationSuggestionManager (LocationSuggestionManagerCreation)


#pragma mark - Class's static constructors


#pragma mark - Class's constructors


@end
