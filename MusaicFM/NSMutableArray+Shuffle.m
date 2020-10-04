//
//  NSMutableArray+Shuffle.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"

@implementation NSMutableArray (Shuffle)

- (void)trim:(NSInteger)maximalItems
{
    if (self.count < maximalItems) {
        return;
    }
    [self removeObjectsInRange:NSMakeRange(maximalItems, self.count - maximalItems)];
}

- (void)shuffle
{
    NSUInteger count = [self count];
    if (count < 1)
        return;

    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end
