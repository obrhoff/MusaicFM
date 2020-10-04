//
//  Artwork.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import "Artwork.h"

@implementation Artwork

- (instancetype)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (self) {
        self.url = [decoder decodeObjectForKey:@"url"];
        self.artworkUrl = [decoder decodeObjectForKey:@"artworkUrl"];
        self.album = [decoder decodeObjectForKey:@"name"];
        self.artist = [decoder decodeObjectForKey:@"artist"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:self.artworkUrl forKey:@"artworkUrl"];
    [encoder encodeObject:self.album forKey:@"album"];
    [encoder encodeObject:self.artist forKey:@"artist"];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    Artwork* compare = object;
    return [compare.artworkUrl isEqual:self.artworkUrl];
}

@end
