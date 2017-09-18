//
// BBLocation.m
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

#import "BBLocation.h"

@implementation BBLocation

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    if ([attributes isEqual:[NSNull null]] || ![attributes isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if ([attributes valueForKeyPath:@"id"]) {
        self.location_id = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"team_id"]) {
        self.team_id = (NSUInteger)[[attributes valueForKeyPath:@"team_id"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"place_id"]) {
        self.place_id = (NSUInteger)[[attributes valueForKeyPath:@"place_id"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"map_id"]) {
        self.map_id = (NSUInteger)[[attributes valueForKeyPath:@"map_id"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"poi_id"]) {
        self.poi_id = (NSUInteger)[[attributes valueForKeyPath:@"poi_id"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"name"]) {
        self.name = [attributes valueForKeyPath:@"name"];
    }
    
    if ([attributes valueForKeyPath:@"posX"]) {
        self.posX = (NSUInteger)[[attributes valueForKeyPath:@"posX"] integerValue];
    }
    
    if ([attributes valueForKeyPath:@"posY"]) {
        self.posY = (NSUInteger)[[attributes valueForKeyPath:@"posY"] integerValue];
    }
    return self;
}

- (CGPoint) coordinate {
    return CGPointMake(self.posX, self.posY);
}

@end
