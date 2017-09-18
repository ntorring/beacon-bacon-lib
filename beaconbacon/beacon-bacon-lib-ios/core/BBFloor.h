//
// BBPOIFloor.h
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

#import <Foundation/Foundation.h>
#import "BBPOILocation.h"
#import "BBBeaconLocation.h"
#import "UIColor+Hex.h"

@interface BBFloor : NSObject

@property (nonatomic, assign) NSInteger floor_id;
@property (nonatomic, assign) NSInteger team_id;
@property (nonatomic, strong) NSString  *name;

@property (nonatomic, assign) NSInteger order;

@property (nonatomic, strong) NSString  *image_url;

@property (nonatomic, strong) NSArray   *poiLocations;      // <BBPOILocation>
@property (nonatomic, strong) NSArray   *beaconLocations;   // <BBBeaconLocation>

@property (nonatomic, assign) NSInteger map_width_in_centimeters;
@property (nonatomic, assign) NSInteger map_height_in_centimeters;

@property (nonatomic, assign) NSInteger map_width_in_pixels;
@property (nonatomic, assign) NSInteger map_height_in_pixels;

@property (nonatomic, assign) double map_pixel_to_centimeter_ratio;

@property (nonatomic, strong) UIColor  *map_walkable_color;
@property (nonatomic, strong) UIColor  *map_background_color;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

- (BBBeaconLocation *) matchingBBBeacon:(CLBeacon *)clbeacon;

- (void) clearAllAccuracyDataPoints;

@end
