//
//  NSBundle+Bundle.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 03.10.20.
//  Copyright © 2020 Dennis Oberhoff. All rights reserved.
//

#import "NSBundle+Bundle.h"

@interface DummyClass : NSObject
@end

@implementation DummyClass
@end

@implementation NSBundle (Bundle)

+(NSBundle*)current {
   return [NSBundle bundleForClass:[DummyClass class]];
}

+(NSString*)localizedString:(NSString*)key {
    return [[NSBundle current] localizedStringForKey:key value:@"" table:@""];
}

@end
