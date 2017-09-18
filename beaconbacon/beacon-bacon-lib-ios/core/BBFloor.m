//
// BBPOIFloor.m
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

#import "BBFloor.h"
#import "BBConfig.h"

@implementation BBFloor

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([attributes isEqual:[NSNull null]] || ![attributes isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    if ([attributes valueForKeyPath:@"id"]) {
        self.floor_id = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"team_id"]) {
        self.team_id = (NSUInteger)[[attributes valueForKeyPath:@"team_id"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"name"]) {
        self.name = [attributes valueForKeyPath:@"name"];
    }
    
    if ([attributes valueForKeyPath:@"order"]) {
        self.order = (NSUInteger)[[attributes valueForKeyPath:@"order"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"image"]) {
        self.image_url = [attributes valueForKeyPath:@"image"];
    }
    
    if ([attributes valueForKeyPath:@"locations"]) {
        NSMutableArray *tmpPOILocations = [NSMutableArray new];
        NSMutableArray *tmpBeaconLocations = [NSMutableArray new];
        for (NSDictionary *locationDict in [attributes valueForKeyPath:@"locations"]) {
            if ([locationDict valueForKeyPath:@"type"]) {
                if ([locationDict[@"type"] isEqualToString:@"poi"]) {
                    BBPOILocation *location = [[BBPOILocation alloc] initWithAttributes:locationDict];
                    [tmpPOILocations addObject:location];
                } else if ([locationDict[@"type"] isEqualToString:@"beacon"]) {
                    BBBeaconLocation *location = [[BBBeaconLocation alloc] initWithAttributes:locationDict];
                    [tmpBeaconLocations addObject:location];
                } else if ([locationDict[@"type"] isEqualToString:@"ims"]) {
                    // Ignore all IMS
                } else {
                    // Unknown Type - ingnore at this point (until supported)
                }
            }
        }
        self.poiLocations = tmpPOILocations;
        self.beaconLocations = tmpBeaconLocations;
    }
    
    if ([attributes valueForKeyPath:@"map_width_in_centimeters"]) {
        self.map_width_in_centimeters = (NSUInteger)[[attributes valueForKeyPath:@"map_width_in_centimeters"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"map_height_in_centimeters"]) {
        self.map_height_in_centimeters = (NSUInteger)[[attributes valueForKeyPath:@"map_height_in_centimeters"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"map_width_in_pixels"]) {
        self.map_width_in_pixels = (NSUInteger)[[attributes valueForKeyPath:@"map_width_in_pixels"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"map_height_in_pixels"]) {
        self.map_height_in_pixels = (NSUInteger)[[attributes valueForKeyPath:@"map_height_in_pixels"] integerValue];
    }
    
//    if ([attributes valueForKeyPath:@"map_pixel_to_centimeter_ratio"]) {
//        self.map_pixel_to_centimeter_ratio = (NSUInteger)[[attributes valueForKeyPath:@"map_pixel_to_centimeter_ratio"] integerValue];
//    }
    
    // Make the calculation ourselves instead.
    double wp = self.map_width_in_pixels;
    double wc = self.map_width_in_centimeters;
    self.map_pixel_to_centimeter_ratio = wp / wc;
    
    if ([attributes valueForKeyPath:@"map_walkable_color"]) {
        NSString *map_walkable_color = [attributes valueForKeyPath:@"map_walkable_color"];
        if (map_walkable_color != nil && ![map_walkable_color isEqualToString:@""] ) {
            self.map_walkable_color = [UIColor colorFromHexString:map_walkable_color];
        }
    }
    
    if ([attributes valueForKeyPath:@"map_background_color"]) {
        NSString *map_background_color = [attributes valueForKeyPath:@"map_background_color"];
        if (map_background_color != nil && ![map_background_color isEqualToString:@""] ) {
            self.map_background_color = [UIColor colorFromHexString:map_background_color];
        }
    }
    return self;
}

- (BBBeaconLocation *) matchingBBBeacon:(CLBeacon *)clbeacon {
    for (BBBeaconLocation *beaconLocation in self.beaconLocations) {
        if ([beaconLocation.beacon majorMinorMacthing:clbeacon]) {
            return beaconLocation;
        }
    }
    return nil;
}

- (void) clearAllAccuracyDataPoints {
    for (BBBeaconLocation *beaconLocation in self.beaconLocations) {
        beaconLocation.beacon.accuracyDataPoints = [NSMutableArray new];
    }
}

@end
