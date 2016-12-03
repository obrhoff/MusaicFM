//
//  Factory.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 03/12/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import "Factory.h"
#import "Constants.h"

@implementation Factory


+ (NSURLRequest *)lastFmRequest:(NSArray *)queryItems {
    NSMutableArray *items = queryItems ? queryItems.mutableCopy : [NSMutableArray new];

    [items addObjectsFromArray:@[[NSURLQueryItem queryItemWithName:@"api_key" value:lastFmId],
                                 [NSURLQueryItem queryItemWithName:@"format" value:@"json"]]];

    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"ws.audioscrobbler.com";
    components.path = @"/2.0/";
    components.queryItems = items.copy;
    return [NSURLRequest requestWithURL:components.URL];
}

+ (NSURLComponents *)spotifyAlbums {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"api.spotify.com";
    components.path = @"/v1/me/albums";
    return components;
}


+ (NSURLComponents *)spotifyNewReleases {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"api.spotify.com";
    components.path = @"/v1/browse/new-releases";
    return components;
}


+ (NSURLComponents *)spotifyToken {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"accounts.spotify.com";
    components.path = @"/api/token";
    return components;
}

+ (NSURLComponents *)spotifyAuthentification {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"accounts.spotify.com";
    components.path = @"/authorize/";
    components.queryItems = @[[NSURLQueryItem queryItemWithName:@"client_id" value:spotifyClientId],
                              [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"],
                              [NSURLQueryItem queryItemWithName:@"scope" value:@"user-library-read"],
                              [NSURLQueryItem queryItemWithName:@"show_dialog" value:@"true"],
                              [NSURLQueryItem queryItemWithName:@"redirect_uri" value:spotifyRedirectUrl]];

    return components;
}

@end
