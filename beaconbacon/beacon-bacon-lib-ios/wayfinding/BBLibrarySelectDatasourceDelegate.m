//
// .m
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

#import "BBLibrarySelectDatasourceDelegate.h"

@implementation BBLibrarySelectDatasourceDelegate

- (BOOL) isEmpty {
    return ![self isLoading] && self.data.count == 0;
}

- (BOOL) isLoading {
    return self.data == nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isLoading]) {
        return 1;
    } else if ([self isEmpty]) {
        return 1;
    } else {
        return self.data.count;
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
        
        cell.emptyImageView.image = [UIImage imageNamed:@"empty-icon-poi" inBundle:[BBConfig libBundle] compatibleWithTraitCollection:nil];
        [cell setTitle:@"Ingen interessepunkter" description:@"Kom tilbage senere og se om vi har tilføjet nogle interessepunkter"];
        
        return cell;

    } else {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row % 2 == 0) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.00];
        } else {
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
        }
        
        BBPlace *place = self.data[indexPath.row];
        cell.textLabel.text = place.name;
        cell.textLabel.font = [[BBConfig sharedConfig] lightFontWithSize:16];
        
        if ([[NSString stringWithFormat:@"%ld", (long)place.place_id] isEqualToString:[BBConfig sharedConfig].currentPlaceId]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        cell.backgroundColor = cell.contentView.backgroundColor;
        cell.accessoryView.backgroundColor = [UIColor clearColor];
        cell.tintColor = [[BBConfig sharedConfig] customColor];
        
        return cell;

    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
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
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isLoading]) {

    } else if ([self isEmpty]) {

    } else {
        BBPlace *place = self.data[indexPath.row];
        if ([self.selectDelegate respondsToSelector:@selector(didSelectPlace:)]){
            [self.selectDelegate didSelectPlace:place];
        }
    }
}

@end
