//
// BBLibraryMapPOIViewController.h
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
#import "BBLibraryMapPOIDatasourceDelegate.h"
#import "BBPOISection.h"
#import "BBDataManager.h"
#import "BBConfig.h"

@interface BBLibraryMapPOIViewController: UIViewController

// Custom Navigation/Top Bar
@property (weak, nonatomic) IBOutlet UIView *fakeNavigationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fakeNavigationBarHeight;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;

// Other Views
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (instancetype)init;

@end
