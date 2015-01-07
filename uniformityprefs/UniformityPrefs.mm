#import <Preferences/Preferences.h>
#import "UniformityPrefs.h"

@implementation UniformityPrefsListController {
    BOOL _settingsChanged;
}

- (id)specifiers {
	if (!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"Uniformity" target:self] retain];

	return _specifiers;
}

- (void)twitter {

    NSString * _user = @"_pNre";

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:_user]]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:_user]]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:_user]]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:_user]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:_user]]];
    }
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {

    [super setPreferenceValue:value specifier:spec];

	if (!_settingsChanged) {
		_settingsChanged = YES;

        UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStyleDone target:self action:@selector(respring:)];
        [[self navigationItem] setRightBarButtonItem:respringButton];
        [respringButton release];
	}
}

- (void)respring:(id)sender {

    setuid(0);
    system("killall SpringBoard");

}

@end
