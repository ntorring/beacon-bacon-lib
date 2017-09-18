//
// BBLibraryMapViewController.h
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#import "UIColor+Hex.h"
#import "UIImage+Resize.h"

#import "BBTrilateration.h"
#import "BBBeacon.h"
#import "BBLibraryMapPOIViewController.h"
#import "BBLibrarySelectViewController.h"
#import "BBDataManager.h"
#import "BBFloor.h"
#import "BBMyPositionView.h"
#import "BBPOIMapView.h"
#import "BBPopupView.h"
#import "BBPOIAreaMapView.h"

#import "UIImageView+BeaconBacon.h"
#import "CBCentralManager+BeaconBacon.h"

#import "BBCoordinateHelper.h"

@interface BBLibraryMapViewController : UIViewController <CLLocationManagerDelegate>

#define BB_MAP_TAG_FLOORPLAN   999
#define BB_MAP_TAG_MY_POSITION 666

#define BB_POPUP_HEIGHT_NORMAL 220
#define BB_POPUP_HEIGHT_LARGE 250
#define BB_POPUP_WIDTH 280

#define BB_NOTIFICATION_MAP_NEEDS_LAYOUT    @"BB_NOTIFICATION_MAP_NEEDS_LAYOUT"
#define BB_NOTIFICATION_MAP_LAYOUT_NOW      @"BB_NOTIFICATION_MAP_LAYOUT_NOW"

#define BB_FADE_DURATION 0.3

// Wayfinding Item
@property (nonatomic, strong) BBIMSRequstObject *wayfindingRequstObject;
@property (nonatomic, strong) BBFoundSubject *foundSubject;

// Custom Navigation/Top Bar
@property (weak, nonatomic) IBOutlet UIView *fakeNavigationBar;

@property (weak, nonatomic) IBOutlet UIButton *navBarNextButton;
@property (weak, nonatomic) IBOutlet UIButton *navBarPreviousButton;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeButtonAction:(id)sender;


// Default Top Bar
@property (weak, nonatomic) IBOutlet UIView *defaultTopBar;
@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *navBarSubtitleLabel;

//@property (weak, nonatomic) IBOutlet UILabel *navBarSubtitleLabel;


// Navigate To Material Top Bar
@property (weak, nonatomic) IBOutlet UIView *materialTopBar;
@property (weak, nonatomic) IBOutlet UIImageView *materialTopImageView;
@property (weak, nonatomic) IBOutlet UILabel *materialTopTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *materialTopSubtitleLabel;


// Bottom Right Cornor Views
@property (weak, nonatomic) IBOutlet UIButton *myFoundMaterialButton;
@property (weak, nonatomic) IBOutlet UIButton *myLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *pointsOfInterestButton;

// Other Views
@property (weak, nonatomic) IBOutlet UIScrollView *mapScrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) CLLocationManager *locationManager;


//// My Position Pop Down
//@property (weak, nonatomic) IBOutlet UIView *myPositionPopDownView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myPositionPopDownTopConstraint;
//@property (weak, nonatomic) IBOutlet UILabel *myPositionPopDownLabel;
//@property (weak, nonatomic) IBOutlet UIButton *myPositionPopDownButton;

// Material Position Pop Down
@property (weak, nonatomic) IBOutlet UIView *materialPopDownView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *materialPopDownTopConstraint;
//@property (weak, nonatomic) IBOutlet UILabel *materialPopDownLabel;
//@property (weak, nonatomic) IBOutlet UILabel *materialPopDownText;
@property (weak, nonatomic) IBOutlet UIButton *materialPopDownButton;

+ (BBLibraryMapViewController *) mapViewController;

- (IBAction)navBarNextAction:(id)sender;
- (IBAction)navBarPreviousAction:(id)sender;

- (IBAction)pointsOfInterestAction:(id)sender;
- (IBAction)myLocationAction:(id)sender;
- (IBAction)myFoundMaterialButtonAction:(id)sender;

//- (IBAction)myPositionPopDownButtonAction:(id)sender;
- (IBAction)materialPopDownButtonAction:(id)sender;

@end
