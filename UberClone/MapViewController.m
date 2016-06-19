#import "MapViewController.h"
#import "MapView.h"
#import <MapKit/MapKit.h>
#import "LocationNameView.h"
#import "SuggestionTableViewCell.h"
#import "LocationSuggestionManager.h"
#import "LocationPin.h"
#import "LocationPinView.h"
#import "LocationManager.h"

typedef NS_ENUM(NSUInteger, LocationSelectionMode) {
    LocationSelectionModeNone,
    LocationSelectionModeSource,
    LocationSelectionModeDestination,
};

typedef NS_ENUM(NSUInteger, SelectionState) {
    SelectionStateNone,
    SelectionStateAnimating,
    
};

MKMapRect MKMapRectFromMKCoordinateRegion(MKCoordinateRegion region)
{
    CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2.0, region.center.longitude + region.span.longitudeDelta/2.0);
    CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2.0, region.center.longitude - region.span.longitudeDelta/2.0);
    
    MKMapPoint topLeftPt = MKMapPointForCoordinate(topLeft);
    MKMapPoint bottomRightPt = MKMapPointForCoordinate(bottomRight);
    
    MKMapRect rect =  MKMapRectMake(
                                    MIN(topLeftPt.x, bottomRightPt.x),
                                    MIN(topLeftPt.y, bottomRightPt.y),
                                    ABS(bottomRightPt.x - topLeftPt.x),
                                    ABS(bottomRightPt.y - topLeftPt.y)
                                    );
    return rect;
}


@interface MapViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MapViewModelDelegate>
{
}

@property (strong, nonatomic) IBOutlet LocationNameView   *sourceView;
@property (strong, nonatomic) IBOutlet LocationNameView   *destinationView;
@property (strong, nonatomic) IBOutlet UITableView        *suggestionsView;
@property (strong, nonatomic) IBOutlet UIButton           *nextButton;
@property (strong, nonatomic) IBOutlet UIButton           *uberItButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *suggestionViewBottom;

@property (strong, nonatomic) UIToolbar *blurView;
@property (strong, nonatomic) MapView   *mapView;


@property (nonatomic, strong) MKLocalSearchResponse *localSearchResponse;
@property (nonatomic, strong) LocationPin *sourcePin;
@property (nonatomic, strong) LocationPin *destinationPin;

@property (nonatomic, strong) LocationPinView *pinView;

@property (nonatomic, assign) LocationSelectionMode locationSelectionMode;
@property (nonatomic, assign) SelectionState selectionState;

@property (nonatomic, strong) UIImage *sourcePinImage;
@property (nonatomic, strong) UIImage *destinationPinImage;


@property (nonatomic, assign) CGPoint pinReferencePoint;
@property (nonatomic, assign) BOOL deltaCalculated;
@property (nonatomic, assign) MKCoordinateSpan defaultSpan;
@property (nonatomic, assign) CLLocationCoordinate2D coordinateDelta;

@property (nonatomic, strong) CLGeocoder *geocoder;


/** Initialize class's private variables. */
- (void)_init;
/** Localize UI components. */
- (void)_localize;
/** Visualize all view's components. */
- (void)_visualize;

@end


@implementation MapViewController


#pragma mark - Class's constructors
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _init];
    }
    return self;
}


#pragma mark - Cleanup memory
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}


#pragma mark - View's lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pinView = [LocationPinView pin];
    self.sourcePin = [[LocationPin alloc] init];
    self.destinationPin = [[LocationPin alloc] init];
    self.blurView = [[UIToolbar alloc] init];
    self.blurView.alpha = 0.5;
    self.blurView.barStyle = UIBarStyleBlack;
    [self.view addSubview:self.blurView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTapBackgroundView:)];
    [self.blurView addGestureRecognizer:tap];
    
    self.mapView = [[MapView alloc] initWithMapType:AppleMapType];
    self.mapView.delegate = self;
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.mapView];
    
    self.sourceView.color = kUISourceLocationColor;
    self.sourceView.textFieldDelegate = self;
    self.sourceView.placeholderText = @"Source";

    
    self.destinationView.color = kUIDestinationLocationColor;
    self.destinationView.textFieldDelegate = self;
    self.destinationView.placeholderText = @"Destination";

    self.locationSelectionMode = LocationSelectionModeSource;
    self.geocoder = [[CLGeocoder alloc] init];
    self.coordinateDelta = kCLLocationCoordinate2DInvalid;
    
    // Update location by GPS
    [[LocationManager sharedManager] subscribeCurrentLocationUpdates:^(CLLocation *location)
    {
        [self _updateMapViewFirstTime];
    }];
    
    
    [self _visualize];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self _localize];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    static BOOL refPointRegistered = NO;
    
    if (!refPointRegistered)
    {
        refPointRegistered = YES;
        
        // set a test layout center
        // HCM city
        [self _setLat:10.762622 lon:106.660172];
        
        // layout pin from its center
        self.pinView.center = CGPointMake(CGRectGetMidX(self.mapView.frame), CGRectGetMidY(self.mapView.frame));
        
        // the point under which we have actual marker
        self.pinReferencePoint = CGPointMake(self.pinView.center.x, CGRectGetMaxY(self.pinView.frame));
        
    }
    
    if (!CLLocationCoordinate2DIsValid(self.coordinateDelta))
    {
        // Calculate offsets for reference point
        CLLocationCoordinate2D coordUnderPin = [self.mapView convertPoint:self.pinReferencePoint toCoordinateFromView:self.view];
        CLLocationCoordinate2D coordAtCenter = self.mapView.centerCoordinate;
        
        self.coordinateDelta = CLLocationCoordinate2DMake(coordUnderPin.latitude - coordAtCenter.latitude, coordUnderPin.longitude - coordAtCenter.longitude);

    }
    
    // layout pin from its center
    self.pinView.center = CGPointMake(CGRectGetMidX(self.mapView.frame), CGRectGetMidY(self.mapView.frame));
    
}


#pragma mark - View's memory handler
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - View's orientation handler
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


#pragma mark - View's status handler
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


#pragma mark - View's transition event handler
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


#pragma mark - View's key pressed event handlers
- (IBAction)keyPressed:(id)sender {
}


#pragma mark - Class's properties


#pragma mark - Class's public methods


#pragma mark - Class's private methods
- (void)_init {
}
- (void)_localize {
}
- (void)_visualize
{
    [self.view sendSubviewToBack:self.blurView];
    [self.view sendSubviewToBack:self.mapView];
    [self.view insertSubview:self.pinView aboveSubview:self.mapView];
    [self _enableNextButton:NO];
    
    self.suggestionsView.tableFooterView = [UIView new];
    self.suggestionsView.hidden = YES;
    
//    self.navigationController.hidesBarsWhenKeyboardAppears = YES;
   
}

// Priority first, map view frame can affect its methods
- (void)addContraintForMapView
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_mapView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_mapView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];

}

- (void)updateViewConstraints
{
    [self addContraintForMapView];
    [super updateViewConstraints];
}


#pragma mark - Class's notification handlers


#pragma mark - Event handler
- (void)_onTapBackgroundView:(id)sender
{
    [self _resetViews];
}

- (void)setLocationSelectionMode:(LocationSelectionMode)locationSelectionMode
{
    _locationSelectionMode = locationSelectionMode;
    CGFloat alphaBlur = 0.5;
    
    
    if (_locationSelectionMode == LocationSelectionModeSource)
    {
        self.pinView.innerColor = kUISourceLocationColor;
        if (!self.sourcePinImage)
        {
            self.sourcePinImage = self.pinView.image;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.sourceView.alpha = 1;
            self.destinationView.alpha = alphaBlur;
        }];
        
    }
    else if (_locationSelectionMode == LocationSelectionModeDestination)
    {
        self.pinView.innerColor = kUIDestinationLocationColor;
        if (!self.destinationPinImage)
        {
            self.destinationPinImage = self.pinView.image;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.sourceView.alpha = alphaBlur;
            self.destinationView.alpha = 1;
        }];
        
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.sourceView.alpha = alphaBlur;
            self.destinationView.alpha = alphaBlur;
        }];
    }
    
    [self _updateAnnotations];
}


- (void)_updateAnnotations
{
    [self.mapView removeAnnotation:self.sourcePin];
    [self.mapView removeAnnotation:self.destinationPin];
    
    NSMutableArray *annotations = [NSMutableArray new];
    
    // In animating mode or if we are in the re view mode,
    // we show both placeholders if available
    
    if (self.locationSelectionMode == LocationSelectionModeNone || self.selectionState == SelectionStateAnimating)
    {
        if (self.sourcePin.place && self.destinationPin.place)
        {
            [annotations addObject:self.sourcePin];
            [annotations addObject:self.destinationPin];
        }
        self.pinView.hidden = YES;
    }
    
    else if (self.locationSelectionMode == LocationSelectionModeSource)
    {
        if (self.destinationPin.place)
        {
            [annotations addObject:self.destinationPin];
        }
            self.pinView.hidden = NO;
    }
    else if (self.locationSelectionMode == LocationSelectionModeDestination)
    {
        if (self.sourcePin.place)
        {
            [annotations addObject:self.sourcePin];
        }
        self.pinView.hidden = NO;
    }
    
    [self.mapView addAnnotations:annotations];
    
}


- (void)_updateSuitableLocationLabels:(NSArray *)placemarks forCoord:(CLLocationCoordinate2D)coord
{
    if (placemarks.count == 0)
    {
        return;
    }
    
    CLPlacemark *place = [placemarks firstObject];
    
    if (self.locationSelectionMode == LocationSelectionModeSource)
    {
        self.sourcePin.place = place;
        
//        if (!CLLocationCoordinate2DIsValid(coord))
//        {
//            self.sourcePin.actualCoordinate = place.location.coordinate;
//        }
//        else
//        {
//            self.sourcePin.actualCoordinate = coord;
//        }

        self.sourcePin.actualCoordinate = CLLocationCoordinate2DIsValid(coord) ? coord : place.location.coordinate;
        self.sourceView.locationText = place.name;
        
        //[self calculateCenterOffsetsIfRequired];
        
    }
    else if (self.locationSelectionMode == LocationSelectionModeDestination)
    {
        self.destinationPin.place = place;
//        if (!CLLocationCoordinate2DIsValid(coord))
//        {
//            self.destinationPin.actualCoordinate = place.location.coordinate;
//        }
//        else
//        {
//            self.destinationPin.actualCoordinate = coord;
//        }
        
        self.destinationPin.actualCoordinate = CLLocationCoordinate2DIsValid(coord) ? coord : place.location.coordinate;
        self.destinationView.locationText = place.name;
    }
    
    [self _updateAnnotations];
    
    if (self.sourcePin.place && self.destinationPin.place)
    {
        [self _enableNextButton:YES];
    }
    else
    {
        [self _enableNextButton:NO];
    }
}

- (void)_setLat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon
{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
    MKCoordinateRegion baseRegion = MKCoordinateRegionMakeWithDistance(coord, 1350, 1350);
    MKCoordinateRegion adjRegion = [self.mapView regionThatFits:baseRegion];
    [self.mapView setRegion:adjRegion animated:NO];
}

- (void)_setUnderPinLat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon
{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat - self.coordinateDelta.latitude, lon - self.coordinateDelta.longitude);
    MKCoordinateRegion baseRegion = MKCoordinateRegionMakeWithDistance(coord, 1350, 1350);
    MKCoordinateRegion adjRegion = [self.mapView regionThatFits:baseRegion];
    [self.mapView setRegion:adjRegion animated:YES];
}

- (void)_reverseGeocodeVisiblePin
{
    if (self.locationSelectionMode == LocationSelectionModeNone)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.geocoder cancelGeocode];

    CLLocationCoordinate2D coord = [self.mapView convertPoint:self.pinReferencePoint toCoordinateFromView:self.view];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        [weakSelf _updateSuitableLocationLabels:placemarks forCoord:coord];
    }];
    
}

- (void)_updateMapViewFirstTime
{
    static BOOL didShowFirstView = NO;
    if (!didShowFirstView)
    {
        didShowFirstView = YES;
        
        self.mapView.showsUserLocation = YES;
        CLLocation *recentLocation = [[LocationManager sharedManager] recentLocation];
        [self _setUnderPinLat:recentLocation.coordinate.latitude lon:recentLocation.coordinate.longitude];
    }
    
}

- (void)_enableNextButton:(BOOL)enable
{
    if (enable) {
        self.nextButton.alpha = 1;
        self.nextButton.userInteractionEnabled = YES;
    } else {
        self.nextButton.alpha = 0.2;
        self.nextButton.userInteractionEnabled = NO;
    }
}

- (IBAction)switchToReviewMapMode:(id)sender
{
    self.locationSelectionMode = LocationSelectionModeNone;
    
    self.nextButton.hidden = YES;
    self.uberItButton.hidden = NO;
    
    [self _updateAnnotations];
    
    if (self.sourcePin.place && self.destinationPin.place)
    {
        MKCoordinateRegion r1 = MKCoordinateRegionMakeWithDistance(self.sourcePin.coordinate, 1000, 1000);
        MKCoordinateRegion r2 = MKCoordinateRegionMakeWithDistance(self.destinationPin.coordinate, 1000, 1000);
        MKCoordinateRegion region = MKCoordinateRegionForMapRect(MKMapRectUnion(MKMapRectFromMKCoordinateRegion(r1), MKMapRectFromMKCoordinateRegion(r2)));
        
        MKCoordinateRegion candidateRegion = [self.mapView regionThatFits:region];
        [self.mapView setRegion:candidateRegion animated:YES];
    }
    
//    [self.mapView drawRouteFromLocation:self.sourcePin toLocation:self.destinationPin];
    
}

- (IBAction)_uberIt:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Uber It" message:@"Coming soon !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)_switchToSelectionMode
{
    self.nextButton.hidden = NO;
    self.uberItButton.hidden = YES;
}


- (void)_resetViews
{
    [self.view endEditing:YES];
    self.suggestionsView.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - MapViewModelDelegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}



- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    // If state was animating, we already have coordinates
    // so we don't need to reverse geocode it
    if (self.selectionState == SelectionStateAnimating)
    {
        self.selectionState = SelectionStateNone;
    }
    else
    {
        // reverse geocode only if we are not animating
        if (self.mapView.mapInitialized)
        {
            [self _reverseGeocodeVisiblePin];
        }
    }
    
//    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self _reverseGeocodeVisiblePin];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == self.sourcePin || annotation == self.destinationPin)
    {
        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"loc"];
        if (!view)
        {
            view = [[MKAnnotationView alloc] initWithAnnotation:nil
                                                reuseIdentifier:@"loc"];
        }
        
        if (annotation == self.sourcePin)
        {
            view.image = self.sourcePinImage;
            view.centerOffset = CGPointMake(0, -view.image.size.height/2);
            return view;
        }
        if (annotation == self.destinationPin)
        {
            view.image = self.destinationPinImage;
            view.centerOffset = CGPointMake(0, -view.image.size.height/2);
            return view;
        }
    }
    return nil;
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.hidden = (self.localSearchResponse.mapItems.count == 0);
    return self.localSearchResponse.mapItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuggestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    MKMapItem *item = [self.localSearchResponse.mapItems objectAtIndex:indexPath.row];
    
    NSMutableArray *details = [NSMutableArray new];
    if (item.placemark.subLocality) {
        [details addObject:item.placemark.subLocality];
    }
    if (item.placemark.locality) {
        [details addObject:item.placemark.locality];
    }
    
    cell.nameLabel.text = item.name;
    cell.detailLabel.text = [details componentsJoinedByString:@", "];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.localSearchResponse.mapItems.count <= indexPath.row)
    {
        return;
    }
    
    // Update location views
    MKMapItem *item = [self.localSearchResponse.mapItems objectAtIndex:indexPath.row];
    NSArray *locationViews = @[self.sourceView, self.destinationView];
    for (LocationNameView *view in locationViews)
    {
        if (view.isFocused)
        {
            view.locationText = item.placemark.name;
            break;
        }
    }
    
    if (item.placemark)
    {
//        self.locationSelectionMode = LocationSelectionModeDestination;
        [self _updateSuitableLocationLabels:@[item.placemark ] forCoord:kCLLocationCoordinate2DInvalid];
        [self _setUnderPinLat:item.placemark.coordinate.latitude lon:item.placemark.coordinate.longitude];
    }

    
    
    [self _resetViews];
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self _switchToSelectionMode];
    
    if (self.destinationView.isFocused)
    {
        if (self.locationSelectionMode != LocationSelectionModeDestination)
        {
            // if it was set already, first zoom in to that area
            if (self.destinationPin.place)
            {
                self.selectionState = SelectionStateAnimating;
                [self _setUnderPinLat:self.destinationPin.coordinate.latitude lon:self.destinationPin.coordinate.longitude];
            }
            
            self.locationSelectionMode = LocationSelectionModeDestination;
        }
    }
    else if(self.sourceView.isFocused)
    {
        if (self.locationSelectionMode != LocationSelectionModeSource)
        {
            if (self.sourcePin.place)
            {
                self.selectionState = SelectionStateAnimating;
                [self _setUnderPinLat:self.sourcePin.coordinate.latitude lon:self.sourcePin.coordinate.longitude];
            }
            self.locationSelectionMode = LocationSelectionModeSource;
        }
    }

//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.suggestionsView.hidden = NO;
//    self.localSearchResponse = nil;
//    [self.suggestionsView reloadData];
    
    // Show blur view
    self.blurView.frame = self.mapView.frame;
    [UIView animateWithDuration:0.5f animations:^{
        self.blurView.hidden = NO;
    }];
    
    [self.view layoutIfNeeded];
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5f animations:^{
        self.blurView.hidden = YES;
        
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *currentText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (currentText.length > 0)
    {
        [[LocationSuggestionManager sharedManager] suggestLocationWithSearchString:currentText region:self.mapView.region completion:^(MKLocalSearchResponse *response, NSError *error) {
            self.localSearchResponse = response;
            [self.suggestionsView reloadData];
            
        }];
    }
    else
    {
        self.localSearchResponse = nil;
        [self.suggestionsView reloadData];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0)
    {
        NSArray *places;
        if (self.locationSelectionMode == LocationSelectionModeSource)
        {
            places = self.sourcePin.place ? @[self.sourcePin.place] : nil;
        }
        else if (self.locationSelectionMode == LocationSelectionModeDestination)
        {
            places = self.destinationPin.place ? @[self.destinationPin.place] : nil;
        }
        
        if (places.count > 0)
        {
            [self _updateSuitableLocationLabels:places forCoord:kCLLocationCoordinate2DInvalid];
        }
        
    }
    
    [self _resetViews];
    
    return YES;
}

#pragma mark - KeyboardManager
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.suggestionViewBottom.constant = kbSize.height;
    [self.view setNeedsLayout];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.suggestionViewBottom.constant = 15;
    [self.view setNeedsLayout];

}

@end
