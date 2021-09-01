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
#import "MusaicFMView.h"
#import "NSBundle+Bundle.h"

@interface PreferencesViewController () <WKNavigationDelegate, NSTextFieldDelegate>

@property (nonatomic, readwrite, weak) IBOutlet NSButton* doneButton;
@property (nonatomic, readwrite, weak) IBOutlet NSSlider* rowSlider;
@property (nonatomic, readwrite, weak) IBOutlet NSSlider* delaySlider;

@property (nonatomic, readwrite, weak) IBOutlet NSTextField* titleLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField* descriptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField* rowLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField* delayLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField* delayDescriptionLabel;

@property (nonatomic, readwrite, weak) IBOutlet NSTextField* lastFmUserTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField* lastFmTagTextField;

@property (nonatomic, readwrite, weak) IBOutlet NSTextField* lastFMPeriodLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSButton* lastfmPlayedAlbumsRadio;
@property (nonatomic, readwrite, weak) IBOutlet NSButton* lastFmTagRadio;
@property (nonatomic, readwrite, weak) IBOutlet NSButton* spotifyPlayedAlbumsRadio;
@property (nonatomic, readwrite, weak) IBOutlet NSButton* spotifyNewRadio;
@property (nonatomic, readwrite, weak) IBOutlet NSButton* spotifyFavoriteSongsRadio;
@property (nonatomic, readwrite, weak) IBOutlet NSButton* spotifySignIn;

@property (nonatomic, readwrite, weak) IBOutlet NSPopUpButton* lastFmWeeklyButton;
@property (nonatomic, readwrite, weak) IBOutlet WKWebView* webView;
@property (nonatomic, readwrite, weak) IBOutlet NSView* contentView;
@property (nonatomic, readwrite, weak) IBOutlet NSView* containerView;

@property (nonatomic, readwrite, weak) IBOutlet MusaicFMView* previewView;
@property (nonatomic, readwrite, strong) Manager* manager;
@property (nonatomic, readwrite, strong) Preferences* preferences;

@end

@implementation PreferencesViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configure];
}

- (void)configure
{
    self.manager = [Manager new];
    self.preferences = [Preferences preferences];
    self.webView.hidden = YES;
    self.contentView.hidden = NO;
    self.containerView.wantsLayer = YES;

    self.lastFmTagTextField.delegate = self;
    self.lastFmUserTextField.delegate = self;

    self.previewView.layer.cornerRadius = 8;

    [self.lastFmWeeklyButton addItemsWithTitles:@[ [NSBundle localizedString:@"lastfm_fetch_period_overall"],
                                                   [NSBundle localizedString:@"lastfm_fetch_period_seven_days"],
                                                   [NSBundle localizedString:@"lastfm_fetch_period_one_month"],
                                                   [NSBundle localizedString:@"lastfm_fetch_period_three_month"],
                                                   [NSBundle localizedString:@"lastfm_fetch_period_six_month"],
                                                   [NSBundle localizedString:@"lastfm_fetch_period_one_year"]]];

    [self updateView];
}

- (void)updateView
{

    NSButton* radioButton = self.radioButtons[self.preferences.mode];
    for (NSButton* button in self.radioButtons) {
        button.state = button == radioButton ? NSOnState : NSOffState;
    }

    for (NSButton* button in @[ self.spotifyPlayedAlbumsRadio, self.spotifyNewRadio, self.spotifyFavoriteSongsRadio ]) {
        button.enabled = self.preferences.spotifyToken.length;
    }

    self.rowSlider.integerValue = self.preferences.rows;
    self.delaySlider.integerValue = self.preferences.delays;
    self.lastFmUserTextField.stringValue = self.preferences.lastfmUser;
    self.lastFmTagTextField.stringValue = self.preferences.lastfmTag;

    self.titleLabel.stringValue = [NSBundle localizedString:@"app_title"];
    self.descriptionLabel.stringValue = [NSBundle localizedString:@"app_title_description"];
    self.rowLabel.stringValue = [NSBundle localizedString:@"rows"];

    self.delayLabel.stringValue = [NSBundle localizedString:@"delay"];

    self.spotifySignIn.title = self.preferences.spotifyToken.length
        ? [NSBundle localizedString:@"spotify_sign_out"]
        : [NSBundle localizedString:@"spotify_sign_in"];

    self.spotifyNewRadio.title = [NSBundle localizedString:@"spotify_new_releases"];
    self.spotifyFavoriteSongsRadio.title = [NSBundle localizedString:@"spotify_liked_songs"];
    self.spotifyPlayedAlbumsRadio.title = [NSBundle localizedString:@"spotify_albums"];
    self.lastFMPeriodLabel.stringValue = [NSBundle localizedString:@"lastfm_fetch_period_overall_title"];
    self.lastFmTagRadio.title = [NSBundle localizedString:@"lastfm_tags"];
    self.lastfmPlayedAlbumsRadio.title = [NSBundle localizedString:@"lastfm_user_albums"];
    self.delayDescriptionLabel.stringValue = [NSString stringWithFormat:[NSBundle localizedString:@"delay_in_seconds"], self.delaySlider.integerValue];
    self.doneButton.title = [NSBundle localizedString:@"okay"];
    [self.lastFmWeeklyButton selectItemAtIndex:self.preferences.lastfmWeekly];
}

- (IBAction)loginSpotify:(NSButton*)sender
{
    if (self.preferences.spotifyToken.length) {
        [self.preferences clear];
        [self updateView];
    } else {
        NSURLRequest* request = [NSURLRequest requestWithURL:[Factory spotifyAuthentification].URL];
        [self showLoginFlow:YES];
        [self.webView loadRequest:request];
    }
}

- (void)showLoginFlow:(BOOL)show
{
    self.webView.hidden = !show;
    self.contentView.hidden = show;

    CATransition* transition = [CATransition new];
    transition.type = @"flip";
    transition.subtype = kCATransitionFromRight;
    transition.duration = 0.6;

    [self.containerView.layer addAnimation:transition forKey:nil];
}

- (IBAction)didSelectRadio:(NSButton*)sender
{
    self.preferences.mode = [[self radioButtons] indexOfObject:sender];
    [self updateView];
    [self.previewView fetchData];
}

- (IBAction)didChangeRowSlider:(id)sender
{
    self.preferences.rows = self.rowSlider.integerValue;
    [self.previewView prepareLayout];
    [self updateView];
}

- (IBAction)didChangeDelaySlider:(id)sender
{
    self.preferences.delays = self.delaySlider.integerValue;
    [self updateView];
}

- (IBAction)didSelectLastfmInterfal:(id)sender
{
    self.preferences.lastfmWeekly = self.lastFmWeeklyButton.indexOfSelectedItem;
    [self updateView];
}


- (void)didChangeText
{
    self.preferences.lastfmUser = self.lastFmUserTextField.stringValue;
    self.preferences.lastfmWeekly = self.lastFmWeeklyButton.indexOfSelectedItem;
    self.preferences.lastfmTag = self.lastFmTagTextField.stringValue;
    [self updateView];
}

- (IBAction)dismissViewController:(NSButton*)doneButton
{
    [self.preferences synchronize];
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (void)controlTextDidChange:(NSNotification*)obj
{
    [self didChangeText];
}

- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{

    NSURLComponents* components = [NSURLComponents componentsWithURL:webView.URL resolvingAgainstBaseURL:NO];
    NSURLComponents* callbackComponents = [NSURLComponents componentsWithString:spotifyRedirectUrl];

    if (![components.scheme isEqualToString:callbackComponents.scheme]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    NSPredicate* filter = [NSPredicate predicateWithFormat:@"name == %@", @"code"];
    NSString* code = [[components.queryItems filteredArrayUsingPredicate:filter].firstObject value];
    typeof(self) weakSelf = self;

    dispatch_block_t dismiss = ^{
        [weakSelf updateView];
        [weakSelf showLoginFlow:NO];
        decisionHandler(WKNavigationActionPolicyCancel);
    };
    if (!code.length) {
        dismiss();
        return;
    }
    [self.manager performSpotifyToken:code
                    completionHandler:dismiss
                           andFailure:^(NSError* error) {
                               dismiss();
                           }];
}

- (NSString*)windowNibName
{
    return @"PreferencesViewController";
}

- (NSArray*)radioButtons
{
    return @[ self.lastfmPlayedAlbumsRadio, self.lastFmTagRadio, self.spotifyPlayedAlbumsRadio,
        self.spotifyNewRadio, self.spotifyFavoriteSongsRadio];
}

@end
