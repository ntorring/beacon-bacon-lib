//
// BBLibraryMapPOIDatasourceDelegate.m
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

#import "BBLibraryMapPOIDatasourceDelegate.h"

@implementation BBLibraryMapPOIDatasourceDelegate

- (BOOL) isEmpty {
    return ![self isLoading] && self.datasource.count == 0;
}

- (BOOL) isLoading {
    return self.datasource == nil;
}

- (BBPOISection *) sectionForIndex:(NSInteger)section {
    return self.datasource[section];
}

- (BBPOIMenuItem *) menuItemsForIndexPath:(NSIndexPath *)indexPath {
    return ((BBPOISection *)self.datasource[indexPath.section]).menuItems[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isLoading]) {
        return 1;
    } else if ([self isEmpty]) {
        return 1;
    } else {
        return self.datasource.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isLoading]) {
        return 1;
    } else if ([self isEmpty]) {
        return 1;
    } else {
        return ((BBPOISection *)self.datasource[section]).menuItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLoading]) {
        BBLoadingIndicatorCell* cell = [tableView dequeueReusableCellWithIdentifier:@"BBLoadingIndicatorCell"];
        if(cell == nil){
            cell = [[[BBConfig libBundle] loadNibNamed:@"BBLoadingIndicatorCell" owner:self options:nil] firstObject];
        }
        
        [cell.loadingIndicator startAnimating];
        return cell;

    } else if ([self isEmpty]) {
        BBEmptyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BBEmptyTableViewCell" forIndexPath:indexPath];
        if (cell == nil){
            cell = [[[BBConfig libBundle] loadNibNamed:@"BBEmptyTableViewCell" owner:self options:nil] firstObject];
        }
    
        [cell setTitle:@"Interessepunkter" description:@"Kom tilbage senere og se om vi har tilføjet nogle interessepunkter"];
        
        return cell;

    } else {
        BBPOITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BBPOITableViewCell" forIndexPath:indexPath];
        if (cell == nil){
            cell = [[[BBConfig libBundle] loadNibNamed:@"BBPOITableViewCell" owner:self options:nil] firstObject];
        }
        [cell applyPointOfInterst:[self menuItemsForIndexPath:indexPath].poi atIndex:indexPath];
        return cell;

    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self isLoading]) {
        return nil;
    } else if ([self isEmpty]) {
        return nil;
    } else {
        BBPOISectionHeaderView *headerView = [[[BBConfig libBundle] loadNibNamed:@"BBPOISectionHeaderView" owner:self options:nil] firstObject];
        headerView.headerTitleLabel.text = [self sectionForIndex:section].sectionTitle;
        
        headerView.headerButton.hidden = section != 0; // Hide when not section 0
        [headerView.headerButton setTitle:@"Fravælg alle" forState:UIControlStateNormal];
        [headerView.headerButton addTarget:self action:@selector(headerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLoading]) {
        return [UIScreen mainScreen].bounds.size.height - 84;
    } else if ([self isEmpty]) {
        return [UIScreen mainScreen].bounds.size.height - 84;
    } else {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self isLoading]) {
        return 0;
    } else if ([self isEmpty]) {
        return 0;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isLoading]) {

    } else if ([self isEmpty]) {

    } else {
        [self menuItemsForIndexPath:indexPath].poi.selected = ![self menuItemsForIndexPath:indexPath].poi.selected;
        [((BBPOITableViewCell *)[tableView cellForRowAtIndexPath:indexPath]) setCheckmarkSelected:[self menuItemsForIndexPath:indexPath].poi.selected  animated:YES];
    }
}

- (IBAction)headerButtonAction:(id)sender {
    for (BBPOISection *section in self.datasource) {
        for (BBPOIMenuItem *menuItem in section.menuItems) {
            menuItem.poi.selected = NO;
        }
    }
    
    [self.tableViewRef reloadData];
}


@end
