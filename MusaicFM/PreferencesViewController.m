//
//  Preferences.m
//  MusaicFM
//
//  Created by Dennis Oberhoff on 13/11/2016.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

@import ScreenSaver;
@import WebKit;
@import QuartzCore;

#import "PreferencesViewController.h"
#import "Preferences.h"
#import "Constants.h"
#import "Manager.h"
#import "Constants.h"
#import "Factory.h"

@interface PreferencesViewController () <WebFrameLoadDelegate, WebPolicyDelegate>

@property (nonatomic, readwrite, weak) IBOutlet NSButton *doneButton;
@property (nonatomic, readwrite, weak) IBOutlet NSPopUpButton *rowButton;
@property (nonatomic, readwrite, weak) IBOutlet NSPopUpButton *delayButton;

@property (nonatomic, readwrite, weak) IBOutlet NSTextField *lastFmUserTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *lastFmTagTextField;

@property (nonatomic, readwrite, weak) IBOutlet NSButton *lastFmUserRadio;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *lastFmTagRadio;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *spotifyUserRadio;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *spotifyNewRadio;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *spotifySignIn;

@property (nonatomic, readwrite, weak) IBOutlet NSPopUpButton *lastFmWeeklyButton;

@property (nonatomic, readwrite, weak) IBOutlet WebView *webView;
@property (nonatomic, readwrite, weak) IBOutlet NSView *settingsView;
@property (nonatomic, readwrite, weak) IBOutlet NSView *containerView;

@property (nonatomic, readwrite, strong) Manager *manager;

@end

@implementation PreferencesViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.manager = [Manager new];
    self.containerView.wantsLayer = YES;
    self.containerView.layer.backgroundColor = [NSColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.00].CGColor;
    [self configure];

    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieJar.cookies) [cookieJar deleteCookie:cookie];
}

- (void)configure {
    Preferences *preferences = [Preferences preferences];

    self.webView.hidden = YES;
    self.settingsView.hidden = NO;

    [self.rowButton addItemsWithTitles:@[@"2", @"3", @"4", @"5", @"6", @"7", @"8"]];
    [self.delayButton addItemsWithTitles:@[@"2", @"3", @"4", @"5", @"6", @"7", @"8"]];
    [self.lastFmWeeklyButton addItemsWithTitles:@[@"Overall", @"7 Days", @"1 Month", @"3 Month", @"6 Month", @"12 Month"]];

    self.rowButton.autoenablesItems = YES;
    self.delayButton.autoenablesItems = YES;

    [self.rowButton selectItemWithTitle:@(preferences.rows).stringValue];
    [self.delayButton selectItemWithTitle:@(preferences.delays).stringValue];
    [self.lastFmWeeklyButton selectItemAtIndex:preferences.lastfmWeekly];

    NSButton *radioButton = [self radioButtons][preferences.mode];
    radioButton.state = NSOnState;

    self.lastFmUserTextField.stringValue = preferences.lastfmUser ? preferences.lastfmUser : @"";
    self.lastFmTagTextField.stringValue = preferences.lastfmTag ? preferences.lastfmTag : @"";

    self.spotifyNewRadio.enabled = preferences.spotifyToken.length;
    self.spotifyUserRadio.enabled = preferences.spotifyToken.length;
    self.spotifySignIn.title = preferences.spotifyToken.length ? @"Sign out" : @"Sign In";
}

- (NSArray *)radioButtons {
    return @[self.lastFmUserRadio, self.lastFmTagRadio, self.spotifyUserRadio, self.spotifyNewRadio];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.styleMask = NSWindowStyleMaskTitled;
}

- (IBAction)didSelectRadio:(NSButton *)sender {
    NSMutableArray *buttons = self.radioButtons.mutableCopy;
    [buttons removeObject:sender];
    for (NSButton *button in buttons) {
        button.state = NSOffState;
    }
}

- (IBAction)loginSpotify:(NSButton *)sender {
    Preferences *preferences = [Preferences preferences];
    if (preferences.spotifyToken.length) {
        preferences.spotifyToken = nil;
        preferences.spotifyRefresh = nil;
        preferences.spotifyCode = nil;
        [preferences synchronize];
        [self configure];
    }
    else {
        self.webView.hidden = NO;
        self.settingsView.hidden = YES;
        [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[Factory spotifyAuthentification].URL]];
    }
}

- (IBAction)dismissViewController:(NSButton *)doneButton {
    [self.lastFmUserTextField resignFirstResponder];

    Preferences *preference = [Preferences preferences];
    preference.rows = self.rowButton.indexOfSelectedItem + 2;
    preference.delays = self.delayButton.indexOfSelectedItem + 2;
    preference.lastfmUser = self.lastFmUserTextField.stringValue;
    preference.lastfmWeekly = self.lastFmWeeklyButton.indexOfSelectedItem;
    preference.lastfmTag = self.lastFmTagTextField.stringValue;

    NSPredicate *radioFilter = [NSPredicate predicateWithFormat:@"state == %i", NSOnState];
    NSButton *radioButton = [[self radioButtons] filteredArrayUsingPredicate:radioFilter].firstObject;
    if (radioButton) {
        preference.mode = [[self radioButtons] indexOfObject:radioButton];
    }

    [preference clear];
    [preference synchronize];

    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (NSString *)windowNibName {
    return @"PreferencesViewController";
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request
          frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
    NSURLComponents *callbackComponents = [NSURLComponents componentsWithString:spotifyRedirectUrl];

    if (![components.scheme isEqualToString:callbackComponents.scheme]) {
        [listener use];
        return;
    }

    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name == %@", @"code"];
    NSString *code = [[components.queryItems filteredArrayUsingPredicate:filter].firstObject value];
    typeof(self) weakSelf = self;
    dispatch_block_t dismiss = ^{
        [weakSelf configure];
    };
    if (!code.length) {
        dismiss();
        return;
    }
    [self.manager performSpotifyToken:code completionHandler:dismiss andFailure:^(NSError *error) {
        dismiss();
    }];
}


@end
