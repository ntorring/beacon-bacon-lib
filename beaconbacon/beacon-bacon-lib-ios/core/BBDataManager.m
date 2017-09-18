//
// BBDataManager.m
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

#import "BBDataManager.h"

@interface BBDataManager()

@property (nonatomic, strong) NSArray *cachedMenuItems;
@property (nonatomic, strong) BBPlace *cachedCurrentPlace;
@property (nonatomic, strong) NSArray *cachedPlaces;

@end


@implementation BBDataManager

+ (BBDataManager *)sharedInstance {
    
    static BBDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BBDataManager alloc] init];
        
    });
    return sharedInstance;
}

- (NSError *) errorInvalidConfiguration {
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"Ugyldig opsætning", NSUnderlyingErrorKey : @(BB_ERROR_CODE_INVALID_CONFIGURATION) };
    return [[NSError alloc] initWithDomain:@"beaconbacon.nosuchagency.com" code:BB_ERROR_CODE_INVALID_CONFIGURATION userInfo:errorDictionary];
}

- (NSError *) errorUnsupportedPlace {
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"Sted ikke understøttet", NSUnderlyingErrorKey : @(BB_ERROR_CODE_UNSUPPORTED_PLACE) };
    return [[NSError alloc] initWithDomain:@"beaconbacon.nosuchagency.com" code:BB_ERROR_CODE_UNSUPPORTED_PLACE userInfo:errorDictionary];
}

- (NSError *) errorInvalidResponse {
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"Fejl i svar fra server", NSUnderlyingErrorKey : @(BB_ERROR_CODE_INVALID_RESPONSE) };
    return [[NSError alloc] initWithDomain:@"beaconbacon.nosuchagency.com" code:BB_ERROR_CODE_INVALID_RESPONSE userInfo:errorDictionary];
}

- (NSError *) errorSubjectNotFound {
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"Materialet blev ikke fundet", NSUnderlyingErrorKey : @(BB_ERROR_CODE_SUBJECT_NOT_FOUND) };
    return [[NSError alloc] initWithDomain:@"beaconbacon.nosuchagency.com" code:BB_ERROR_CODE_SUBJECT_NOT_FOUND userInfo:errorDictionary];
}


- (void) clearAllChacedData {
    self.cachedMenuItems = nil;
    self.cachedCurrentPlace = nil;
    self.cachedPlaces = nil;
}

- (void) fetchAllPlacesWithCompletion:(void (^)(NSArray *places, NSError *error))completionBlock {
    
    if (self.cachedPlaces == nil) {
        [[BBAPIClient sharedClient] GET:@"place/" parameters:nil progress:nil success:^(NSURLSessionDataTask __unused *task, id JSON) {
            
            NSError *error;
            NSDictionary *attributes = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
            if (error) {
                
                [self clearAllChacedData];
                completionBlock(nil, error);
                return;
            }
            
            NSArray *placesDict = attributes[@"data"];
            NSMutableArray *places = [NSMutableArray new];
            
            for (NSDictionary *placeDict in placesDict) {
                [places addObject:[[BBPlace alloc] initWithAttributes:placeDict]];
            }
            
            // Apply Sort by 'order'
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            self.cachedPlaces = [places sortedArrayUsingDescriptors:sortDescriptors];
            
            completionBlock(self.cachedPlaces, nil);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [self clearAllChacedData];
            completionBlock(nil, error);
        }];
    } else {
        // Return Cache
        completionBlock(self.cachedPlaces, nil);
    }
}

- (void) fetchPlaceIdFromIdentifier:(NSString *)identifier withCompletion:(void (^)(NSString *placeIdentifier, NSError *error))completionBlock {
    
    [self fetchAllPlacesWithCompletion:^(NSArray *places, NSError *error) {
        if (error == nil) {
            for (BBPlace *place in places) {
                if ([place.identifier1 isEqualToString:identifier]) {
                    NSString *currentPlaceId = [NSString stringWithFormat:@"%ld", place.place_id];
                    
                    [self clearAllChacedData];
                    completionBlock(currentPlaceId, nil);
                    return;
                }
            }
            
            [self clearAllChacedData];
            completionBlock(nil, [self errorUnsupportedPlace]);
        } else {
            completionBlock(nil, error);
        }
    }];
}


- (void) requestPOIMenuItemsWithCompletion:(void (^)(NSArray *result, NSError *error))completionBlock {
    
    if ([BBConfig sharedConfig].currentPlaceId == nil) {
        completionBlock(nil, [self errorInvalidConfiguration]);
        return;
    }
    
    if (self.cachedMenuItems == nil) {
        
        NSString *route = [NSString stringWithFormat:@"place/%@/menu", [BBConfig sharedConfig].currentPlaceId];
        [[BBAPIClient sharedClient] GET:route parameters:nil progress:nil success:^(NSURLSessionDataTask __unused *task, id JSON) {

            NSError *error;
            NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
            if (error) {
                completionBlock(nil, error);
                return;
            }
            NSMutableArray *menu = [[NSMutableArray alloc] initWithCapacity:jsonData.count];
            
            for (NSDictionary *attributes in jsonData) {
                BBPOIMenuItem *menuItem = [[BBPOIMenuItem alloc] initWithAttributes:attributes];
                if (menuItem) { [menu addObject:menuItem]; }
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            self.cachedMenuItems = [menu sortedArrayUsingDescriptors:sortDescriptors];

            completionBlock(self.cachedMenuItems, nil);

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completionBlock(nil, error);

        }];
    
    } else {
        // Return Cache
        completionBlock(self.cachedMenuItems, nil);
    }
}

- (void) requestSelectedPOIMenuItemsWithCompletion:(void (^)(NSArray *result, NSError *error))completionBlock {
    
    if ([BBConfig sharedConfig].currentPlaceId == nil) {
        completionBlock(nil, [self errorInvalidConfiguration]);
        return;
    }
    
    if (self.cachedMenuItems == nil) {
        
        completionBlock(@[], nil);
    } else {
        
        NSMutableArray *selectedItems = [NSMutableArray new];
        for (BBPOIMenuItem *item in self.cachedMenuItems) {
            if (item.isPOIMenuItem) {
                if (item.poi.selected) {
                    [selectedItems addObject:item];
                }
            }
        }
        completionBlock(selectedItems, nil);
    }
}

- (void) requestCurrentPlaceSetupWithCompletion:(void (^)(BBPlace *result, NSError *error))completionBlock {
    
    if ([BBConfig sharedConfig].currentPlaceId == nil) {
        completionBlock(nil, [self errorInvalidConfiguration]);
        return;
    }
    
    if (self.cachedCurrentPlace == nil || self.cachedCurrentPlace.place_id != [[BBConfig sharedConfig].currentPlaceId integerValue]) {

        NSDictionary *params = @{@"embed" : @"floors.locations.beacon"};
        NSString *route = [NSString stringWithFormat:@"place/%@/", [BBConfig sharedConfig].currentPlaceId];
        [[BBAPIClient sharedClient] GET:route parameters:params progress:nil success:^(NSURLSessionDataTask __unused *task, id JSON) {
            
            NSError *error;
            NSDictionary *attributes = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
            if (error) {
                completionBlock(nil, error);
                return;
            }
            BBPlace *place = [[BBPlace alloc] initWithAttributes:attributes];
            if (place) {
                self.cachedCurrentPlace = place;
                completionBlock(self.cachedCurrentPlace, nil);
            } else {
                self.cachedCurrentPlace = nil;
                completionBlock(nil, [self errorInvalidResponse]);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            self.cachedCurrentPlace = nil;
            completionBlock(nil, error);
            
        }];
        
    } else {
        completionBlock(self.cachedCurrentPlace, nil);
    }
    
}

- (void) requestFindASubject:(NSDictionary *)requestDict withCompletion:(void (^)(id result, NSError *error))completionBlock {
    
    if ([BBConfig sharedConfig].currentPlaceId == nil) {
        completionBlock(nil, [self errorInvalidConfiguration]);
        return;
    }
    NSString *route = [NSString stringWithFormat:@"%@place/%@/find", [[BBConfig sharedConfig] APIURL], [BBConfig sharedConfig].currentPlaceId];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = @"";
    if (!jsonData) {
        completionBlock(nil, error);
        return;
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:route parameters:nil error:nil];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setValue:[NSString stringWithFormat:@"Bearer %@", [BBConfig sharedConfig].apiKey] forHTTPHeaderField:@"Authorization"];

    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error == nil) {
            BBFoundSubject *result = [[BBFoundSubject alloc] initWithAttributes:responseObject];
            if (result) {
                if ([result isSubjectFound]) {
                    completionBlock(result, nil);
                } else {
                    completionBlock(nil, [self errorSubjectNotFound]);
                }
            } else {
                completionBlock(nil, [self errorSubjectNotFound]);
            }
        } else {
            completionBlock(nil, [self errorSubjectNotFound]);
        }
    }] resume];
}

- (void) requestFindIMSSubject:(BBIMSRequstObject *)requstObject withCompletion:(void (^)(BBFoundSubject *result, NSError *error))completionBlock {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary new];
    [requestDict setObject:@"IMS" forKey:@"find_identifier"];
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject:requstObject.faust forKey:@"Faust"];
    [requestDict setObject:data forKey:@"data"];
    
    [[BBDataManager sharedInstance] requestFindASubject:requestDict withCompletion:completionBlock];
}

@end
