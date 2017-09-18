//
// BBLibraryMapViewController.m
//
// Copyright (c) 2016 Mustache ApS
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "BBLibraryMapViewController.h"

@interface BBLibraryMapViewController() <CBCentralManagerDelegate>

@property (nonatomic) CBCentralManager *bluetoothManager;
@end


@implementation BBLibraryMapViewController {
    
    double scaleRatio;
    
    UIPinchGestureRecognizer *pinchGestureRecognizer;
    
    UIImageView *floorplanImageView; // BB_MAP_TAG_FLOORPLAN
    BBMyPositionView *myCurrentLocationView;   // BB_MAP_TAG_MY_POSITION
    CGFloat currentUserPrecision;
    
    CGPoint myCoordinate;
    
    BBPlace *place;
    BBFloor *currentDisplayFloorRef;
    
    // When ranging beacons we want to know which floor the user is located at
    BBFloor *rangedBeaconsFloorRef;
    BBFloor *lastRangedBeaconsFloorRef;
    
    BBLibraryMapPOIViewController *currentPOIViewController;
    BBLibrarySelectViewController *currentSelectLibraryViewController;

    BOOL zoomToUserPosition;
    BOOL zoomToMaterialPosition;

    BOOL showMaterialView;
    
    BBPopupView *popupView;
    BOOL foundSubjectPopopViewDisplayed;
    
    BOOL shouldLayoutMap;
    CGFloat lastScale;
    
    BOOL invalidLocationAlertShown;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (BBLibraryMapViewController *) mapViewController {
    return [[BBLibraryMapViewController alloc] initWithNibName:@"BBLibraryMapViewController" bundle:[NSBundle bundleWithIdentifier:@"dk.mustache.beaconbaconlib"]];
}


- (void) applyRoundAndShadow:(UIView *)view {
    
    [view layoutIfNeeded];
    
    [view.layer setShadowOffset:CGSizeMake(0, 5)];
    [view.layer setShadowOpacity:0.1f];
    [view.layer setShadowRadius:2.5f];
    [view.layer setShouldRasterize:NO];
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setCornerRadius:view.frame.size.width/2];
    
    [view.layer setShadowPath: [[UIBezierPath bezierPathWithRoundedRect:[view bounds] cornerRadius:view.frame.size.width/2] CGPath]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateMyLocationButtonEnabled];

    invalidLocationAlertShown = false;
    
    self.mapScrollView.alpha = 0.0f;

    currentUserPrecision = BB_MY_POSITION_WIDTH * 0.8f;
    
    [self setLoadingMap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapNeedsLayout) name:BB_NOTIFICATION_MAP_NEEDS_LAYOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapLayoutNow) name:BB_NOTIFICATION_MAP_LAYOUT_NOW object:nil];

    if ([BBConfig sharedConfig].currentPlaceId == nil) {
        currentSelectLibraryViewController = nil;
        currentSelectLibraryViewController = [[BBLibrarySelectViewController alloc] initWithNibName:@"BBLibrarySelectViewController" bundle:[NSBundle bundleWithIdentifier:@"dk.mustache.beaconbaconlib"]];
        currentSelectLibraryViewController.dismissAsSubview = true;
        [self.view addSubview:currentSelectLibraryViewController.view];
        [self addChildViewController:currentSelectLibraryViewController];
        return;
    }

    shouldLayoutMap = true;

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (shouldLayoutMap) {
        shouldLayoutMap = false;
        [self mapLayoutNow];
    }
}

- (void) mapLayoutNow {
    place = nil;
    currentDisplayFloorRef = nil;
    rangedBeaconsFloorRef = nil;
    lastRangedBeaconsFloorRef = nil;
    myCoordinate = CGPointZero;
   
    [self setLoadingMap];
    
    if (self.wayfindingRequstObject == nil) {
        // Wayfinding Object not set - go straight to Layout Map
        [self layoutMap];
    } else {
        // We need to check if there is a wayfinding result Object for this Map!
        [self lookForIMS];
        
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self != nil) {
        [self layoutPOI];
    }
    if (currentDisplayFloorRef != nil) {
        [self startLookingForBeacons];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void) startLookingForBeacons {
    if (place == nil || !place.beacon_positioning_enabled) {
        [self stopLookingForBeacons];
    } else {
        if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied){
            
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.locationManager.delegate = self;
            
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            
            [self.locationManager startMonitoringForRegion:[self beaconRegion]];
            [self.locationManager startRangingBeaconsInRegion:[self beaconRegion]];
            
            _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CBCentralManagerOptionShowPowerAlertKey]];
            
        } else {
            if (!invalidLocationAlertShown) {
                [self showAlert:@"Vi kan ikke finde din placering" message:@"Sørg for at aktivere bluetooth og tjek eventuelt om du har givet app’en tilladelse til at bruge lokalitet service."];
                invalidLocationAlertShown = true;
            }
        }
    }
}

- (void) stopLookingForBeacons {
    if (_locationManager != nil) {
        [_locationManager stopMonitoringForRegion:[self beaconRegion]];
        [_locationManager stopRangingBeaconsInRegion:[self beaconRegion]];
        _locationManager = nil;
    }
    
    if (_bluetoothManager != nil) {
        [_bluetoothManager stopScan];
        _bluetoothManager = nil;
    }
}


- (void) lookForIMS {
    
    self.materialTopTitleLabel.text = @"";
    self.materialTopSubtitleLabel.text = @"";
    self.materialTopImageView.image = nil;
    
    if (self.wayfindingRequstObject == nil || self.wayfindingRequstObject.faust == nil) {
        self.foundSubject = nil;
        [self layoutMap];
        return;
    }
    
    [[BBDataManager sharedInstance] requestFindIMSSubject:self.wayfindingRequstObject withCompletion:^(BBFoundSubject *result, NSError *error) {
        self.foundSubject = result;
        [self layoutMap];
    }];

}

- (CLBeaconRegion*) beaconRegion {
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"identifier"];
    return beaconRegion;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // This delegate method will monitor for any changes in bluetooth state and respond accordingly
    NSString *stateString = nil;
    switch(_bluetoothManager.state) {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent.";
            myCurrentLocationView.hidden = YES;
            break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy.";
            myCurrentLocationView.hidden = YES;
            break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            myCurrentLocationView.hidden = YES;
            break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off.";
            myCurrentLocationView.hidden = YES;
            if (!invalidLocationAlertShown) {
                [self showAlert:@"Vi kan ikke finde din placering" message:@"Sørg for at aktivere bluetooth og tjek eventuelt om du har givet app’en tilladelse til at bruge lokalitet service."];
                invalidLocationAlertShown = true;
            }
            break;
        default: stateString = @"State unknown, update imminent.";
            myCurrentLocationView.hidden = YES;
            break;
    }
    
    [self updateMyLocationButtonEnabled];
    NSLog(@"Bluetooth State: %@",stateString);

}

- (void)showAlert:(NSString*)title message:(NSString*)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UI Helpers

- (void) updateNavBarNextPrevButtons {
    if (currentDisplayFloorRef == nil) {
        return;
    }
    
    if (place.floors.count <= 1) {
        self.navBarNextButton.enabled = NO;
        self.navBarPreviousButton.enabled = NO;
    } else {
        NSInteger idx = [place.floors indexOfObject:currentDisplayFloorRef];
        
        self.navBarPreviousButton.enabled = idx >= 1;
        self.navBarNextButton.enabled = idx != place.floors.count-1;
    }

}

- (void) layoutCurrentFloorplan {
    
    __weak __typeof__(self) weakSelf = self;

    [UIImageView loadImageFromURL:[NSURL URLWithString:currentDisplayFloorRef.image_url] completionBlock:^(UIImage *image, NSError *error) {
        if (error == nil) {
            if (image == nil) {
                NSLog(@"An error occured: %@", @"No Image");
                [weakSelf.spinner stopAnimating];
            } else {
                if (floorplanImageView == nil) {
                    floorplanImageView = [[UIImageView alloc] initWithImage:image];
                    floorplanImageView.tag = BB_MAP_TAG_FLOORPLAN;
                }
                
                floorplanImageView.image = image;
                scaleRatio = [self minScale];
                floorplanImageView.frame = CGRectMake(0, 0, image.size.width * scaleRatio, image.size.height * scaleRatio);

                // Default Scale Ratio
                [weakSelf.mapScrollView setContentSize: floorplanImageView.frame.size];
                
                CGPoint center = floorplanImageView.center;
                CGRect frame = weakSelf.mapScrollView.frame;
                
                [weakSelf.mapScrollView setContentOffset:CGPointMake(center.x - frame.size.width/2, center.y - frame.size.height/2)];
                
                [weakSelf.mapScrollView addSubview:floorplanImageView]; // INDEX 0
                [weakSelf.spinner stopAnimating];
                
                [UIView animateWithDuration:BB_FADE_DURATION animations:^{
                    if (currentDisplayFloorRef.map_background_color != nil) {
                        self.mapScrollView.backgroundColor = currentDisplayFloorRef.map_background_color;
                    } else {
                        self.mapScrollView.backgroundColor = [self colorAtImage:image xCoordinate:0 yCoordinate:0];
                    }
                    self.mapScrollView.alpha = 1.0f;
                    
                } completion:^(BOOL finished) {
                    if (currentDisplayFloorRef.map_background_color != nil) {
                        self.view.backgroundColor = currentDisplayFloorRef.map_background_color;
                    } else {
                        self.view.backgroundColor = [self colorAtImage:image xCoordinate:0 yCoordinate:0];
                    }
                }];
                
                if (zoomToMaterialPosition) {
                    [self zoomToFoundSubject];
                    zoomToMaterialPosition = NO;
                }
                
                [self layoutPOI];
            }
        } else {
            NSLog(@"An error occured: %@",error.localizedDescription);
            [weakSelf.spinner stopAnimating];
        }
    }];
    
    if (currentDisplayFloorRef == nil) {
        self.navBarTitleLabel.text = @"";
        self.navBarSubtitleLabel.text = @"";
        self.navBarNextButton.enabled = NO;
        self.navBarPreviousButton.enabled = NO;
        return;
    }
    
    self.navBarTitleLabel.text = currentDisplayFloorRef.name;
    self.navBarSubtitleLabel.text = place.name;

    [self updateNavBarNextPrevButtons];
}

- (void) setLoadingMap {
    
    for (UIView *view in self.mapScrollView.subviews) {
        [view removeFromSuperview];
    }
    self.mapScrollView.alpha = 0.0f;
    
    scaleRatio = 1.00f;
    zoomToUserPosition = NO;
    zoomToMaterialPosition = NO;
    foundSubjectPopopViewDisplayed = NO;
    self.materialTopBar.hidden = true;

    [self showMaterialView:NO animated:NO];
    
    self.mapScrollView.backgroundColor = [UIColor clearColor];
    
    self.materialPopDownView.backgroundColor    = [[BBConfig sharedConfig] customColor];
    
    self.navBarTitleLabel.font          = [[BBConfig sharedConfig] lightFontWithSize:14];
    self.navBarSubtitleLabel.font       = [[BBConfig sharedConfig] lightFontWithSize:11];
    
    self.materialTopSubtitleLabel.font  = [[BBConfig sharedConfig] lightFontWithSize:10];
    
    self.materialTopTitleLabel.font     = [[BBConfig sharedConfig] regularFontWithSize:12];
    
    [self.navBarTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.navBarSubtitleLabel setAdjustsFontSizeToFitWidth:YES];

    self.navBarTitleLabel.text = @"";
    self.navBarSubtitleLabel.text = @"";
    self.navBarTitleLabel.textColor = [UIColor colorWithRed:97.0f/255.0f green:97.0f/255.0f blue:97.0f/255.0f alpha:1.0];
    self.navBarSubtitleLabel.textColor = [UIColor colorWithRed:97.0f/255.0f green:97.0f/255.0f blue:97.0f/255.0f alpha:0.75];
    
    UITapGestureRecognizer *changeMapTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMapTapGestureAction:)];
    UITapGestureRecognizer *changeMapTapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMapTapGestureAction:)];

    [self.navBarTitleLabel setUserInteractionEnabled:YES];
    [self.navBarSubtitleLabel setUserInteractionEnabled:YES];

    [self.navBarTitleLabel addGestureRecognizer:changeMapTapGesture];
    [self.navBarSubtitleLabel addGestureRecognizer:changeMapTapGesture1];

    self.materialTopTitleLabel.textColor = [UIColor whiteColor];
    self.materialTopSubtitleLabel.textColor = [UIColor whiteColor];
    
    self.materialPopDownButton.titleLabel.font = [[BBConfig sharedConfig] lightFontWithSize:10];
    
    [self.materialPopDownButton setTitle:@"Afslut" forState:UIControlStateNormal];
    
    [self applyRoundAndShadow:self.myFoundMaterialButton];
    [self applyRoundAndShadow:self.myLocationButton];
    [self applyRoundAndShadow:self.pointsOfInterestButton];
    
    // Resize Subject Image to fit inside center of the button
    UIImage *scaledImage = [self.wayfindingRequstObject.subject_image resizeImage:CGSizeMake(25, 25)];
    
    [self.myFoundMaterialButton setImage:[scaledImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.myFoundMaterialButton.tintColor = [UIColor colorFromHexString:@"#616161"];
    
    [self showMyFoundMaterialButton:false animated:false];

    myCurrentLocationView = [[BBMyPositionView alloc] initWithFrame:CGRectMake(0, 0, BB_MY_POSITION_WIDTH, BB_MY_POSITION_WIDTH)];
    myCurrentLocationView.tag = BB_MAP_TAG_MY_POSITION;
    myCurrentLocationView.hidden = YES;
    
    [self.myLocationButton setImage:[[UIImage imageNamed:@"location-icon" inBundle:[BBConfig libBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.pointsOfInterestButton setImage:[UIImage imageNamed:@"marker-icon" inBundle:[BBConfig libBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    
    [self.mapScrollView addSubview:myCurrentLocationView]; // Index 1
    
    self.mapScrollView.bounces = YES;
    self.mapScrollView.alwaysBounceVertical = YES;
    self.mapScrollView.alwaysBounceHorizontal = YES;
    
    [self updateMapScrollViewContentInsets];
    
    pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    self.navBarNextButton.enabled = NO;
    self.navBarPreviousButton.enabled = NO;
    
    [self.spinner startAnimating];
}

- (void) layoutMap {
    
    [[BBDataManager sharedInstance] requestCurrentPlaceSetupWithCompletion:^(BBPlace *result, NSError *error) {
        if (error == nil) {
            place = result;
            
            if (place == nil) {
                return;
            }
            
            if (place.floors != nil && place.floors.count > 0) {
                
                currentDisplayFloorRef = place.floors.firstObject;
                
                BOOL isFoundSubjectOnThisPlace = false;
                if (self.foundSubject != nil && self.foundSubject.displayType != None) {
                    for (BBFloor *floor in place.floors) {
                        if (floor.floor_id == self.foundSubject.floor_id) {
                            currentDisplayFloorRef = floor;
                            isFoundSubjectOnThisPlace = true;
                            break;
                        }
                        
                    }
                }
                
                if (isFoundSubjectOnThisPlace) {
                    self.materialTopTitleLabel.text = self.wayfindingRequstObject.subject_name;
                    self.materialTopSubtitleLabel.text = self.wayfindingRequstObject.subject_subtitle;
                    self.materialTopImageView.image = [self.wayfindingRequstObject.subject_image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    self.materialTopImageView.tintColor = [UIColor whiteColor];
                    
                    [self showMyFoundMaterialButton:true animated:true];
                    
                } else {
                    if (self.wayfindingRequstObject != nil) {
                        NSString *message = [NSString stringWithFormat:@"'%@' blev ikke fundet på %@. Du kan stadig bruge kortet, eller du kan prøve at skifte bibliotek ved at klikke på biblioteksnavnet foroven.", self.wayfindingRequstObject.subject_name, place.name];
                        [[[UIAlertView alloc] initWithTitle:@"Materialet blev ikke fundet" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    }
                    self.foundSubject = nil;
                    [self showMyFoundMaterialButton:false animated:false];

                }
                
                [currentDisplayFloorRef clearAllAccuracyDataPoints];
                myCoordinate = CGPointZero;
                [self layoutCurrentFloorplan];
                [self layoutMyLocationAnimated:false];
                [self startLookingForBeacons];
           
            } else {
                
                [self.spinner stopAnimating];
                self.navBarTitleLabel.text = @"-";
                self.navBarSubtitleLabel.text = @"Skift bibliotek";
                [self showAlert:@"Der opstod en fejl" message:@"Vi kan desværre ikke finde noget kort for dit nuværende bibliotek."];
            }
            
        } else {
            [self.spinner stopAnimating];
            self.navBarTitleLabel.text = @"-";
            self.navBarSubtitleLabel.text = @"Skift bibliotek";
            [self showAlert:@"Der opstod en fejl" message:@"Vi kan desværre ikke finde noget kort for dit nuværende bibliotek."];
        }
        
    }];
}

- (void) layoutPOI {
    
        for (UIView *view in self.mapScrollView.subviews) {
            if (view.tag == BB_MAP_TAG_MY_POSITION || view.tag == BB_MAP_TAG_FLOORPLAN) {
                continue;
            } else {
                [view removeFromSuperview];
            }
        }

        if (place == nil) {
            return;
        }
    
    [[BBDataManager sharedInstance] requestSelectedPOIMenuItemsWithCompletion:^(NSArray *result, NSError *error) {
        
        if (result != nil && result.count != 0) {
            
            NSMutableDictionary *displayPOI = [NSMutableDictionary new];
            
            for (BBPOIMenuItem *menuItem in result) {
                if ([menuItem isPOIMenuItem] == YES) {
                    if (menuItem.poi.selected == YES) {
                        [displayPOI setObject:menuItem.poi forKey:[NSString stringWithFormat:@"%ld",(long)menuItem.poi.poi_id]];
                        
                    }
                }
            }
            for (BBPOILocation *poiLocation in currentDisplayFloorRef.poiLocations) {
                BBPOI *poi = [displayPOI objectForKey:[NSString stringWithFormat:@"%ld",(long)poiLocation.poi.poi_id]];
                if (poi != nil) {
                    
                    if ([poi.type isEqualToString:BB_POI_TYPE_AREA]) {
                        
                        // Layout All Areas's (at the bottom)
                        CGMutablePathRef p = CGPathCreateMutable() ;
                        CGPoint startingPoint = [poiLocation.area.firstObject CGPointValue];
                        
                        CGFloat minX = startingPoint.x;
                        CGFloat maxX = startingPoint.x;
                        
                        CGFloat minY = startingPoint.y;
                        CGFloat maxY = startingPoint.y;
                        
                        for (NSValue *pointValue in poiLocation.area) {
                            CGPoint point = [pointValue CGPointValue];
                            
                            minX = fmin(point.x, minX);
                            maxX = fmax(point.x, maxX);
                            
                            minY = fmin(point.y, minY);
                            maxY = fmax(point.y, maxY);
                        }
                        
                        CGSize size = CGSizeMake(fabs(minX - maxX), fabs(minY - maxY));
                        
                        
                        for (NSValue *pointValue in poiLocation.area) {
                            CGPoint point = [pointValue CGPointValue];
                            
                            if (pointValue == poiLocation.area.firstObject) {
                                CGPathMoveToPoint(p, NULL, floor((point.x - minX) * scaleRatio), floor((point.y - minY) * scaleRatio));
                            } else {
                                CGPathAddLineToPoint(p, NULL, floor((point.x - minX) * scaleRatio), floor((point.y - minY) * scaleRatio));
                            }
                        }
                        
                        CGPathCloseSubpath(p) ;
                        
                        CAShapeLayer *layer = [CAShapeLayer layer];
                        layer.path = p;
                        layer.fillColor = [[UIColor colorFromHexString:poiLocation.poi.hex_color] colorWithAlphaComponent:0.4].CGColor;
                        
                        
                        BBPOIAreaMapView *areaView = [[BBPOIAreaMapView alloc] initWithFrame:CGRectMake(minX * scaleRatio, minY * scaleRatio, size.width * scaleRatio, size.height * scaleRatio)];
                        
                        areaView.titleVisible = false;
                        areaView.title = poi.name;
                        [areaView.layer addSublayer:layer];
                        [self.mapScrollView insertSubview:areaView atIndex:2];  // (Index 2) + areaViews.count
                        
                    } else
                        if ([poi.type isEqualToString:BB_POI_TYPE_ICON]) {
                            // Layout All POI (at the middle)
                            CGPoint position = [poiLocation coordinate];
                            BBPOIMapView *poiView = [[BBPOIMapView alloc] initWithFrame:CGRectMake(position.x * scaleRatio - BB_POI_WIDTH/2, position.y * scaleRatio - BB_POI_WIDTH/2, BB_POI_WIDTH, BB_POI_WIDTH)];
                            poiView.titleVisible = false;
                            poiView.title = poi.name;
                            [poiView applyPOIStyle];
                            
                            [poiView.poiIconView loadImageFromURL:[NSURL URLWithString:poiLocation.poi.icon_url] completionBlock:nil];

                            [self.mapScrollView addSubview:poiView]; // (Index 2 + areaViews.count) + poiViews.count
                        }
                }
            }
        }
        
        if (self.foundSubject != nil) {
            
            if (self.foundSubject.floor_id == currentDisplayFloorRef.floor_id) {
                
                [self showMaterialView:YES animated:YES];
                
                if (self.foundSubject.displayType == Single) {
                    
                    BBFoundSubjectLocation *location = self.foundSubject.locations[0];
                    
                    if (location.type == BBLocationTypePoint) {
                        // Show a single point for the found subject
                        BBPOIMapView *foundMaterialPOIView = [[BBPOIMapView alloc] initWithFrame:CGRectMake(self.foundSubject.center.x * scaleRatio - BB_POI_WIDTH/2, self.foundSubject.center.y * scaleRatio - BB_POI_WIDTH/2, BB_POI_WIDTH, BB_POI_WIDTH)];
                        
                        [foundMaterialPOIView applyFoundSubjcetStyle];
                        
                        // Resize Subject Image to fit inside center of the button
                        UIImage *scaledImage = [self.wayfindingRequstObject.subject_image resizeImage:CGSizeMake(25, 25)];
                        
                        foundMaterialPOIView.poiIconView.image = [scaledImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        foundMaterialPOIView.poiIconView.tintColor = [UIColor whiteColor];
                        foundMaterialPOIView.titleVisible = false;
                        foundMaterialPOIView.title = self.wayfindingRequstObject.subject_name;
                        
                        [self.mapScrollView addSubview:foundMaterialPOIView];
                        
                    } else if (location.type == BBLocationTypeArea) {
                        
                        // Show a Area for the found subject
                        CGMutablePathRef p = CGPathCreateMutable() ;
                        CGPoint startingPoint = [location.area.firstObject CGPointValue];
                        
                        CGFloat minX = startingPoint.x;
                        CGFloat maxX = startingPoint.x;
                        
                        CGFloat minY = startingPoint.y;
                        CGFloat maxY = startingPoint.y;
                        
                        for (NSValue *pointValue in location.area) {
                            CGPoint point = [pointValue CGPointValue];
                            
                            minX = fmin(point.x, minX);
                            maxX = fmax(point.x, maxX);
                            
                            minY = fmin(point.y, minY);
                            maxY = fmax(point.y, maxY);
                        }
                        
                        CGSize size = CGSizeMake(fabs(minX - maxX), fabs(minY - maxY));
                        
                        
                        for (NSValue *pointValue in location.area) {
                            CGPoint point = [pointValue CGPointValue];
                            
                            if (pointValue == location.area.firstObject) {
                                CGPathMoveToPoint(p, NULL, floor((point.x - minX) * scaleRatio), floor((point.y - minY) * scaleRatio));
                            } else {
                                CGPathAddLineToPoint(p, NULL, floor((point.x - minX) * scaleRatio), floor((point.y - minY) * scaleRatio));
                            }
                        }
                        
                        CGPathCloseSubpath(p) ;
                        
                        CAShapeLayer *layer = [CAShapeLayer layer];
                        layer.path = p;
                        
                        layer.fillColor = [[[BBConfig sharedConfig] customColor] colorWithAlphaComponent:0.4].CGColor;
                        
                        BBPOIAreaMapView *areaView = [[BBPOIAreaMapView alloc] initWithFrame:CGRectMake(minX * scaleRatio, minY * scaleRatio, size.width * scaleRatio, size.height * scaleRatio)];

                        areaView.titleVisible = false;
                        areaView.title = self.wayfindingRequstObject.subject_name;
                        [areaView.layer addSublayer:layer];

                        [self.mapScrollView addSubview:areaView];
                    }
                    
                } else if (self.foundSubject.displayType == Cluster) {
                    // Show a Cluster for the found subject

                    BBFoundSubjectLocation *location = self.foundSubject.locations[0];
                    
                    // Add 100cm to make sure we encapsule the area
                    double width = ((self.foundSubject.maxDistLocations + 100) / location.map_pixel_to_centimeter_ratio) * scaleRatio;
                    
                    BBPOIMapView *foundMaterialPOIView = [[BBPOIMapView alloc] initWithFrame:CGRectMake(self.foundSubject.center.x * scaleRatio - width/2 , self.foundSubject.center.y * scaleRatio - width/2 , width , width )];
                     
                    [foundMaterialPOIView applyFoundClusterSubjcetStyle];
                    foundMaterialPOIView.titleVisible = false;
                    foundMaterialPOIView.title = self.wayfindingRequstObject.subject_name;
                    
                    [self.mapScrollView addSubview:foundMaterialPOIView];
                    
                }
                
                
                if (!foundSubjectPopopViewDisplayed && ![[NSUserDefaults standardUserDefaults] boolForKey:BB_POPUP_DONT_SHOW]) {
                    popupView = [[[BBConfig libBundle] loadNibNamed:@"BBPopupView" owner:self options:nil] firstObject];
                    popupView.labelTitle.text = @"Her er dit materiale";

                    
                    CGFloat height = BB_POPUP_HEIGHT_NORMAL;
                    
                    if (self.foundSubject.displayType == Single) {
                        
                        BBFoundSubjectLocation *location = self.foundSubject.locations[0];
                        
                        if (location.type == BBLocationTypePoint) {
                            // Show a single point for the found subject
                            
                            if (self.foundSubject.locations.count > 1) {
                                popupView.labelText.text = @"Brug knapperne i nederste højre hjørner til at navigere med. Husk du altid kan reserve dit materiale her i app, hvis du mod forventning ikke kan finde den på biblioteket.";
                                height = BB_POPUP_HEIGHT_LARGE;
                                
                            } else {
                                popupView.labelText.text = @"Brug knapperne i nederste højre hjørner til at navigere med. Husk du altid kan reserve dit materiale her i app, hvis du mod forventning ikke kan finde den på biblioteket.";
                            }
                            
                            
                        } else if (location.type == BBLocationTypeArea) {
                            // Show a Area for the found subject
                            popupView.labelText.text = @"Brug knapperne i nederste højre hjørner til at navigere med. Husk du altid kan reserve dit materiale her i app, hvis du mod forventniƒng ikke kan finde den på biblioteket.";
                            
                        }
                        
                    } else if (self.foundSubject.displayType == Cluster) {
                        // Show a Cluster for the found subject
                        popupView.labelText.text = @"Brug knapperne i nederste højre hjørner til at navigere med. Husk du altid kan reserve dit materiale her i app, hvis du mod forventniƒng ikke kan finde den på biblioteket.";
                    }
                    
                    
                        [popupView.buttonOK setTitle:@"Ok" forState:UIControlStateNormal];
                    [popupView.buttonOKDontShowAgain setTitle:@"Ok, vis ikke igen" forState:UIControlStateNormal];

                    
                    [popupView setFrame:CGRectMake(self.foundSubject.center.x * scaleRatio - BB_POPUP_WIDTH / 2, self.foundSubject.center.y * scaleRatio - height, BB_POPUP_WIDTH, height)];

                    [popupView.buttonOK addTarget:self action:@selector(popupViewButtonOKAction:) forControlEvents: UIControlEventTouchUpInside];
                    [popupView.buttonOKDontShowAgain addTarget:self action:@selector(popupViewButtonOKDontShowAgainAction:) forControlEvents: UIControlEventTouchUpInside];

                    [popupView layoutIfNeeded];
                    [self.mapScrollView addSubview:popupView]; // (Index 2 + areaViews.count + poiViews.count) + popupView (last)
                    [self zoomToFoundSubject];
                } else {
                    [self zoomToFoundSubject];
                }
                
            } else {
                [self showMaterialView:YES animated:YES];
            }
        }
        // Bring My Current Location at the top
        [myCurrentLocationView.superview bringSubviewToFront:myCurrentLocationView];
    }];
}

BOOL isRunning;
dispatch_queue_t dispatch_queue_nearest_pixel;

- (void) layoutMyLocationAnimated:(Boolean) animated {
    
    CGFloat animationDuration = animated ? myCurrentLocationView.hidden ? 0 : 6.0 : 0;
    if (!CGPointEqualToPoint(myCoordinate, CGPointZero)) {
        if (myCoordinate.x > 0 && myCoordinate.x < floorplanImageView.image.size.width &&
            myCoordinate.y > 0 && myCoordinate.y < floorplanImageView.image.size.height) {
            
            if (dispatch_queue_nearest_pixel == nil) {
                dispatch_queue_nearest_pixel = dispatch_queue_create("scanning_pixels", nil);
                isRunning = false;
            }
            __weak __typeof__(self) weakSelf = self;
            
            if (!isRunning) {
                isRunning = true;
                dispatch_async(dispatch_queue_nearest_pixel, ^{
                    CGPoint walkablePixel = CGPointMake(myCoordinate.x, myCoordinate.y);
                    CGPoint coordinate = [weakSelf nearestWalkablePixel:floorplanImageView.image xCoordinate:walkablePixel.x yCoordinate:walkablePixel.y];
                    if (!CGPointEqualToPoint(coordinate, CGPointZero)) {
                        walkablePixel = coordinate;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (CGPointEqualToPoint(walkablePixel, CGPointZero)) {
                            isRunning = false;
                            return;
                        }
                        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            
                            myCurrentLocationView.frame = CGRectMake(walkablePixel.x * scaleRatio - myCurrentLocationView.frame.size.width/2, walkablePixel.y * scaleRatio - myCurrentLocationView.frame.size.height/2, myCurrentLocationView.frame.size.height, myCurrentLocationView.frame.size.width);
                            [myCurrentLocationView.superview bringSubviewToFront:myCurrentLocationView];
                            myCurrentLocationView.hidden = NO;
                            [self zoomToMyPosition];
                            [myCurrentLocationView setPulsatingAnimationWithMaxWidth:currentUserPrecision * scaleRatio];
                            
                        } completion:nil];
                        isRunning = false;
                    });
                    
                });
            }
            
        }
    } else {
        myCurrentLocationView.hidden = YES;
    }
    
    [self updateMyLocationButtonEnabled];
}

- (void) zoomToMyPosition {
    if (zoomToUserPosition && !myCurrentLocationView.hidden) {

        CGRect position = myCurrentLocationView.frame;
        
        CGPoint center = CGPointMake(position.origin.x + position.size.width/2, position.origin.y + position.size.height/2);
        
        [self.mapScrollView setContentOffset:CGPointMake(center.x - roundf(self.mapScrollView.frame.size.width/2), center.y - roundf(self.mapScrollView.frame.size.height/2)) animated:YES];
        zoomToUserPosition = NO;
    }
}

- (void) zoomToFoundSubject {
    if (self.foundSubject) {
        CGPoint center = CGPointMake(self.foundSubject.center.x * scaleRatio, self.foundSubject.center.y * scaleRatio);
        [self.mapScrollView setContentOffset:CGPointMake(center.x - roundf(self.mapScrollView.frame.size.width/2), center.y - roundf(self.mapScrollView.frame.size.height/2)) animated:YES];
    }
}

- (CGPoint)nearestWalkablePixel:(UIImage *)image xCoordinate:(int)x yCoordinate:(int)y {
    
    CGImageRef cgImage          = image.CGImage;
    CGDataProviderRef provider  = CGImageGetDataProvider(cgImage);
    CFDataRef pixelData         = CGDataProviderCopyData(provider);
    CGPoint center              = CGPointMake(x, y);
    int centerPixelInfo         = ((image.size.width  * y) + x ) * 4;
    unsigned char *data         = (unsigned char *)CFDataGetBytePtr(pixelData);
    
    UIColor *center_color = [self colorFromPixelData:data pixelInfo:centerPixelInfo xCoordinate:center.x yCoordinate:center.y];
    if (center_color == nil || ![center_color isKindOfClass:[UIColor class]]) {
        CFRelease(pixelData);
        return CGPointZero;
    }
    
    if ([self color:center_color isEqualToColor:currentDisplayFloorRef.map_walkable_color withTolerance:0.05]) {
        CFRelease(pixelData);
        return center;
    } else {
        
        // Start looking around the center coordinate for color match
        int maxRadius = fmin(fmin(image.size.width, image.size.height) * 0.10, 100);

        for (int offset = 1 ; offset < maxRadius; offset++) {
            int matrixSize = 1 + 2 * offset; // 3x3 - 5x5 - 7x7 ...
            
            for (int row = 0; row < matrixSize; row++) {
                for (int coloumn = 0; coloumn < matrixSize; coloumn++) {
                    CGPoint coordinate;
                    if (row == 0 || row == matrixSize-1) {
                        // Top + Bottom Row - Check all elements
                        int x = center.x - ((matrixSize-1) / 2) + row;
                        int y = center.y - ((matrixSize-1) / 2) + coloumn;
                        if (x < 0 || x > image.size.width || y < 0 || x > image.size.height ) {
                            continue;
                        }
                        coordinate = CGPointMake(x, y);
                    } else {
                        // Middle rows - Only check First and Last element
                        if (coloumn == 0 ||coloumn == matrixSize-1) {
                            if (x < 0 || x > image.size.width || y < 0 || x > image.size.height ) {
                                continue;
                            }
                            coordinate = CGPointMake(center.x - ((matrixSize-1) / 2) + row, center.y - ((matrixSize-1) / 2) + coloumn);
                        } else {
                            continue;
                        }
                    }
                    int pixelInfo = ((image.size.width  * coordinate.y) + coordinate.x ) * 4;
                    UIColor *pixel_color = [self colorFromPixelData:data pixelInfo:pixelInfo xCoordinate:coordinate.x yCoordinate:coordinate.y];
                    if (center_color == nil) {
                        continue;
                    }
                    if ([self color:pixel_color isEqualToColor:currentDisplayFloorRef.map_walkable_color withTolerance:0.05]) {
                        CFRelease(pixelData);
                        return coordinate;
                    }
                }
                
            }
        }
    }

    CFRelease(pixelData);
    return CGPointZero;

}


- (UIColor *) colorFromPixelData:(unsigned char *)data pixelInfo:(int)pixelInfo xCoordinate:(int)x yCoordinate:(int)y {

    if (data == NULL || (data[0] == '\0')) {
        NSLog(@"Data is empty");
        return nil;
    }
    
    UInt8 red   = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue  = data[(pixelInfo + 2)];
    UInt8 alpha = data[(pixelInfo + 3)];
    
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f];
    
}

- (UIColor *) colorAtImage:(UIImage *)image xCoordinate:(int)x yCoordinate:(int)y {
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    int pixelInfo = ((image.size.width * y) + x ) * 4;
    unsigned char *data =  (unsigned char *)CFDataGetBytePtr(pixelData);
    
    UIColor *pixel_color = [self colorFromPixelData:data pixelInfo:pixelInfo xCoordinate:x yCoordinate:y];
    if (pixel_color == nil) {
        CFRelease(pixelData);
        return [UIColor whiteColor];
    }
    CFRelease(pixelData);
    
    return pixel_color;
}


- (BOOL)color:(UIColor *)color1 isEqualToColor:(UIColor *)color2 withTolerance:(CGFloat)tolerance {
    
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    return
    fabs(r1 - r2) <= tolerance &&
    fabs(g1 - g2) <= tolerance &&
    fabs(b1 - b2) <= tolerance &&
    fabs(a1 - a2) <= tolerance;
}

- (void) updateMyLocationButtonEnabled {
    
    [UIView animateWithDuration:0.35 animations:^{
        if ([self.bluetoothManager userPositioningAvailable]) {
            if (myCurrentLocationView.hidden) {
                if (rangedBeaconsFloorRef != nil && rangedBeaconsFloorRef.floor_id != currentDisplayFloorRef.floor_id) {
                    self.myLocationButton.alpha = 1.0f;
                    self.myLocationButton.tintColor = [UIColor colorFromHexString:@"#616161"];
                } else {
                    self.myLocationButton.alpha = 0.8f;
                    self.myLocationButton.tintColor = [UIColor colorFromHexString:@"#CECECE"];
                }
            } else {
                self.myLocationButton.alpha = 1.0f;
                self.myLocationButton.tintColor = [UIColor colorFromHexString:@"#616161"];
            }
        } else {
            self.myLocationButton.alpha = 0.8f;
            self.myLocationButton.tintColor = [UIColor colorFromHexString:@"#CECECE"];
        }
    }];
}

- (void) showMyFoundMaterialButton:(BOOL)show animated:(BOOL)animated {
    
    if (show) {
        self.myFoundMaterialButton.transform = CGAffineTransformMakeScale(0, 0);
    }
    
    [UIView animateWithDuration:animated ? 0.35 : 0.0 animations:^{
        self.myFoundMaterialButton.alpha = show ? 1.0f : 0.0;
        self.myFoundMaterialButton.transform = CGAffineTransformMakeScale(1, 1);

    }];
    
}

- (BBFloor *) floorForFloorID:(NSInteger) floorId {

    if (place == nil || place.floors == nil) {
        return nil;
    }
    
    for (BBFloor *floor in place.floors) {
        if (floor.floor_id == floorId) {
            return floor;
        }
    }
    
    return nil;
}

#pragma mark - Pop Down


- (void) showMaterialView:(BOOL)shouldShow animated:(BOOL)animated {
    CGFloat animationDuration = animated ? 0.35 : 0;
    showMaterialView = shouldShow;
    
    BBFloor *materialFloor = [self floorForFloorID:self.foundSubject.floor_id];
    if (materialFloor == nil) {
        // Don't show when floor isn't found.
        shouldShow = NO;
    }
    if (shouldShow) {
        self.materialPopDownTopConstraint.constant = 0;
    } else {
        self.materialPopDownTopConstraint.constant = -self.materialPopDownView.frame.size.height;
    }
    
    [self updateMapScrollViewContentInsets];

    [self.view needsUpdateConstraints];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void) updateMapScrollViewContentInsets {
    
    if (showMaterialView) {
        self.mapScrollView.contentInset = UIEdgeInsetsMake(BB_POPUP_HEIGHT_LARGE + self.materialPopDownView.frame.size.height, BB_POPUP_WIDTH/2, BB_POPUP_HEIGHT_LARGE, BB_POPUP_WIDTH/2);
    } else {
        self.mapScrollView.contentInset = UIEdgeInsetsMake(BB_POPUP_HEIGHT_LARGE, BB_POPUP_WIDTH/2, BB_POPUP_HEIGHT_LARGE, BB_POPUP_WIDTH/2);
    }
}

#pragma mark - Pinch Gesture


- (IBAction)handlePinch:(UIPinchGestureRecognizer *)sender {
    
    if (floorplanImageView == nil) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastScale = sender.scale;
    }
    
    if ([sender numberOfTouches] > 1 && sender.scale != lastScale) {
        // Do not touch this peice of magic calculation!
        CGPoint contentOffset = self.mapScrollView.contentOffset;
        CGPoint oldCenter = CGPointMake(contentOffset.x + self.mapScrollView.frame.size.width/2, contentOffset.y + self.mapScrollView.frame.size.height/2);
        CGPoint originalPoint = CGPointMake(oldCenter.x / scaleRatio, oldCenter.y / scaleRatio);
        
        myCurrentLocationView.hidden = YES;
        
        double maxScale = 1.0;
        double minScale = [self minScale];
        
        double scaleMultiplier = 1 + (sender.scale - lastScale);
        double newScaleRatio = scaleRatio * scaleMultiplier;
        
        scaleRatio = newScaleRatio >= maxScale ? maxScale : newScaleRatio <= minScale ? minScale : newScaleRatio;
        
        floorplanImageView.frame = CGRectMake(0, 0, floorplanImageView.image.size.width * scaleRatio, floorplanImageView.image.size.height * scaleRatio);
        self.mapScrollView.contentSize = floorplanImageView.bounds.size;

        CGPoint newCenter = CGPointMake(originalPoint.x * scaleRatio, originalPoint.y * scaleRatio);
        
        [self.mapScrollView setContentOffset:CGPointMake(newCenter.x - self.mapScrollView.frame.size.width/2, newCenter.y - self.mapScrollView.frame.size.height/2) animated:NO];
        
        [self layoutPOI];
        [self layoutMyLocationAnimated:YES];
        lastScale = sender.scale;
    }
}

- (double) minScale {
    double minScaleWidth = self.mapScrollView.bounds.size.width / floorplanImageView.image.size.width;
    double minScaleHeight = self.mapScrollView.bounds.size.height / floorplanImageView.image.size.height;
    
    return fmax(minScaleHeight, minScaleWidth);
}

#pragma mark - Actions

- (IBAction)closeButtonAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)navBarNextAction:(id)sender {
    if (currentDisplayFloorRef == nil) {
        return;
    }
    
    [UIView animateWithDuration:BB_FADE_DURATION animations:^{
        self.mapScrollView.alpha = 0.0f;
    }];
 
    NSInteger idx = [place.floors indexOfObject:currentDisplayFloorRef];
    currentDisplayFloorRef = place.floors[idx + 1];
    [currentDisplayFloorRef clearAllAccuracyDataPoints];
    myCoordinate = CGPointZero;
    [self layoutCurrentFloorplan];
    [self layoutMyLocationAnimated:NO];
}

- (IBAction)navBarPreviousAction:(id)sender {
    if (currentDisplayFloorRef == nil) {
        return;
    }
    
    [UIView animateWithDuration:BB_FADE_DURATION animations:^{
        self.mapScrollView.alpha = 0.0f;
    }];
    
    NSInteger idx = [place.floors indexOfObject:currentDisplayFloorRef];
    currentDisplayFloorRef = place.floors[idx - 1];
    [currentDisplayFloorRef clearAllAccuracyDataPoints];
    myCoordinate = CGPointZero;
    [self layoutCurrentFloorplan];
    [self layoutMyLocationAnimated:NO];
}

- (IBAction)pointsOfInterestAction:(id)sender {
    [self hidePopupView];

    currentPOIViewController = nil;
    currentPOIViewController = [[BBLibraryMapPOIViewController alloc] initWithNibName:@"BBLibraryMapPOIViewController" bundle:[BBConfig libBundle]];
    [self presentViewController:currentPOIViewController animated:true completion:nil];
}

- (IBAction)myLocationAction:(id)sender {
    if (!place.beacon_positioning_enabled) {
        [self showAlert:@"Din placering" message:@"Din placering kan ikke lokaliseres på dette bibliotek. Denne løsning virker pt. kun på udvalgte biblioteker."];
    } else if ([self.bluetoothManager userPositioningAvailable]) {
        if ((myCurrentLocationView.hidden && currentDisplayFloorRef.floor_id == rangedBeaconsFloorRef.floor_id) || (myCurrentLocationView.hidden && rangedBeaconsFloorRef == nil)) {
            [self showAlert:@"Din placering" message:@"Vi er i gang med at lokalisere din nuværende placering, vi viser den på kortet, så snart vi har fundet den."];
        } else {
             if (rangedBeaconsFloorRef != nil) {
                if (currentDisplayFloorRef.floor_id != rangedBeaconsFloorRef.floor_id) {
                    currentDisplayFloorRef = rangedBeaconsFloorRef;
                    [currentDisplayFloorRef clearAllAccuracyDataPoints];
                    zoomToUserPosition = YES;
                    [self layoutCurrentFloorplan];
                    [self layoutMyLocationAnimated:NO];
                } else {
                    zoomToUserPosition = YES;
                    [self layoutMyLocationAnimated:NO];
                }
            }
        }
    } else {
        [self showAlert:@"Vi kan ikke finde din placering" message:@"Sørg for at aktivere bluetooth og tjek eventuelt om du har givet app’en tilladelse til at bruge lokalitet service."];
    }
}

- (IBAction)myFoundMaterialButtonAction:(id)sender {
    if (currentDisplayFloorRef.floor_id != self.foundSubject.floor_id) {
        [currentDisplayFloorRef clearAllAccuracyDataPoints];

        if (self.foundSubject != nil) {
            for (BBFloor *floor in place.floors) {
                if (floor.floor_id == self.foundSubject.floor_id) {
                    currentDisplayFloorRef = floor;
                    break;
                }
            }
        }
        myCoordinate = CGPointZero;
        [currentDisplayFloorRef clearAllAccuracyDataPoints];
        myCurrentLocationView.hidden = YES;
        zoomToMaterialPosition = YES;
        
        [self layoutCurrentFloorplan];

    } else {
        [self zoomToFoundSubject];
        
    }

}

- (void) changeMapTapGestureAction:(UITapGestureRecognizer *)recognizer {
    [self hidePopupView];

    currentSelectLibraryViewController = nil;
    currentSelectLibraryViewController = [[BBLibrarySelectViewController alloc] initWithNibName:@"BBLibrarySelectViewController" bundle:[BBConfig libBundle]];
    currentSelectLibraryViewController.dismissAsSubview = false;
    [self presentViewController:currentSelectLibraryViewController animated:true completion:nil];
}

//- (IBAction)changeMapAction:(id)sender {
//    currentSelectLibraryViewController = nil;
//    currentSelectLibraryViewController = [[BBLibrarySelectViewController alloc] initWithNibName:@"BBLibrarySelectViewController" bundle:[BBConfig libBundle]];
//    currentSelectLibraryViewController.dismissAsSubview = false;
//    [self presentViewController:currentSelectLibraryViewController animated:true completion:nil];
//}

- (IBAction)popupViewButtonOKAction:(id)sender {
    [self hidePopupView];
}

- (IBAction)popupViewButtonOKDontShowAgainAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BB_POPUP_DONT_SHOW];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self hidePopupView];
}

- (void) hidePopupView {
    foundSubjectPopopViewDisplayed = YES;
    [popupView removeFromSuperview];
    popupView = nil;
}

- (IBAction)myPositionPopDownButtonAction:(id)sender {
    [self myLocationAction:nil];
}

- (IBAction)materialPopDownButtonAction:(id)sender {

    self.foundSubject = nil;
    self.wayfindingRequstObject = nil;
    shouldLayoutMap = true;
    [self mapLayoutNow];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)rangeBeacons inRegion:(CLBeaconRegion *)region {
    
    if (place == nil) {
        myCoordinate = CGPointZero;
        [self layoutMyLocationAnimated:false];
        return;
    }
    
    NSMutableArray *rangedFloors = [NSMutableArray new];
    for (CLBeacon *beacon in rangeBeacons) {
        if (beacon.accuracy == -1) {
            continue;
        }
        BBFloor *floor = [place matchingBBFloor:beacon];
        if (floor == nil) { continue; }
        
        [rangedFloors addObject:floor];
        if (rangedFloors.count == 3) {
            break;
        }
    }
    
    lastRangedBeaconsFloorRef = rangedBeaconsFloorRef;
    
    if (rangedFloors.count >= 3) {
        if (((BBFloor *)rangedFloors[0]).floor_id == ((BBFloor *)rangedFloors[1]).floor_id == ((BBFloor *)rangedFloors[2]).floor_id) {
            rangedBeaconsFloorRef = rangedFloors[0];
            
        } else if (((BBFloor *)rangedFloors[0]).floor_id == ((BBFloor *)rangedFloors[1]).floor_id || ((BBFloor *)rangedFloors[0]).floor_id == ((BBFloor *)rangedFloors[2]).floor_id) {
            rangedBeaconsFloorRef = rangedFloors[0];
            
        } else if (((BBFloor *)rangedFloors[1]).floor_id == ((BBFloor *)rangedFloors[0]).floor_id || ((BBFloor *)rangedFloors[1]).floor_id == ((BBFloor *)rangedFloors[2]).floor_id) {
            rangedBeaconsFloorRef = rangedFloors[1];
            
        } else if (((BBFloor *)rangedFloors[2]).floor_id == ((BBFloor *)rangedFloors[0]).floor_id || ((BBFloor *)rangedFloors[2]).floor_id == ((BBFloor *)rangedFloors[1]).floor_id) {
            rangedBeaconsFloorRef = rangedFloors[2];
            
        } else {
            rangedBeaconsFloorRef = nil;
        }
    } else if (rangedFloors.count == 2) {
        if (((BBFloor *)rangedFloors[0]).floor_id == ((BBFloor *)rangedFloors[1]).floor_id) {
            rangedBeaconsFloorRef = rangedFloors[0];
        } else {
            rangedBeaconsFloorRef = nil;
        }
        
    } else if (rangedFloors.count == 1) {
        rangedBeaconsFloorRef = rangedFloors[0];
        
    } else {
        rangedBeaconsFloorRef = nil;
    }
    
    NSMutableArray *rangedBBBeacons = [NSMutableArray new];
    for (CLBeacon *beacon in rangeBeacons) {
        BBBeaconLocation *beaconLocation = [currentDisplayFloorRef matchingBBBeacon:beacon];
        if (beaconLocation.beacon == nil) {
            continue;
        }
        
        if (beacon.accuracy > 0 && beacon.accuracy < 12) {
            beaconLocation.beacon.accuracy = beacon.accuracy;
            
            [rangedBBBeacons addObject:beaconLocation];
            if (rangedBBBeacons.count == 3) {
                break;
            }
        } else {
            beaconLocation.beacon.accuracy = -1;
        }
    }
    
    CGPoint rangedCoordinate;
    
    if (rangedBBBeacons.count >= 3) {
        BBBeaconLocation *beaconA = rangedBBBeacons[0];
        BBBeaconLocation *beaconB = rangedBBBeacons[1];
        BBBeaconLocation *beaconC = rangedBBBeacons[2];
        rangedCoordinate = [BBCoordinateHelper centerOf3Points:[beaconA coordinate] p2:[beaconB coordinate] p3:[beaconC coordinate]];
        
    } else if (rangedBBBeacons.count == 2) {
        BBBeaconLocation *beaconA = rangedBBBeacons[0];
        BBBeaconLocation *beaconB = rangedBBBeacons[1];
        rangedCoordinate = [BBCoordinateHelper centerOf2Points:[beaconA coordinate] p2:[beaconB coordinate]];
        
    } else if (rangedBBBeacons.count == 1) {
        BBBeaconLocation *beaconA = rangedBBBeacons[0];
        rangedCoordinate = [beaconA coordinate];
        
    } else {
        [self updateMyLocationButtonEnabled];
        return;
    }

    if (currentDisplayFloorRef.floor_id != rangedBeaconsFloorRef.floor_id) {
        if (lastRangedBeaconsFloorRef.floor_id == rangedBeaconsFloorRef.floor_id) {
            myCurrentLocationView.hidden = YES;

        }
        [self updateMyLocationButtonEnabled];
        return;
    } else {
        
        double distPixels = hypot((myCoordinate.x - rangedCoordinate.x), (myCoordinate.y - rangedCoordinate.y));
        double distCentimeters = distPixels * currentDisplayFloorRef.map_pixel_to_centimeter_ratio;
        
        if (distCentimeters > 500) {
            myCoordinate = rangedCoordinate;
            [self layoutMyLocationAnimated:true];
        }
    }

    [self updateMyLocationButtonEnabled];
}


- (BOOL) userPositioningAvailable {
    return _bluetoothManager.state == CBManagerStatePoweredOn && [CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
    
}

#pragma mark - Key Value Observers

- (void) mapNeedsLayout {
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F1F1F1"];
    shouldLayoutMap = true;
}

@end
