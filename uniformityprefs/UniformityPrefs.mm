#import <Preferences/Preferences.h>

@interface UniformityPrefsListController: PSListController {
}
@end

@implementation UniformityPrefsListController

- (id)specifiers {
	if (!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"Uniformity" target:self] retain];

	return _specifiers;
}

@end

