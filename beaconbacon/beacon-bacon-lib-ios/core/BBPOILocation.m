//
// BBPOILocation.m
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

#import "BBPOILocation.h"

@implementation BBPOILocation

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    if ([attributes isEqual:[NSNull null]] || ![attributes isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self.poi = [[BBPOI alloc] initWithAttributes:attributes[@"poi"]];
    
    if ([attributes valueForKeyPath:@"area"]) {
        NSString *areaStr = [attributes valueForKeyPath:@"area"];
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
    
    return self;
}

@end
