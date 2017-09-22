//
// ViewController.m
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

#import "ViewController.h"
#import "BBConfig.h"
#import "BBLibraryMapViewController.h"

@implementation ViewController {
    BBLibraryMapViewController *mapViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [BBConfig sharedConfig].apiBaseURL      = @"https://app.beaconbacon.io/api";
    [BBConfig sharedConfig].apiKey          = @"$2y$10$xNbv82pkfvDT7t4I2cwkLu4csCtd75PIZ/G06LylcMnjwdj/vmJtm";
    [BBConfig sharedConfig].SSLPinningMode  = BBSSLPinningModeNone;
}

- (void) setSpinner {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    spinner.color = self.style1Button.tintColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void) removeSpinner {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)noStyleAction:(id)sender {
    [BBConfig sharedConfig].customColor = nil;
    [BBConfig sharedConfig].regularFont = nil;
    [BBConfig sharedConfig].lightFont   = nil;
    [self.style1Button setSelected:YES];
    [self.style2Button setSelected:NO];
    [self.style3Button setSelected:NO];
}

- (IBAction)style1Action:(id)sender {
    [BBConfig sharedConfig].customColor = [UIColor magentaColor];
    [BBConfig sharedConfig].regularFont = [UIFont fontWithName:@"Menlo-Bold" size:16];
    [BBConfig sharedConfig].lightFont   = [UIFont fontWithName:@"Menlo-Regular" size:16];
    [self.style1Button setSelected:NO];
    [self.style2Button setSelected:YES];
    [self.style3Button setSelected:NO];
}

- (IBAction)style2Action:(id)sender {
    [BBConfig sharedConfig].customColor = [UIColor orangeColor];
    [BBConfig sharedConfig].regularFont = [UIFont fontWithName:@"Avenir-Regular" size:16];
    [BBConfig sharedConfig].lightFont   = [UIFont fontWithName:@"Avenir-Light" size:16];
    [self.style1Button setSelected:NO];
    [self.style2Button setSelected:NO];
    [self.style3Button setSelected:YES];
}

- (IBAction)placeKBHaction:(id)sender {
    [self setSpinner];
    [[BBConfig sharedConfig] setupWithPlaceIdentifier:@"koebenhavnsbib" withCompletion:^(NSString *placeIdentifier, NSError *error) {
        [self removeSpinner];
        [self.place1Button setSelected:YES];
        [self.place2Button setSelected:NO];
        [self.place3Button setSelected:NO];
    }];
}

- (IBAction)placeMustacheAction:(id)sender {
    [self setSpinner];
    [[BBConfig sharedConfig] setupWithPlaceIdentifier:@"koldingbib" withCompletion:^(NSString *placeIdentifier, NSError *error) {
        [self removeSpinner];
        [self.place1Button setSelected:NO];
        [self.place2Button setSelected:YES];
        [self.place3Button setSelected:NO];
    }];
}

- (IBAction)placeUnsupportedAction:(id)sender {
    [self setSpinner];
    [[BBConfig sharedConfig] setupWithPlaceIdentifier:@"apple-campus-2" withCompletion:^(NSString *placeIdentifier, NSError *error) {
        [self removeSpinner];
        [self.place1Button setSelected:NO];
        [self.place2Button setSelected:NO];
        [self.place3Button setSelected:YES];
    }];
}

- (IBAction)mapAction:(id)sender {
    
    // Returns a list of available places of the BBPlace class
    [[BBDataManager sharedInstance] fetchAllPlacesWithCompletion:^(NSArray *places, NSError *error) {
        if (error == nil) {
            
            // Use the custom identifiers keys to identify your place (library) - this example uses 'identifier1'
            BBPlace *thePlaceWeAreLookingFor;
            for (BBPlace *place in places) {
                if ([place.identifier1 isEqualToString:@"museu22m1"]) {
                    thePlaceWeAreLookingFor = place;
                    break;
                }
            }
            
            // Setup with identifier1 (we use BBConfig because we'll remember the identifier for future usage)
            [[BBConfig sharedConfig] setupWithPlaceIdentifier:thePlaceWeAreLookingFor.identifier1 withCompletion:^(NSString *placeIdentifier, NSError *error) {
                if (error == nil) {
                    // Beacon Bacon has been setup and configuerd to run on this Place (Library)
                    // Now we're ready to initialise the UI.
                    mapViewController = [BBLibraryMapViewController new];
                     
                    // If you want to add a wayfinding Object. Please use this part.
//                    BBIMSRequstObject *requstObject = [[BBIMSRequstObject alloc] initWithFaustId:@"29715394"];
//                    requstObject.subject_name     = @"En mand der hedder Ove";
//                    requstObject.subject_subtitle = @"SK";
//                    requstObject.subject_image    = [UIImage imageNamed:@"menu-library-map-icon"];
//                    mapViewController.wayfindingRequstObject = requstObject;
                    
                    [self presentViewController:mapViewController animated:true completion:nil];
                    
                    
                } else {
                    NSLog(@"Gracefully handle error: %@", error.localizedDescription);
                }
            }];
            
            
        } else {
            NSLog(@"Gracefully handle error: %@", error.localizedDescription);
        }
        
    }];
    
}

- (IBAction)mapWayfindingAction:(id)sender {
    
    BBIMSRequstObject *requstObject = [[BBIMSRequstObject alloc] initWithFaustId:@"29715394"];
    requstObject.subject_name     = @"En mand der hedder Ove";
    requstObject.subject_subtitle = @"SK";
    requstObject.subject_image    = [UIImage imageNamed:@"96-book"];
    
    mapViewController = [BBLibraryMapViewController new];
    mapViewController.wayfindingRequstObject = requstObject;
    [self presentViewController:mapViewController animated:true completion:nil];
}

@end
