//
//  MusaicFMView.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

@import QuartzCore;

#import "MusaicFMView.h"
#import "MusaicItem.h"
#import "Manager.h"
#import "NSMutableArray+Shuffle.h"
#import "Artwork.h"
#import "PreferencesViewController.h"
#import "Preferences.h"

@interface MusaicFMView () <NSCollectionViewDataSource>

@property (nonatomic, readwrite, assign) NSInteger rows;
@property (nonatomic, readwrite, assign) NSInteger delay;

@property (nonatomic, readwrite, strong) NSArray *currentItems;
@property (nonatomic, readwrite, strong) NSArray *totalItems;

@property (nonatomic, readwrite, strong) NSTimer *timer;
@property (nonatomic, readwrite, strong) Manager *manager;
@property (nonatomic, readwrite, strong) NSCollectionView *collectionView;
@property (nonatomic, readwrite, strong) NSCollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, readwrite, strong) PreferencesViewController *prefencesViewController;

@end

// intergace extends ScreenSaverView
@implementation MusaicFMView

// Step 2. Your module is instantiated and its init(frame:isPreview:) routine is called.
- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.wantsLayer = YES;
    self.animationTimeInterval = 60;
    
    Preferences *preferences = [Preferences preferences];
    self.rows = preferences.rows;
    self.delay = preferences.delays;
    
    self.manager = [Manager new];
    self.manager.preferences = [Preferences preferences];
    
    self.collectionViewLayout = [NSCollectionViewFlowLayout new];
    self.collectionViewLayout.minimumInteritemSpacing = 0.0;
    self.collectionViewLayout.minimumLineSpacing = 0.0;
    
    CGFloat size = CGRectGetHeight(self.bounds) / (CGFloat)self.rows;
    self.collectionViewLayout.itemSize = CGSizeMake(size, size);
    
    self.collectionView = [[NSCollectionView alloc] initWithFrame:NSZeroRect];
    self.collectionView.collectionViewLayout = self.collectionViewLayout;
    
    [self.collectionView registerClass:[MusaicItem class] forItemWithIdentifier:NSStringFromClass([MusaicItem class])];
    
    self.collectionView.wantsLayer = YES;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColors = @[[NSColor colorWithRed:0.11 green:0.11 blue:0.13 alpha:1.00]];
    
    [self addSubview:self.collectionView];
    
    NSRect calculatedBounds = [self calculateFrameRect:self.bounds];
    CGFloat offsetY = (calculatedBounds.size.height - self.bounds.size.height) / 2;
    CGFloat offsetX = (calculatedBounds.size.width - self.bounds.size.width) / 2;
    self.collectionView.frame = NSOffsetRect(calculatedBounds, -offsetX, -offsetY);
    
    [self loadData];
}

- (void)loadData {
    __weak typeof(self) weakSelf = self;
    void (^ done)(NSArray *artworks) = ^void (NSArray *new) {
        
        NSPredicate *removePredicate = [NSPredicate predicateWithFormat:@"artworkUrl.absoluteString.length > 0"];
        NSArray *newItems = [new filteredArrayUsingPredicate:removePredicate];
        
        if (newItems.count == 0) {
            return;
        }
        
        NSInteger maximalCount = [weakSelf maximalCount];
        NSMutableArray *artworks = [NSMutableArray arrayWithCapacity:maximalCount];
        
        while (artworks.count < maximalCount) {
            [artworks addObjectsFromArray:newItems];
        }
        
        NSMutableArray *shuffled = artworks.mutableCopy;
        [shuffled shuffle];
        [shuffled trim:maximalCount];
        
        weakSelf.totalItems = artworks;
        weakSelf.currentItems = shuffled.copy;
        weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)weakSelf.delay
                                                          target:weakSelf selector:@selector(animate) userInfo:nil repeats:YES];
        [weakSelf.collectionView reloadData];
    };
    
    void (^ failure)(NSError *error) = ^void (NSError *error) {
        Preferences *preferences = [Preferences preferences];
        if (preferences.artworks.count) done(preferences.artworks);
    };
    
    switch ([Preferences preferences].mode) {
        case PreferencesModeLastFmUser:
            [self.manager performLastfmWeekly:done andFailure:failure];
            break;
            
        case PreferencesModeTag:
            [self.manager performLastfmTag:done andFailure:failure];
            break;
            
        case PreferencesModeSpotifyUser:
            [self.manager performSpotifyUserAlbums:done andFailure:failure];
            break;
            
        case PreferencesModeSpotifyReleases:
            [self.manager performSpotifyReleases:done andFailure:failure];
            break;
            
        case PreferencesModeSpotifyLikedSongs:
            [self.manager performSpotifyLikedSongs:done andFailure:failure];
            break;
            
        case PreferencesModeSpotifyArtists:
            [self.manager performSpotifyArtists:done andFailure:failure];
            break;
            
        default:
            break;
    }
}

- (void)animate {
    NSMutableArray *current = self.currentItems.mutableCopy;
    NSMutableArray *totalItem = self.totalItems.mutableCopy;
    [totalItem removeObjectsInArray:current];
    if (!totalItem.count) return;
    
    NSInteger currentIndex = SSRandomIntBetween(0, (int)current.count - 1);
    NSInteger totalIndex = SSRandomIntBetween(0, (int)totalItem.count - 1);
    
    Artwork *newArtwork = [totalItem objectAtIndex:totalIndex];
    current[currentIndex] = newArtwork;
    MusaicItem *item = (MusaicItem *)[self.collectionView itemAtIndex:currentIndex];
    [item configureUrl:newArtwork.artworkUrl andType:MusaicAnimationFlip];
    self.currentItems = current.copy;
}

- (CGRect)calculateFrameRect:(NSRect)bounds {
    CGSize totalSize = self.bounds.size;
    CGFloat (^ calculateBlock)(CGFloat size, CGFloat windowSize) = ^CGFloat (CGFloat size, CGFloat windowSize) {
        CGFloat current = 0.0;
        while (current < windowSize)
            current += size;
        return current;
    };
    CGFloat height = calculateBlock(self.collectionViewLayout.itemSize.height, totalSize.height);
    CGFloat width = calculateBlock(self.collectionViewLayout.itemSize.width, totalSize.width);
    return NSMakeRect(0, 0, width, height);
}

- (NSInteger)maximalCount {
    CGSize size = [self calculateFrameRect:self.bounds].size;
    CGSize itemSize = self.collectionViewLayout.itemSize;
    CGFloat count = (size.width * size.height) / (itemSize.width * itemSize.height);
    return (NSInteger)ceilf(count);
}

- (BOOL)hasConfigureSheet {
    return YES;
}

- (NSWindow *)configureSheet {
    NSWindow *window;
    if (!self.prefencesViewController) {
        self.prefencesViewController = [PreferencesViewController new];
        [self.prefencesViewController loadWindow];
        window = self.prefencesViewController.window;
    }
    window.styleMask = NSWindowStyleMaskTitled;
    return self.prefencesViewController.window;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    MusaicItem *item = [collectionView makeItemWithIdentifier:NSStringFromClass([MusaicItem class]) forIndexPath:indexPath];
    Artwork *artwork;
    if (self.currentItems.count > indexPath.item) {
        artwork = self.currentItems[indexPath.item];
    }
    [item configureUrl:artwork.artworkUrl andType:MusaicAnimationFade];
    return item;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self maximalCount];
}


@end
