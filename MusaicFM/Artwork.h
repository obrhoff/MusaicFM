//
//  Artwork.h
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Artwork : NSObject <NSCoding>

@property (nonatomic, readwrite, strong)NSString * album;
@property (nonatomic, readwrite, strong) NSString *artist;
@property (nonatomic, readwrite, strong) NSURL *artworkUrl;
@property (nonatomic, readwrite, strong) NSURL *url;

@end
