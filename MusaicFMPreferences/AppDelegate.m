//
//  AppDelegate.m
//  MusaicFMPreferences
//
//  Created by Dennis Oberhoff on 14/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, readwrite, strong) PreferencesViewController *preferences;


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.preferences = [PreferencesViewController new];
    [self.preferences loadWindow];

    NSWindow *window = self.preferences.window;
    window.styleMask = NSWindowStyleMaskTitled;
    
    [self.window makeKeyAndOrderFront:self];
    [self.window beginSheet:window completionHandler:nil];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
