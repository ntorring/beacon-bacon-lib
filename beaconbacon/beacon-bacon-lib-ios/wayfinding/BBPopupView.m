//
// BBPopupView.m
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
///

#import "BBPopupView.h"

#define HEIGHTOFPOPUPTRIANGLE 20
#define WIDTHOFPOPUPTRIANGLE 40

@implementation BBPopupView

-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self layoutIfNeeded];
    
    self.labelTitle.font = [[BBConfig sharedConfig] lightFontWithSize:14];
    self.labelText.font = [[BBConfig sharedConfig] lightFontWithSize:12];
    self.labelText.numberOfLines = 0;
    
    self.buttonOK.titleLabel.font = [[BBConfig sharedConfig] regularFontWithSize:12];
    self.buttonOKDontShowAgain.titleLabel.font = [[BBConfig sharedConfig] regularFontWithSize:12];
    
    [self.opacityViewWithShadow.layer setShadowOffset:CGSizeMake(0, 5)];
    [self.opacityViewWithShadow.layer setShadowOpacity:0.1f];
    [self.opacityViewWithShadow.layer setShadowRadius:2.5f];
    [self.opacityViewWithShadow.layer setShouldRasterize:NO];
    [self.opacityViewWithShadow.layer setShadowColor:[[UIColor blackColor] CGColor]];
}


@end
