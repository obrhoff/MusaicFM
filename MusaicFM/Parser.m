//
//  Parser.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import "Parser.h"
#import "Artwork.h"

@implementation Parser

+ (NSArray *)parseSpotifyItems:(NSArray *)responseDicts {
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *albumDict in responseDicts) {
        float targetSize = 300;
        NSArray *images = [albumDict[@"images"] sortedArrayUsingComparator:^NSComparisonResult (NSDictionary *first, NSDictionary *second) {
            CGFloat firstCompare = fabs([first[@"width"] floatValue] - targetSize);
            CGFloat secondCompare = fabs([second[@"width"] floatValue] - targetSize);
            return firstCompare >= secondCompare;
        }];
        NSURL *artworkUrl = [NSURL URLWithString:images.firstObject[@"url"]];
        if (!artworkUrl) {
            continue;
        }
        Artwork *artwork = [Artwork new];
        artwork.artworkUrl = artworkUrl;
        artwork.album = albumDict[@"name"];
        artwork.artist = [albumDict[@"artists"] firstObject][@"name"];
        artwork.url = albumDict[@"href"];
        [items addObject:artwork];
    }

    return [NSSet setWithArray:items.copy].allObjects;
}

+ (NSArray *)parseItems:(NSArray *)itemDicts {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:itemDicts.count];

    for (NSDictionary *itemDict in itemDicts) {
        NSString *urlText = [itemDict[@"image"] lastObject][@"#text"];
        NSURL *artworkUrl = [NSURL URLWithString:urlText];
        if (!artworkUrl) {
            continue;
        }

        Artwork *artwork = [Artwork new];
        artwork.artworkUrl = artworkUrl;
        artwork.album = itemDict[@"name"];
        artwork.url = [NSURL URLWithString:itemDict[@"url"]];
        artwork.artist = itemDict[@"artist"][@"name"];
        [items addObject:artwork];
    }

    return [NSSet setWithArray:items.copy].allObjects;
}

@end
