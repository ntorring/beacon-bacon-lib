//
// BBPOITableViewCell.m
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

#import "BBPOITableViewCell.h"

@implementation BBPOITableViewCell

-(void)awakeFromNib {
    
    [super awakeFromNib];

    self.selectedImageView.backgroundColor = [UIColor whiteColor];
    self.selectedImageView.layer.borderColor = [[UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.00] CGColor];
    self.selectedImageView.layer.borderWidth = 1.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.nameLabel.font = [[BBConfig sharedConfig] lightFontWithSize:14];

}

-(void) applyPointOfInterst:(BBPOI *)poi atIndex:(NSIndexPath *)indexPath {
    
    if (indexPath.row % 2 == 0) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.00];
    } else {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
    }
    
    [self setCheckmarkSelected:poi.selected animated:NO];
    
    self.nameLabel.text = poi.name;
    self.iconImageView.image = nil;
    self.iconImageView.contentMode = UIViewContentModeScaleToFill;
    self.iconImageView.layer.sublayers = nil;

    if ([poi.type isEqualToString:BB_POI_TYPE_ICON]) {
        [self.iconImageView loadImageFromURL:[NSURL URLWithString:poi.icon_url] completionBlock:nil];
        
    } else if ([poi.type isEqualToString:BB_POI_TYPE_AREA]) {
        
        [self layoutIfNeeded];
        [self.iconImageView setImage:[UIImage imageNamed:@"icon-area" inBundle:[BBConfig libBundle] compatibleWithTraitCollection:nil]];
        CAShapeLayer *dotLayer = [CAShapeLayer layer];
        dotLayer.fillColor = [[UIColor colorFromHexString:poi.hex_color] colorWithAlphaComponent:0.4].CGColor;
        dotLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.iconImageView.bounds.size.width/2 - 3, self.iconImageView.bounds.size.height/2 - 3, 6, 6)].CGPath;
        [self.iconImageView.layer addSublayer:dotLayer];
    }
}

- (void) setCheckmarkSelected:(BOOL)selected animated:(BOOL)animated {
    
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
        self.selectedImageView.image = selected ? [[UIImage imageNamed:@"checkmark-icon" inBundle:[BBConfig libBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : nil;
        self.selectedImageView.tintColor = [[BBConfig sharedConfig] customColor];
    }];

}





@end
