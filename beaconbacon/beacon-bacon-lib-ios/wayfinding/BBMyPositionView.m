//
// BBMyPositionView.m
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

#import "BBMyPositionView.h"

@implementation BBMyPositionView {
   
    UIView *myPosistionView;
    
//    UIImageView *myPositionImageView;
    
    UIView *pulseView;
    
//    BBUserPrecision currentUsetPrecision;
    
    CGFloat pulsationScaleToValue;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, BB_MY_POSITION_WIDTH, BB_MY_POSITION_WIDTH)];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    UIColor *color = [[BBConfig sharedConfig] customColor];
    
    if (pulseView == nil) {
        pulseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BB_MY_POSITION_WIDTH, BB_MY_POSITION_WIDTH)];
        
        pulseView.backgroundColor = [color colorWithAlphaComponent:0.2];
        pulseView.layer.cornerRadius = BB_MY_POSITION_WIDTH/2;
        [self addSubview:pulseView];
    }
    
    if (myPosistionView == nil) {
        CGFloat insetXY = BB_MY_POSITION_WIDTH/2 - BB_MY_POSITION_INDICATOR_WIDTH/2;
        myPosistionView = [[UIView alloc] initWithFrame:CGRectMake(insetXY, insetXY, BB_MY_POSITION_INDICATOR_WIDTH, BB_MY_POSITION_INDICATOR_WIDTH)];
        myPosistionView.backgroundColor = UIColor.clearColor;
        myPosistionView.layer.cornerRadius = BB_MY_POSITION_INDICATOR_WIDTH/2;
        myPosistionView.layer.masksToBounds = YES;
//        myPosistionView.layer.borderColor = [[UIColor whiteColor] CGColor];
//        myPosistionView.layer.borderWidth = 2.f;
        [self addSubview:myPosistionView];
    }
    
//    if (myPositionImageView == nil) {
//        CGFloat insetXY = BB_MY_POSITION_INDICATOR_WIDTH/2 - BB_MY_POSITION_ICON_WIDTH/2;
//        myPositionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(insetXY, insetXY, BB_MY_POSITION_ICON_WIDTH, BB_MY_POSITION_ICON_WIDTH)];
//        myPositionImageView.contentMode = UIViewContentModeScaleAspectFit;
//        myPositionImageView.image = [[UIImage imageNamed:@"position-icon" inBundle:[BBConfig libBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        myPositionImageView.tintColor = [UIColor whiteColor];
//        [myPosistionView addSubview:myPositionImageView];
//    }

    
    return self;
}

- (void) setPulsatingAnimationWithMaxWidth:(CGFloat)toValue {
    
    pulsationScaleToValue = toValue / BB_MY_POSITION_WIDTH;
    if (pulsationScaleToValue < 1.2) {
        pulsationScaleToValue = 1.2;
    }
    if (pulseView.layer.animationKeys.count > 0) {
        return;
    }
    [self addPulsation];
}

- (void) addPulsation {
    
    CGFloat scale = pulsationScaleToValue;
    
    [UIView animateWithDuration:1.6 animations:^{
        pulseView.transform = CGAffineTransformMakeScale(scale, scale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.6 animations:^{
            pulseView.transform = CGAffineTransformMakeScale(scale * 0.8f, scale * 0.8f);
        } completion:^(BOOL finished) {
            [self addPulsation];
        }];
    }];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self addPulsation];
}

@end
