//
//  MusaicItem.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

@import QuartzCore;

#import "MusaicItem.h"
#import <SDWebImage/SDWebImageManager.h>

@interface MusaicItem ()

@end

@implementation MusaicItem

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[MusaicItem class]]];
}

- (instancetype)init {
    return [super init];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.view.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.imageView.image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"placeholder" ofType:@"png"]];
}

- (void)configureUrl:(NSURL *)url andType:(MusaicAnimation)type {
    __weak typeof(self) weakSelf = self;

    void (^ completion)(NSImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) = ^void (NSImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!image) return;

        weakSelf.imageView.image = image;
        if (type == MusaicAnimationNone) {
            return;
        }
        CATransition *transition = [CATransition new];
        transition.type = type == MusaicAnimationFlip ? @"flip" : kCATransitionFade;
        transition.subtype = kCATransitionFromRight;
        transition.duration = type == MusaicAnimationFlip ? 0.75 : 0.3;
        [weakSelf.imageView.layer addAnimation:transition forKey:nil];
    };

    [[SDWebImageManager sharedManager] loadImageWithURL:url options:0 progress:nil completed:completion];
}
@end
