//
//  MusaicItem.h
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM (NSUInteger, MusaicAnimation) {
    MusaicAnimationNone = 0,
    MusaicAnimationFade = 1,
    MusaicAnimationFlip = 2,
};

@interface MusaicItem : NSCollectionViewItem

@end
