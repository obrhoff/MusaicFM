//
//  Parser.h
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Parser : NSObject

+ (NSArray *)parseSpotifyItems:(NSArray *)itemDicts;
+ (NSArray *)parseItems:(NSArray *)itemDicts;

@end
