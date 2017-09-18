//
// BBLibrarySelectViewController.m
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

#import "BBLibrarySelectViewController.h"

@implementation BBLibrarySelectViewController {

    BBLibrarySelectDatasourceDelegate *datasourceDelegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.navBarTitleLabel.font = [[BBConfig sharedConfig] lightFontWithSize:18];
    self.navBarTitleLabel.text = @"Skift bibliotek";
    self.navBarTitleLabel.textColor = [UIColor colorWithRed:97.0f/255.0f green:97.0f/255.0f blue:97.0f/255.0f alpha:1.0];
    
    datasourceDelegate = [BBLibrarySelectDatasourceDelegate new];
    datasourceDelegate.selectDelegate = self;
    
    self.tableView.dataSource = datasourceDelegate;
    self.tableView.delegate = datasourceDelegate;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BBLoadingIndicatorCell" bundle:[BBConfig libBundle]] forCellReuseIdentifier:@"BBLoadingIndicatorCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BBEmptyTableViewCell" bundle:[BBConfig libBundle]] forCellReuseIdentifier:@"BBEmptyTableViewCell"];
    
    [self.tableView reloadData];
    
    [self loadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark - Load Data

- (void) loadData {
    
    [[BBDataManager sharedInstance] fetchAllPlacesWithCompletion:^(NSArray *places, NSError *error) {
        if (error == nil) {
            datasourceDelegate.data = places;
            
            [self.tableView reloadData];
        } else {
            
            datasourceDelegate.data = [NSMutableArray new];
            [self.tableView reloadData];
            NSLog(@"An Error Occured: %@", error.localizedDescription);
        }
        
    }];
}

#pragma mark - Actions

- (IBAction)closeButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BBLibrarySelectDelegate

- (void) didSelectPlace:(BBPlace *)place {
    
    [[BBConfig sharedConfig] setupWithPlaceIdentifier:place.identifier1 withCompletion:^(NSString *placeIdentifier, NSError *error) {
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:BB_NOTIFICATION_MAP_NEEDS_LAYOUT object:nil];
        
        if (self.dismissAsSubview) {
            [UIView animateWithDuration:0.35 animations:^{
                [self.view setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width, self.view.frame.size.height)];
                
            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:BB_NOTIFICATION_MAP_LAYOUT_NOW object:nil];
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                
            }];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];

    
}

@end
