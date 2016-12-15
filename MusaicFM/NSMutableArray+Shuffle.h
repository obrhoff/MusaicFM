//
//  NSMutableArray+Shuffle.h
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Shuffle)

- (void)trim:(NSInteger)maximalItems;
- (void)shuffle;

@end
