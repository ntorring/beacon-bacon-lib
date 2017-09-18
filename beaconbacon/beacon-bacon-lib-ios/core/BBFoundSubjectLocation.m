//
// BBFoundSubjectLocation.m
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

#import "BBFoundSubjectLocation.h"

@implementation BBFoundSubjectLocation

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([attributes isEqual:[NSNull null]] || ![attributes isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if ([attributes objectForKey:@"floor"]) {
        NSDictionary *floorDict = [attributes objectForKey:@"floor"];
        
        if ([floorDict objectForKey:@"id"]) {
            self.floor_id = (NSUInteger)[[floorDict objectForKey:@"id"] integerValue];
        }
        
        if ([floorDict valueForKeyPath:@"map_pixel_to_centimeter_ratio"]) {
            self.map_pixel_to_centimeter_ratio = [[floorDict valueForKeyPath:@"map_pixel_to_centimeter_ratio"] doubleValue];
        }

    }
    
    if ([attributes objectForKey:@"location"]) {
        NSDictionary *locationDict = [attributes objectForKey:@"location"];
        
        if ([locationDict valueForKeyPath:@"id"]) {
            self.location_id = (NSUInteger)[[locationDict objectForKey:@"id"] integerValue];
        }
        if ([locationDict valueForKeyPath:@"posX"]) {
            self.location_posX = (NSUInteger)[[locationDict objectForKey:@"posX"] integerValue];
        } else {
            self.location_posX = -1;
        }
        
        if ([locationDict valueForKeyPath:@"posY"]) {
            self.location_posY = (NSUInteger)[[locationDict objectForKey:@"posY"] integerValue];
        } else {
            self.location_posY = -1;
        }
        
        if ([locationDict valueForKeyPath:@"type"]) {
            NSString *type = [locationDict valueForKeyPath:@"type"];
            
            if ([type isEqualToString:@"area"]) {
                self.type = BBLocationTypeArea;

            } else if ([type isEqualToString:@"point"]) {
                self.type = BBLocationTypePoint;
            }
        }
        
        if ([locationDict valueForKeyPath:@"area"]) {
            NSString *areaStr = [locationDict valueForKeyPath:@"area"];
            NSArray *areaValues = [areaStr componentsSeparatedByString:@","];
            
            NSMutableArray *areaResult = [NSMutableArray new];
            for (int i = 0; i < areaValues.count/2; i++) {
                int offset = i*2;
                CGFloat x = [areaValues[offset] floatValue];
                CGFloat y = [areaValues[offset+1] floatValue];
                [areaResult addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
            }
            self.area = [areaResult copy];
        }
    }
    
//// FIXME: DUMMY AREA DATA - START!!!
//    self.location_posX = 0;
//    self.location_posY = 0;
//
//    self.type = BBLocationTypeArea;
//    
//    NSString *areaStr = @"1032, 1158, 1432, 1158, 1432, 1758, 932, 1758, 1032, 1158";
//    NSArray *areaValues = [areaStr componentsSeparatedByString:@","];
//    
//    NSMutableArray *areaResult = [NSMutableArray new];
//    for (int i = 0; i < areaValues.count/2; i++) {
//        int offset = i*2;
//        CGFloat x = [areaValues[offset] floatValue];
//        CGFloat y = [areaValues[offset+1] floatValue];
//        [areaResult addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
//    }
//    self.area = [areaResult copy];
//// FIXME: DUMMY AREA DATA - END!!!
    
    return self;
}

- (CGPoint) coordinate {
    return CGPointMake(self.location_posX, self.location_posY);
}

@end
