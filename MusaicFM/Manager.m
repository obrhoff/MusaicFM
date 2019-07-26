//
//  Manager.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import "Manager.h"
#import "Parser.h"
#import "Constants.h"
#import "Preferences.h"
#import "Factory.h"

@interface Manager ()

@property (nonatomic, readwrite, strong) NSURLSession *session;

@end

@implementation Manager

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.URLCache = nil;
        configuration.timeoutIntervalForRequest = 15;
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)performSpotifyUserAlbums:(void (^)(NSArray *items))completion andFailure:(void (^)(NSError *error))failure {
    NSURLRequest * (^ create)(NSInteger offset) = ^NSURLRequest * (NSInteger offset) {
        NSURLComponents *offsetComponents = [Factory spotifyAlbums];
        offsetComponents.queryItems = @[[NSURLQueryItem queryItemWithName:@"limit" value:@"50"],
                                        [NSURLQueryItem queryItemWithName:@"offset" value:@(offset).stringValue]];
        return [NSURLRequest requestWithURL:offsetComponents.URL];
    };
    
    NSMutableArray *total = [NSMutableArray array];
    void (^ finalCompletion)(NSArray *responses) = ^void (NSArray *responses) {
        [total addObjectsFromArray:responses];
        NSMutableArray *itemDicts = [NSMutableArray array];
        for (NSDictionary *items in total) {
            for (NSDictionary *itemDict in items[@"items"]) {
                [itemDicts addObject:itemDict[@"album"]];
            }
        }
        
        NSArray *artworks = [Parser parseSpotifyItems:itemDicts.copy];
        Preferences *preferences = [Preferences preferences];
        preferences.artworks = artworks;
        [preferences synchronize];
        if (completion) completion(artworks);
    };
    
    void (^ initialCompletion)(NSArray *responses) = ^void (NSArray *responses) {
        [total addObjectsFromArray:responses];
        
        NSMutableArray *next = [NSMutableArray array];
        NSDictionary *initial = responses.firstObject;
        NSInteger totalItems = [initial[@"total"] integerValue];
        NSInteger offset = 50;
        while (offset < totalItems) {
            [next addObject:create(offset)];
            offset += 50;
        }
        next.count ? [self performSpotifyTokenRequest:next.copy withCompletionHandler:finalCompletion andFailure:failure] : finalCompletion(total.copy);
    };
    
    [self performSpotifyTokenRequest:@[create(0)] withCompletionHandler:initialCompletion andFailure:failure];
}

- (void)performSpotifyReleases:(void (^)(NSArray *items))completion andFailure:(void (^)(NSError *error))failure {
    NSURLRequest * (^ create)(NSInteger offset) = ^NSURLRequest * (NSInteger offset) {
        NSURLComponents *offsetComponents = [Factory spotifyNewReleases];
        offsetComponents.queryItems = @[[NSURLQueryItem queryItemWithName:@"limit" value:@"50"],
                                        [NSURLQueryItem queryItemWithName:@"offset" value:@(offset).stringValue]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:offsetComponents.URL];
        return request.copy;
    };
    
    NSMutableArray *totalResponses = [NSMutableArray array];
    void (^ finalCompletion)(NSArray *responses) = ^void (NSArray *responses) {
        [totalResponses addObjectsFromArray:responses];
        NSMutableArray *itemDicts = [NSMutableArray array];
        for (NSDictionary *itemDict in responses) {
            [itemDicts addObjectsFromArray:itemDict[@"albums"][@"items"]];
        }
        
        NSArray *artworks = [Parser parseSpotifyItems:itemDicts.copy];
        Preferences *preferences = [Preferences preferences];
        preferences.artworks = artworks;
        [preferences synchronize];
        if (completion) completion(artworks);
    };
    
    void (^ initialCompletion)(NSArray *responses) = ^void (NSArray *responses) {
        [totalResponses addObjectsFromArray:responses];
        
        NSMutableArray *nextRequests = [NSMutableArray array];
        NSDictionary *initial = responses.firstObject;
        NSInteger total = [initial[@"albums"][@"total"] integerValue];
        NSInteger offset = 50;
        while (offset < total) {
            [nextRequests addObject:create(offset)];
            offset += 50;
        }
        [self performSpotifyTokenRequest:nextRequests.copy withCompletionHandler:finalCompletion andFailure:failure];
    };
    
    [self performSpotifyTokenRequest:@[create(0)] withCompletionHandler:initialCompletion andFailure:failure];
}

- (void)performSpotifyLikedSongs:(void (^)(NSArray *items))completion andFailure:(void (^)(NSError *error))failure {
    NSURLRequest * (^ create)(NSInteger offset) = ^NSURLRequest * (NSInteger offset) {
        NSURLComponents *offsetComponents = [Factory spotifyTracks];
        offsetComponents.queryItems = @[[NSURLQueryItem queryItemWithName:@"limit" value:@"50"],
                                        [NSURLQueryItem queryItemWithName:@"offset" value:@(offset).stringValue]];
        return [NSURLRequest requestWithURL:offsetComponents.URL];
    };
    
    NSMutableArray *total = [NSMutableArray array];
    void (^ finalCompletion)(NSArray *responses) = ^void (NSArray *responses) {
        [total addObjectsFromArray:responses];
        // unique albums
        NSMutableDictionary *uniqueAlbums = [NSMutableDictionary new];
        for (NSDictionary *items in total) {
            for (NSDictionary *itemDict in items[@"items"]) {
                [uniqueAlbums setObject:itemDict[@"track"][@"album"] forKey:itemDict[@"track"][@"album"][@"id"]];
            }
        }
        
        NSArray *artworks = [Parser parseSpotifyItems:uniqueAlbums.allValues];
        Preferences *preferences = [Preferences preferences];
        preferences.artworks = artworks;
        [preferences synchronize];
        if (completion) completion(artworks);
    };
    
    void (^ initialCompletion)(NSArray *responses) = ^void (NSArray *responses) {
        [total addObjectsFromArray:responses];
        
        NSMutableArray *next = [NSMutableArray array];
        NSDictionary *initial = responses.firstObject;
        NSInteger totalItems = [initial[@"total"] integerValue];
        NSInteger offset = 50;
        while (offset < totalItems) {
            [next addObject:create(offset)];
            offset += 50;
        }
        next.count ? [self performSpotifyTokenRequest:next.copy withCompletionHandler:finalCompletion andFailure:failure] : finalCompletion(total.copy);
    };
    // make first request / start api get process
    [self performSpotifyTokenRequest:@[create(0)] withCompletionHandler:initialCompletion andFailure:failure];
}

// instance method -
- (void)performSpotifyArtists:(void (^)(NSArray *items))completion andFailure:(void (^)(NSError *error))failure {
 
    NSURLRequest * (^ create)(NSString *after) = ^NSURLRequest * (NSString *after) {
        NSURLComponents *offsetComponents = [Factory spotifyArtists];
        NSMutableArray *queryItems = offsetComponents.queryItems
                                        ? [NSMutableArray arrayWithArray: offsetComponents.queryItems]
                                        : [NSMutableArray new];
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"limit" value:@"50"]];
        if ([after length] != 0) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"after" value:after]];
        }
        offsetComponents.queryItems = queryItems;
        
        return [NSURLRequest requestWithURL:offsetComponents.URL];
    };
    
    NSMutableArray *total = [NSMutableArray array];
    void (^ finalCompletion)(NSArray *responses) = ^void (NSArray *responses) {
        [total addObjectsFromArray:responses];

        NSMutableArray *itemDicts = [NSMutableArray array];
        for (NSDictionary *itemDict in responses) {
            [itemDicts addObjectsFromArray:itemDict[@"artists"][@"items"]];
        }
        
        NSArray *artworks = [Parser parseSpotifyItems:itemDicts];
        Preferences *preferences = [Preferences preferences];
        preferences.artworks = artworks;
        [preferences synchronize];
        if (completion) completion(artworks);
    };
    
    __block __weak void (^weakInitialCompletion)(NSArray *responses);
    void (^ initialCompletion)(NSArray *responses);
    weakInitialCompletion = initialCompletion = ^void (NSArray *responses) {
        [total addObjectsFromArray:responses];
        
        NSDictionary *initial = responses.firstObject[@"artists"];
        id after = initial[@"cursors"][@"after"];
        if ((after != nil) && (after != (id)[NSNull null])) {
            [self performSpotifyTokenRequest:@[create(after)] withCompletionHandler:weakInitialCompletion andFailure:failure];
        } else {
            finalCompletion(total.copy);
        }

    };
    
    [self performSpotifyTokenRequest:@[create(nil)] withCompletionHandler:weakInitialCompletion andFailure:failure];
}

- (void)performSpotifyToken:(NSString *)code completionHandler:(dispatch_block_t)completion andFailure:(void (^)(NSError *error))failure {
    NSURLComponents *components = [Factory spotifyToken];
    NSDictionary *body = @{
                           @"grant_type":@"authorization_code",
                           @"code":code, @"redirect_uri":spotifyRedirectUrl,
                           @"client_id":spotifyClientId, @"client_secret":spotifySecretId
                           };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[[self class] NSStringFromQueryParameters:body] dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [self performRequest:request.copy withCompletionHandler:^(NSDictionary *response) {
        if (response[@"error"]) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorNoPermissionsToReadFile userInfo:nil];
            if (failure) failure(error);
            return;
        }
        Preferences *preferences = [Preferences preferences];
        preferences.spotifyCode = code;
        preferences.spotifyRefresh = response[@"refresh_token"];
        preferences.spotifyToken = response[@"access_token"];
        [preferences synchronize];
        if (completion) completion();
    } andFailure:failure];
}

- (void)performLastfmTag:(void (^)(NSArray *items))completion andFailure:(void (^)(NSError *error))failure {
    NSMutableArray *paramter = @[[NSURLQueryItem queryItemWithName:@"tag" value:self.preferences.lastfmTag],
                                 [NSURLQueryItem queryItemWithName:@"method" value:@"tag.getTopAlbums"],
                                 [NSURLQueryItem queryItemWithName:@"limit" value:@"500"]].mutableCopy;
    
    NSURLRequest *request = [Factory lastFmRequest:paramter];
    [self performRequest:request withCompletionHandler:^(NSDictionary *response) {
        NSArray *artworks = [Parser parseItems:response[@"albums"][@"album"]];
        Preferences *preferences = [Preferences preferences];
        preferences.artworks = artworks;
        [preferences synchronize];
        if (completion) completion(artworks);
    } andFailure:failure];
}

- (void)performLastfmWeekly:(void (^)(NSArray *items))completion andFailure:(void (^)(NSError *error))failure {
    NSMutableArray *paramter = @[[NSURLQueryItem queryItemWithName:@"user" value:self.preferences.lastfmUser],
                                 [NSURLQueryItem queryItemWithName:@"method" value:@"user.gettopalbums"],
                                 [NSURLQueryItem queryItemWithName:@"limit" value:@"500"]].mutableCopy;
    
    switch (self.preferences.lastfmWeekly) {
        case Weekly7Days:
            [paramter addObject:[NSURLQueryItem queryItemWithName:@"period" value:@"7day"]];
            break;
            
        case Weekly1Month:
            [paramter addObject:[NSURLQueryItem queryItemWithName:@"period" value:@"1month"]];
            break;
            
        case Weekly3Month:
            [paramter addObject:[NSURLQueryItem queryItemWithName:@"period" value:@"3month"]];
            break;
            
        case Weekly6Month:
            [paramter addObject:[NSURLQueryItem queryItemWithName:@"period" value:@"6month"]];
            break;
            
        case Weekly12Month:
            [paramter addObject:[NSURLQueryItem queryItemWithName:@"period" value:@"12month"]];
            break;
            
        default:
            break;
    }
    
    NSURLRequest *request = [Factory lastFmRequest:paramter];
    [self performRequest:request withCompletionHandler:^(NSDictionary *response) {
        NSArray *artworks = [Parser parseItems:response[@"topalbums"][@"album"]];
        Preferences *preferences = [Preferences preferences];
        preferences.artworks = artworks;
        [preferences synchronize];
        if (completion) completion(artworks);
    } andFailure:failure];
}

- (void)performSpotifyTokenRequest:(NSArray *)requests
             withCompletionHandler:(void (^)(NSArray *responses))completion
                        andFailure:(void (^)(NSError *error))failure {
    __block NSMutableArray *responses = [NSMutableArray array];
    __block NSInteger taskCount = requests.count;
    __weak typeof(self) weakSelf = self;
    
    void (^ recovery)(void) = ^{
        NSData *authData = [[NSString stringWithFormat:@"%@:%@", spotifyClientId, spotifySecretId] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *auth = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
        
        NSURLComponents *components = [Factory spotifyToken];
        NSDictionary *body = @{
                               @"grant_type":@"refresh_token", @"refresh_token":self.preferences.spotifyRefresh
                               };
        NSMutableURLRequest *recovery = [NSMutableURLRequest requestWithURL:components.URL];
        recovery.HTTPMethod = @"POST";
        recovery.HTTPBody = [[[self class] NSStringFromQueryParameters:body] dataUsingEncoding:NSUTF8StringEncoding];
        [recovery addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [recovery addValue:auth forHTTPHeaderField:@"Authorization"];
        
        [weakSelf performRequest:recovery.copy withCompletionHandler:^(NSDictionary *response) {
            NSInteger errorCode = [response[@"error"][@"status"] integerValue];
            if (response[@"error"]) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorNoPermissionsToReadFile userInfo:nil];
                if (errorCode == 401) {
                    self.preferences.spotifyCode = nil;
                    self.preferences.spotifyRefresh = nil;
                    self.preferences.spotifyToken = nil;
                    [self.preferences synchronize];
                }
                if (failure) failure(error);
            }
            else {
                NSString *accessToken = response[@"access_token"];
                self.preferences.spotifyToken = accessToken;
                [self.preferences synchronize];
                [weakSelf performSpotifyTokenRequest:requests withCompletionHandler:completion andFailure:failure];
            }
        } andFailure:failure];
    };
    
    void (^ internalCompletion)(NSDictionary *response) = ^void (NSDictionary *response) {
        if ([response[@"error"][@"status"] integerValue] == 401) {
            recovery();
            return;
        }
        else if (response[@"error"]) {
            if (failure) failure([NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorNoPermissionsToReadFile userInfo:nil]);
            return;
        }
        taskCount -= 1;
        [responses addObject:response];
        if (taskCount) return;
        
        if (completion) completion(responses.copy);
    };
    
    for (NSURLRequest *request in requests) {
        NSMutableURLRequest *authRequest = request.mutableCopy;
        [authRequest setValue:[NSString stringWithFormat:@"Bearer %@", self.preferences.spotifyToken] forHTTPHeaderField:@"Authorization"];
        [authRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [self performRequest:authRequest withCompletionHandler:internalCompletion andFailure:failure];
    }
}

- (NSURLSessionDataTask *)performRequest:(NSURLRequest *)request
                   withCompletionHandler:(void (^)(NSDictionary *response))completion
                              andFailure:(void (^)(NSError *error))failure {
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error.code == kCFURLErrorCancelled) return;
        
        if (error && failure) {
            failure(error);
        }
        else if (completion) {
            completion([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]);
        }
    }];
    [task resume];
    return task;
}

+ (NSString *)NSStringFromQueryParameters:(NSDictionary *)queryParameters {
    NSMutableArray *parts = [NSMutableArray array];
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat:@"%@=%@",
                          [key stringByAddingPercentEncodingWithAllowedCharacters:set],
                          [value stringByAddingPercentEncodingWithAllowedCharacters:set]];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString:@"&"];
}


@end
