//
// BBTrilateration.m
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

#import "BBTrilateration.h"

@implementation BBTrilateration

- (CGPoint) getMyCoordinate {
    
    //P1,P2,P3 is the point and 2-dimension vector
    NSMutableArray *P1 = [[NSMutableArray alloc] initWithCapacity:0];
    [P1 addObject:[NSNumber numberWithDouble:self.beaconA.x]];
    [P1 addObject:[NSNumber numberWithDouble:self.beaconA.y]];
    
    NSMutableArray *P2 = [[NSMutableArray alloc] initWithCapacity:0];
    [P2 addObject:[NSNumber numberWithDouble:self.beaconB.x]];
    [P2 addObject:[NSNumber numberWithDouble:self.beaconB.y]];
    
    NSMutableArray *P3 = [[NSMutableArray alloc] initWithCapacity:0];
    [P3 addObject:[NSNumber numberWithDouble:self.beaconC.x]];
    [P3 addObject:[NSNumber numberWithDouble:self.beaconC.y]];
    
    // ex = (P2 - P1)/(numpy.linalg.norm(P2 - P1))
    NSMutableArray *ex = [[NSMutableArray alloc] initWithCapacity:0];
    double temp = 0;
    for (int i = 0; i < [P1 count]; i++) {
        double t1 = [[P2 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double t = t1 - t2;
        temp += (t*t);
    }
    for (int i = 0; i < [P1 count]; i++) {
        double t1 = [[P2 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double exx = (t1 - t2)/sqrt(temp);
        [ex addObject:[NSNumber numberWithDouble:exx]];
    }
    
    // i = dot(ex, P3 - P1)
    NSMutableArray *p3p1 = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [P3 count]; i++) {
        double t1 = [[P3 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double t3 = t1 - t2;
        [p3p1 addObject:[NSNumber numberWithDouble:t3]];
    }
    
    double ival = 0;
    for (int i = 0; i < [ex count]; i++) {
        double t1 = [[ex objectAtIndex:i] doubleValue];
        double t2 = [[p3p1 objectAtIndex:i] doubleValue];
        ival += (t1*t2);
    }
    
    // ey = (P3 - P1 - i*ex)/(numpy.linalg.norm(P3 - P1 - i*ex))
    NSMutableArray *ey = [[NSMutableArray alloc] initWithCapacity:0];
    double p3p1i = 0;
    for (int  i = 0; i < [P3 count]; i++) {
        double t1 = [[P3 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
        double t = t1 - t2 -t3;
        p3p1i += (t*t);
    }
    for (int i = 0; i < [P3 count]; i++) {
        double t1 = [[P3 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
        double eyy = (t1 - t2 - t3)/sqrt(p3p1i);
        [ey addObject:[NSNumber numberWithDouble:eyy]];
    }
    
    
    // ez = numpy.cross(ex,ey)
    // if 2-dimensional vector then ez = 0
    NSMutableArray *ez = [[NSMutableArray alloc] initWithCapacity:0];
    double ezx;
    double ezy;
    double ezz;
    if ([P1 count] !=3){
        ezx = 0;
        ezy = 0;
        ezz = 0;
        
    }else{
        ezx = ([[ex objectAtIndex:1] doubleValue]*[[ey objectAtIndex:2]doubleValue]) - ([[ex objectAtIndex:2]doubleValue]*[[ey objectAtIndex:1]doubleValue]);
        ezy = ([[ex objectAtIndex:2] doubleValue]*[[ey objectAtIndex:0]doubleValue]) - ([[ex objectAtIndex:0]doubleValue]*[[ey objectAtIndex:2]doubleValue]);
        ezz = ([[ex objectAtIndex:0] doubleValue]*[[ey objectAtIndex:1]doubleValue]) - ([[ex objectAtIndex:1]doubleValue]*[[ey objectAtIndex:0]doubleValue]);
        
    }
    
    [ez addObject:[NSNumber numberWithDouble:ezx]];
    [ez addObject:[NSNumber numberWithDouble:ezy]];
    [ez addObject:[NSNumber numberWithDouble:ezz]];
    
    
    // d = numpy.linalg.norm(P2 - P1)
    double d = sqrt(temp);
    
    // j = dot(ey, P3 - P1)
    double jval = 0;
    for (int i = 0; i < [ey count]; i++) {
        double t1 = [[ey objectAtIndex:i] doubleValue];
        double t2 = [[p3p1 objectAtIndex:i] doubleValue];
        jval += (t1*t2);
    }
    
    // x = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d)
    double xval = (pow(self.distA,2) - pow(self.distB,2) + pow(d,2))/(2*d);
    
    // y = ((pow(DistA,2) - pow(DistC,2) + pow(i,2) + pow(j,2))/(2*j)) - ((i/j)*x)
    double yval = ((pow(self.distA,2) - pow(self.distC,2) + pow(ival,2) + pow(jval,2))/(2*jval)) - ((ival/jval)*xval);
    
    // z = sqrt(pow(DistA,2) - pow(x,2) - pow(y,2))
    // if 2-dimensional vector then z = 0
    double zval;
    if ([P1 count] !=3){
        zval = 0;
    }else{
        zval = sqrt(pow(self.distA,2) - pow(xval,2) - pow(yval,2));
    }
    
    // triPt = P1 + x*ex + y*ey + z*ez
    NSMutableArray *triPt = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [P1 count]; i++) {
        double t1 = [[P1 objectAtIndex:i] doubleValue];
        double t2 = [[ex objectAtIndex:i] doubleValue] * xval;
        double t3 = [[ey objectAtIndex:i] doubleValue] * yval;
        double t4 = [[ez objectAtIndex:i] doubleValue] * zval;
        double triptx = t1+t2+t3+t4;
        [triPt addObject:[NSNumber numberWithDouble:triptx]];
    }
    
    //    NSLog(@"ex %@",ex);
    //    NSLog(@"i %f",ival);
    //    NSLog(@"ey %@",ey);
    //    NSLog(@"d %f",d);
    //    NSLog(@"j %f",jval);
    //    NSLog(@"x %f",xval);
    //    NSLog(@"y %f",yval);
    //    NSLog(@"y %f",yval);
    //    NSLog(@"final result %@",triPt);
    
    if (triPt.count == 2) {
        return CGPointMake([triPt[0] doubleValue], [triPt[1] doubleValue]);
    } else {
        return CGPointZero;
    }
    
}


- (NSNumber *) optimizeDistanceAverage:(NSArray *)numbers {
    return [self roundResult:[self getAverage:[self mostReliable:numbers]]];
}

- (NSNumber *) roundResult:(NSNumber *) number {
    return @(roundf([number floatValue] * 100) / 100);
}

- (NSNumber *) getAverage:(NSArray *) arr {
    return [arr valueForKeyPath: @"@avg.self"];
}

- (NSUInteger) mostOccuringNumberInArray:(NSArray *)numbers {
    NSMutableArray *flooredArr = [NSMutableArray new];
    for (int i = 0; i < numbers.count; i++) {
        NSUInteger floored = floor([numbers[i] integerValue]);
        [flooredArr addObject:@(floored)];
    }
    
    NSCountedSet *setOfObjects = [[NSCountedSet alloc] initWithArray:flooredArr];
    NSNumber *mostOccurringObject = @0;
    NSUInteger highestCount = 0;
    
    for (NSNumber *number in setOfObjects)
    {
        NSUInteger tempCount = [setOfObjects countForObject:number];
        if (tempCount > highestCount)
        {
            highestCount = tempCount;
            mostOccurringObject = number;
        }
    }
    return [mostOccurringObject integerValue];
}

- (NSArray *) mostReliable:(NSArray *)numbers {
    
    NSInteger mostReliable = [self mostOccuringNumberInArray:numbers];
    
    NSArray *result = [numbers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSNumber *num, NSDictionary *bindings) {
        return ceil([num integerValue]) > ( mostReliable / 2 ) && floor([num integerValue]) < (mostReliable * 2 );
    }]];
   return result;
}

- (NSString *)description {
    CGPoint myCoordinate = [self getMyCoordinate];
    return [NSString stringWithFormat:@"\nA: (%f,%f) B: (%f,%f) C: (%f,%f) \nDistA: %f nDistB: %f nDistC: %f \nCoord: (%f,%f) ", self.beaconA.x, self.beaconA.y, self.beaconB.x, self.beaconB.y, self.beaconC.x, self.beaconC.y, self.distA, self.distB, self.distC, myCoordinate.x, myCoordinate.y];
}


@end
