#import <Preferences/Preferences.h>

@interface UniformityColorSelector : PSListController <UITableViewDelegate> {
}

- (NSString *)colorSettingKeyName;
- (NSString *)defaultColorName;

@end

