//
// BBPOIMapView.m
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

#import "BBPOIMapView.h"

@interface BBPOIMapView() {
    UILabel *nameLabel;
}

@end

@implementation BBPOIMapView

- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.clipsToBounds = NO;
    
    [self layoutIfNeeded];

    if (self.poiIconView == nil) {
        self.poiIconView = [[UIImageView alloc] initWithFrame:(CGRectMake(frame.size.width/4, frame.size.width/4, frame.size.width/2, frame.size.width/2))];
        [self addSubview:self.poiIconView];
    }
    
    [self applyPOIStyle];
    
    return self;
}

- (void) applyPOIStyle {
    [self layoutIfNeeded];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.cornerRadius = 0;
    self.layer.borderColor = nil;
    self.layer.borderWidth = 0;
    
    if (self.poiIconView != nil) {
        self.poiIconView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        self.poiIconView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

- (void) applyFoundSubjcetStyle {
   
    [self layoutIfNeeded];

    self.backgroundColor = [[BBConfig sharedConfig] customColor];
    
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 2.f;
    
    if (self.poiIconView != nil) {
        self.poiIconView.frame = CGRectMake(self.frame.size.width/4, self.frame.size.width/4, self.frame.size.width/2, self.frame.size.width/2);
        self.poiIconView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

- (void) applyFoundClusterSubjcetStyle {
    
    [self layoutIfNeeded];
    
    self.backgroundColor =[[[BBConfig sharedConfig] customColor] colorWithAlphaComponent:0.4];
    
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.borderColor = nil;
    self.poiIconView = nil;
}


-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self layoutIfNeeded];

    if (nameLabel == nil && !self.titleVisible) {
        self.titleVisible = YES;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 16)];
        nameLabel.text = self.title;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        nameLabel.clipsToBounds = NO;
        nameLabel.font = [[BBConfig sharedConfig] lightFontWithSize:14];
        
        [nameLabel sizeToFit];
        nameLabel.frame = CGRectMake(0, 0, nameLabel.frame.size.width + 32, nameLabel.frame.size.height + 16);
        
        [nameLabel.layer setShadowOffset:CGSizeMake(0, 5)];
        [nameLabel.layer setShadowOpacity:0.1f];
        [nameLabel.layer setShadowRadius:2.5f];
        [nameLabel.layer setShouldRasterize:NO];
        [nameLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
        
        UIImageView *triangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowtriangle" inBundle:[BBConfig libBundle] compatibleWithTraitCollection:nil]];
        triangle.frame = CGRectMake(nameLabel.frame.size.width/2 - triangle.frame.size.width/2, nameLabel.frame.size.height, triangle.frame.size.width, triangle.frame.size.height);
        [nameLabel addSubview:triangle];
        
        nameLabel.frame = CGRectMake(self.frame.size.width/2 - nameLabel.frame.size.width/2, 0 - nameLabel.frame.size.height - triangle.frame.size.height + 8, nameLabel.frame.size.width, nameLabel.frame.size.height);
      
        nameLabel.alpha = 0;
        [self addSubview:nameLabel];
        [UIView animateWithDuration:0.3 animations:^{
            nameLabel.alpha = 1;
        }];
        
    } else {
        self.titleVisible = NO;
        if (nameLabel != nil) {
            [UIView animateWithDuration:0.3 animations:^{
                nameLabel.alpha = 0;
            } completion:^(BOOL finished) {
                [nameLabel removeFromSuperview];
                nameLabel = nil;
            }];
        }
    }
}



@end
