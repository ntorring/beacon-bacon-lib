//
// BBPlace.h
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
#import "BBFloor.h"

@interface BBPlace : NSObject

@property (nonatomic, strong) NSString *identifier1; // Used by BeaconBacon
@property (nonatomic, strong) NSString *identifier2;
@property (nonatomic, strong) NSString *identifier3;
@property (nonatomic, strong) NSString *identifier4;
@property (nonatomic, strong) NSString *identifier5;

@property (nonatomic, assign) NSInteger place_id;
@property (nonatomic, assign) NSInteger team_id;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *city;

@property (nonatomic, assign) NSInteger order;

@property (nonatomic, strong) NSArray *floors; // <BBPOIFloor>

@property (nonatomic) BOOL beacon_positioning_enabled;
@property (nonatomic) BOOL beacon_proximity_enabled;


- (instancetype)initWithAttributes:(NSDictionary *)attributes;

- (BBFloor *) matchingBBFloor:(CLBeacon *)clbeacon;

@end
