//
//  MusaicItem.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

@import QuartzCore;
#import <SDWebImage/SDWebImage.h>
#import "MusaicItem.h"
#import "NSBundle+Bundle.h"

@interface MusaicItem ()

@end

@implementation MusaicItem

- (instancetype)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    return [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[MusaicItem class]]];
}

- (instancetype)init
{
    return [super init];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.view.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.imageView.image = self.imageView.image = [[NSBundle current] imageForResource:@"placeholder"];
}
@end
