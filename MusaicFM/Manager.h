//
//  Manager.h
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Preferences.h"

typedef NS_ENUM (NSUInteger, Weekly) {
    WeeklyAll = 0,
    Weekly7Days = 1,
    Weekly1Month = 2,
    Weekly3Month = 3,
    Weekly6Month = 4,
    Weekly12Month = 5,
};

@interface Manager : NSObject

- (void)performSpotifyUserAlbums:(void (^)(NSArray *items)) completion andFailure:(void (^)(NSError *error))failure;
- (void)performSpotifyReleases:(void (^)(NSArray *items)) completion andFailure:(void (^)(NSError *error))failure;
- (void)performSpotifyLikedSongs:(void (^)(NSArray *items)) completion andFailure:(void (^)(NSError *error))failure;
- (void)performSpotifyToken:(NSString *)code completionHandler:(dispatch_block_t)completion andFailure:(void (^)(NSError *error))failure;
- (void)performLastfmTag:(void (^)(NSArray *items)) completion andFailure:(void (^)(NSError *error))failure;
- (void)performLastfmWeekly:(void (^)(NSArray *items)) completion andFailure:(void (^)(NSError *error))failure;

@end
