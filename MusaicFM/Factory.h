//
//  Factory.h
//  MusaicFM
//
//  Created by Dennis Oberhoff on 03/12/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Factory : NSObject

+ (NSURLRequest *)lastFmRequest:(NSArray *)queryItems;

+ (NSURLComponents *)spotifyAlbums;
+ (NSURLComponents *)spotifyNewReleases;
+ (NSURLComponents *)spotifyToken;
+ (NSURLComponents *)spotifyAuthentification;

@end
