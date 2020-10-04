//
//  NSBundle+Bundle.h
//  MusaicFM
//
//  Created by Dennis Oberhoff on 03.10.20.
//  Copyright © 2020 Dennis Oberhoff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Bundle)

+(NSBundle*)current;
+(NSString*)localizedString:(NSString*)key;

@end
