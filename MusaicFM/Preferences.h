//
//  Preferences.h
//  MusaicFM
//
//  Created by Dennis Oberhoff on 14/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, PreferencesMode) {
    PreferencesModeLastFmUser = 0,
    PreferencesModeTag = 1,
    PreferencesModeSpotifyUser = 2,
    PreferencesModeSpotifyReleases = 3,
    PreferencesModeSpotifyLikedSongs = 4,
};

@interface Preferences : NSObject <NSCoding>

@property (nonatomic, readwrite, assign) PreferencesMode mode;

@property (nonatomic, readwrite, strong) NSString *spotifyToken;
@property (nonatomic, readwrite, strong) NSString *spotifyRefresh;
@property (nonatomic, readwrite, strong) NSString *spotifyCode;

@property (nonatomic, readwrite, strong) NSString *lastfmUser;
@property (nonatomic, readwrite, strong) NSString *lastfmTag;

@property (nonatomic, readwrite, assign) NSInteger rows;
@property (nonatomic, readwrite, assign) NSInteger delays;
@property (nonatomic, readwrite, assign) NSInteger lastfmWeekly;

@property (nonatomic, readwrite, strong) NSArray *artworks;

- (void)synchronize;
- (void)clear;
+ (Preferences *)preferences;

@end
