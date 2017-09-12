//
// BBConfig.h
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
#import "AFNetworking.h"
#import <UIKit/UIKit.h>
#import "BBDataManager.h"

@interface BBConfig : NSObject

#define BB_API_VERSION                  @"v2"

#define BB_STORE_KEY_API_KEY            @"BB_STORE_KEY_API_KEY"
#define BB_STORE_KEY_API_BASE_URL       @"BB_STORE_KEY_API_BASE_URL"
#define BB_STORE_KEY_CUSTOM_COLOR       @"BB_STORE_KEY_CUSTOM_COLOR"
#define BB_STORE_KEY_REGULAR_FONT       @"BB_STORE_KEY_REGULAR_FONT"
#define BB_STORE_KEY_LIGHT_FONT         @"BB_STORE_KEY_LIGHT_FONT"

#define BB_POPUP_DONT_SHOW              @"BB_POPUP_DONT_SHOW_2"

typedef NS_ENUM(NSUInteger, BBSSLPinningMode) {
    BBSSLPinningModeNone,
    BBSSLPinningModePublicKey
};

// IMPORTANT: ´apiKey´, ´apiBaseURL´& ´currentPlaceId´ has to be configured
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *apiBaseURL;
@property (nonatomic, copy) NSString *currentPlaceId;

// Default color is [UIColor darkGrayColor];
@property (nonatomic, strong) UIColor  *customColor;

// Default fonts are both [UIFont systemFontOfSize:16.f];
@property (nonatomic, strong) UIFont  *regularFont;
@property (nonatomic, strong) UIFont  *lightFont;

// Default SSL Pinning Mode is BBSSLPinningModeNone
@property (nonatomic, assign) BBSSLPinningMode SSLPinningMode;

+ (instancetype)sharedConfig;
+ (NSBundle *)libBundle;

-(UIFont *)regularFontWithSize:(CGFloat)size;
-(UIFont *)lightFontWithSize:(CGFloat)size;

- (void) setupWithPlaceIdentifier:(NSString *)identifier withCompletion:(void (^)(NSString *placeIdentifier, NSError *error))completionBlock;

- (NSString *) APIURL;

@end
