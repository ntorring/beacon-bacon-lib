//
// BBBeacon.m
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BBBeacon : NSObject

@property (nonatomic, assign) NSInteger beacon_id;
@property (nonatomic, assign) NSInteger team_id;
@property (nonatomic, assign) NSInteger place_id;
@property (nonatomic, assign) NSInteger map_id;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *beacon_description;

@property (nonatomic, strong) NSString *beacon_uid;
@property (nonatomic, strong) NSString *proximity_uuid;

@property (nonatomic, assign) NSInteger major;
@property (nonatomic, assign) NSInteger minor;

@property (nonatomic, strong) NSMutableArray *accuracyDataPoints;
@property (nonatomic, assign) NSInteger accuracy;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

- (BOOL) majorMinorMacthing:(CLBeacon *)clbeacon;

@end
