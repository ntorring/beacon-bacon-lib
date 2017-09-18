//
// BBPlace.m
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

#import "BBPlace.h"

@implementation BBPlace

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([attributes isEqual:[NSNull null]] || ![attributes isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if ([attributes valueForKeyPath:@"identifier_one"]) {
        self.identifier1 = [attributes valueForKeyPath:@"identifier_one"];
    }

    if ([attributes valueForKeyPath:@"identifier_two"]) {
        self.identifier2 = [attributes valueForKeyPath:@"identifier_two"];
    }

    if ([attributes valueForKeyPath:@"identifier_three"]) {
        self.identifier3 = [attributes valueForKeyPath:@"identifier_three"];
    }

    if ([attributes valueForKeyPath:@"identifier_four"]) {
        self.identifier4 = [attributes valueForKeyPath:@"identifier_four"];
    }

    if ([attributes valueForKeyPath:@"identifier_five"]) {
        self.identifier5 = [attributes valueForKeyPath:@"identifier_five"];
    }

    if ([attributes valueForKeyPath:@"id"]) {
        self.place_id = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"team_id"]) {
        self.team_id = (NSUInteger)[[attributes valueForKeyPath:@"team_id"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"name"]) {
        self.name = [attributes valueForKeyPath:@"name"];
    }
    
    if ([attributes valueForKeyPath:@"address"]) {
        self.address = [attributes valueForKeyPath:@"address"];
    }
    
    if ([attributes valueForKeyPath:@"zipcode"]) {
        self.zipcode = [attributes valueForKeyPath:@"zipcode"];
    }
    
    if ([attributes valueForKeyPath:@"city"]) {
        self.city = [attributes valueForKeyPath:@"city"];
    }

    if ([attributes valueForKeyPath:@"order"]) {
        self.order = (NSUInteger)[[attributes valueForKeyPath:@"order"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"floors"]) {
        NSMutableArray *tmpFloors = [NSMutableArray new];
        for (NSDictionary *floorDict in [attributes valueForKeyPath:@"floors"]) {
            BBFloor *floor = [[BBFloor alloc] initWithAttributes:floorDict];
            [tmpFloors addObject:floor];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        self.floors = [tmpFloors sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    if ([attributes valueForKeyPath:@"beacon_positioning_enabled"]) {
        self.beacon_positioning_enabled = (NSUInteger)[[attributes valueForKeyPath:@"beacon_positioning_enabled"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"beacon_proximity_enabled"]) {
        self.beacon_proximity_enabled = (NSUInteger)[[attributes valueForKeyPath:@"beacon_proximity_enabled"] integerValue];
    }
    
    return self;
}

- (BBFloor *) matchingBBFloor:(CLBeacon *)clbeacon {
    for (BBFloor *floor in self.floors) {
        for (BBBeaconLocation *beaconLocation in floor.beaconLocations) {
            if ([beaconLocation.beacon majorMinorMacthing:clbeacon]) {
                return floor;
            }
        }
    }
    return nil;
}

@end
