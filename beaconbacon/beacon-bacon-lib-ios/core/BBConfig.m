//
// BBConfig.m
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

#import "BBConfig.h"

@implementation BBConfig

+ (instancetype)sharedConfig {
    static BBConfig *_sharedConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfig                = [[BBConfig alloc] init];
        _sharedConfig.currentPlaceId = nil;
        _sharedConfig.customColor    = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:BB_STORE_KEY_CUSTOM_COLOR]];
        _sharedConfig.regularFont    = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:BB_STORE_KEY_REGULAR_FONT]];
        _sharedConfig.lightFont      = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:BB_STORE_KEY_LIGHT_FONT]];
        _sharedConfig.apiKey         = [[NSUserDefaults standardUserDefaults] valueForKey:BB_STORE_KEY_API_KEY];
        _sharedConfig.apiBaseURL     = [[NSUserDefaults standardUserDefaults] valueForKey:BB_STORE_KEY_API_BASE_URL];
        _sharedConfig.SSLPinningMode = BBSSLPinningModeNone;
    });
    return _sharedConfig;
}

+ (NSBundle *)libBundle {
    return [NSBundle bundleWithIdentifier:@"dk.mustache.beaconbaconlib"];
}

-(UIFont *)regularFontWithSize:(CGFloat)size {
    return [self.regularFont fontWithSize:size];
}

-(UIFont *)lightFontWithSize:(CGFloat)size {
    return [self.lightFont fontWithSize:size];
}

- (void) setupWithPlaceIdentifier:(NSString *)identifier withCompletion:(void (^)(NSString *placeIdentifier, NSError *error))completionBlock {
    
    if (identifier == nil) {
        [BBConfig sharedConfig].currentPlaceId = nil;
        completionBlock(nil, nil);
        return;
    }
    
    [[BBDataManager sharedInstance] fetchPlaceIdFromIdentifier:identifier withCompletion:^(NSString *placeIdentifier, NSError *error) {
        if (error == nil && placeIdentifier != nil) {
            [BBConfig sharedConfig].currentPlaceId = placeIdentifier;
        } else {
            [BBConfig sharedConfig].currentPlaceId = nil;
        }
        // Handle Completion
        if (completionBlock != nil) {
            completionBlock(placeIdentifier, error);
        }
    }];
}

- (void) setCustomColor:(UIColor *)customColor {
    if (customColor == nil) {
        customColor = [UIColor darkGrayColor];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:customColor] forKey:BB_STORE_KEY_CUSTOM_COLOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _customColor = customColor;
}

- (void) setRegularFont:(UIFont *)regularFont {
    if (regularFont == nil) {
        regularFont = [UIFont systemFontOfSize:16.f];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:regularFont] forKey:BB_STORE_KEY_REGULAR_FONT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _regularFont = regularFont;
}

- (void) setLightFont:(UIFont *)lightFont {
    if (lightFont == nil) {
        lightFont = [UIFont systemFontOfSize:16.f];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:lightFont] forKey:BB_STORE_KEY_LIGHT_FONT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _lightFont = lightFont;
}

- (void) setApiKey:(NSString *)apiKey {
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:BB_STORE_KEY_API_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _apiKey = apiKey;
}

- (void) setApiBaseURL:(NSString *)apiBaseURL {
    [[NSUserDefaults standardUserDefaults] setObject:apiBaseURL forKey:BB_STORE_KEY_API_BASE_URL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _apiBaseURL = apiBaseURL;
}

- (NSString *) APIURL {
    return [NSString stringWithFormat:@"%@/%@/", [BBConfig sharedConfig].apiBaseURL, BB_API_VERSION];
}
@end
