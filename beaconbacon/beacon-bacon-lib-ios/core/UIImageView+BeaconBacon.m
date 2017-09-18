//
// UIImageView+BeaconBacon.m
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

#import "UIImageView+BeaconBacon.h"
#import "BBConfig.h"

@implementation UIImageView (BeaconBacon)

- (void) loadImageFromURL:(NSURL *)url completionBlock:(void (^)(UIImage* image, NSError* error))completionBlock {
    
    [UIImageView loadImageFromURL:url completionBlock:^(UIImage *image, NSError *error) {
        self.image = image;
        if (completionBlock) { completionBlock(image, nil); }

    }];
    
    
}

+ (void) loadImageFromURL:(NSURL *)url completionBlock:(void (^)(UIImage* image, NSError* error))completionBlock {

    if (url == nil) {
        NSLog(@"No URL provided");
        if (completionBlock) { completionBlock(nil, nil); }
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [BBConfig sharedConfig].apiKey] forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error == nil){
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image == nil) {
                NSLog(@"Error trying to convert data to image");
                completionBlock(nil, nil);
            } else {
                if (completionBlock) { completionBlock(image, nil); }
            }
        } else {
            NSLog(@"An error occured: %@",error.localizedDescription);
            if (completionBlock) { completionBlock(nil, error); }
        }
    }];
    
}

@end
