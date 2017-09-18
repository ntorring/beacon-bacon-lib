//
// BBFoundSubject.m
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

#import "BBFoundSubject.h"

@implementation BBFoundSubject

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([attributes isEqual:[NSNull null]] || ![attributes isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
        
    self.displayType = None;
    
    if ([attributes objectForKey:@"status"]) {
        self.status = [attributes objectForKey:@"status"];
    }
    
    if ([attributes objectForKey:@"data"]) {
        
        if (![[attributes objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
            return nil;
        }
        
        NSArray *allData = [attributes objectForKey:@"data"];
        NSMutableArray *locationsArray = [NSMutableArray new];
        
//// FIXME: DUMMY DATA (MULTIPLE LOCATIONS) vvvvvvvvvvvvv
//        NSDictionary *loc1 = @{ @"floor" : @{
//                                        @"id" : @3,
//                                        @"map_pixel_to_centimeter_ratio" : @"1.0"
//                                        },
//                                @"location" : @{
//                                        @"id" : @1620,
//                                        @"area" : @"",
//                                        @"type" : @"point",
//                                        @"posX" : @1032,
//                                        @"posY" : @1158
//                                        }
//                                };
//        
//        NSDictionary *loc2 = @{ @"floor" : @{
//                                        @"id" : @3,
//                                        @"map_pixel_to_centimeter_ratio" : @"1.0"
//                                        },
//                                @"location" : @{
//                                        @"id" : @1619,
//                                        @"area" : @"",
//                                        @"type" : @"point",
//                                        @"posX" : @1032,
//                                        @"posY" : @1458
//                                        }
//                                };
//        
//        NSDictionary *loc3 = @{ @"floor" : @{
//                                        @"id" : @3,
//                                        @"map_pixel_to_centimeter_ratio" : @"1.0"
//                                        },
//                                @"location" : @{
//                                        @"id" : @1619,
//                                        @"area" : @"",
//                                        @"type" : @"point",
//                                        @"posX" : @1032,
//                                        @"posY" : @1258
//                                        }
//                                };
//        
//        allData = @[loc1, loc2, loc3];
//// FIXME: DUMMY DATA (MULTIPLE LOCATIONS) END ^^^^^^^^^^^

        
        for (NSDictionary *data in allData) {
            BBFoundSubjectLocation *location = [[BBFoundSubjectLocation alloc] initWithAttributes:data];
            if (location != nil) {
                [locationsArray addObject:location];
            }
        }
        
        self.locations = [locationsArray copy];
        [self calculateDisplayTypeForLocations];
        
    }
    
    return self;
}

- (BOOL)isSubjectFound {
    return [self.status isEqualToString:BBStatus_Found];
}

- (NSInteger) floor_id {
    if (self.displayType != None && self.locations.count > 0) {
        BBFoundSubjectLocation *location = self.locations[0];
        return location.floor_id;
    } else {
        return -1;
    }
}

- (CGPoint) center {
    
    if (self.locations.count >= 1) {
        BBFoundSubjectLocation *location = self.locations[0];
        
        if (location.type == BBLocationTypeArea) {
            return [self areaCenter];
            
        } else {
            
            if (self.displayType == Single) {
                return [location coordinate];
                
            } else {
                NSMutableArray *xValues = [NSMutableArray new];
                NSMutableArray *yValues = [NSMutableArray new];
                
                for (BBFoundSubjectLocation *location in self.locations) {
                    [xValues addObject:@(location.location_posX)];
                    [yValues addObject:@(location.location_posY)];
                    
                }
                NSNumber *minX = [xValues valueForKeyPath:@"@min.self"];
                NSNumber *maxX = [xValues valueForKeyPath:@"@max.self"];
                
                NSNumber *minY = [yValues valueForKeyPath:@"@min.self"];
                NSNumber *maxY = [yValues valueForKeyPath:@"@max.self"];
                
                
                NSInteger x = [minX integerValue] + ([maxX integerValue] - [minX integerValue])/2;
                NSInteger y = [minY integerValue] + ([maxY integerValue] - [minY integerValue])/2;
                return CGPointMake(x, y);

            }
        }
    }
    return CGPointZero;
}

- (CGPoint) areaCenter {
    
    BBFoundSubjectLocation *location = self.locations[0];

    NSMutableArray *xValues = [NSMutableArray new];
    NSMutableArray *yValues = [NSMutableArray new];
    
    for (NSValue *pointValue in location.area) {
        CGPoint point = [pointValue CGPointValue];
        [xValues addObject:@(point.x)];
        [yValues addObject:@(point.y)];
        
    }
    NSNumber *minX = [xValues valueForKeyPath:@"@min.self"];
    NSNumber *maxX = [xValues valueForKeyPath:@"@max.self"];
    
    NSNumber *minY = [yValues valueForKeyPath:@"@min.self"];
    NSNumber *maxY = [yValues valueForKeyPath:@"@max.self"];
    
    
    NSInteger x = [minX integerValue] + ([maxX integerValue] - [minX integerValue])/2;
    NSInteger y = [minY integerValue] + ([maxY integerValue] - [minY integerValue])/2;
    return CGPointMake(x, y);
    
}

- (float) dist:(CGPoint)p1 to:(CGPoint)p2 {
    return hypotf(p1.x - p2.x, p1.y - p2.y);
}

- (void) calculateDisplayTypeForLocations {

    // Minimum display 2cm area - max 400cm -> BB_MINIMUM_DISTANCE_MULTIPLE_LOCATIONS
    self.maxDistLocations = 200;
    
    if (self.locations == nil || self.locations.count == 0) {
        self.displayType = None;

    } else if (self.locations.count == 1) {
        self.displayType = Single;
        
    } else {
    
        NSInteger floor_id = -1;
        for (int i = 0; i < self.locations.count; i++) {
            BBFoundSubjectLocation *location = self.locations[i];
            if (floor_id == -1) {
                // First Floor
                floor_id = location.floor_id;
            }
            for (int ii = i+1; ii < self.locations.count; ii++) {
                if (floor_id != ((BBFoundSubjectLocation *) self.locations[ii]).floor_id) {
                    // Locations are on two seperate floors
                    self.displayType = Single;
                    return;
                }
                CGPoint p1 = ((BBFoundSubjectLocation *) self.locations[i]).coordinate;
                CGPoint p2 = ((BBFoundSubjectLocation *) self.locations[ii]).coordinate;
                
                BBFoundSubjectLocation *loc = self.locations[i];
                float dist = [self dist:p1 to:p2] * loc.map_pixel_to_centimeter_ratio;
                
                if (dist > BB_MINIMUM_DISTANCE_MULTIPLE_LOCATIONS) {
                    // We found two locations far apart
                    self.displayType = Single;
                    return;
                } else {
                    self.maxDistLocations = fmax(self.maxDistLocations, dist);
                }
            }
        }
        
        // Locations are clustered
        self.displayType = Cluster;
        return;
    }
}

@end




