#import <Preferences/Preferences.h>
#import "UniformityColorSelector.h"

#import "UIColor+Crayola.h"

extern NSString * PSValueKey;

@implementation UIImage (Color)
 
+ (UIImage *)imageWithColor:(UIColor *)color {

    CGRect rect = CGRectMake(0, 0, 29, 29);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;

}
 
@end

@interface PSListController (TableView)

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)indexForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation UniformityColorSelector

- (NSString *)colorSettingKeyName {
    return @"Color";
}

- (PSSpecifier *)defaultColorSpecifier {

    PSSpecifier * specifier = [PSSpecifier preferenceSpecifierNamed:@"Default color"
                                                    target:self
                                                       set:nil
                                                       get:nil
                                                    detail:nil
                                                      cell:PSListItemCell
                                                      edit:nil];

    [specifier setProperty:[NSNull null] forKey:@"color"];
    [specifier setProperty:[self colorSettingKeyName] forKey:@"key"];
    [specifier setProperty:@"com.pNre.uniformity/settingsupdated" forKey:@"PostNotification"];
    [specifier setProperty:@"com.pNre.uniformity" forKey:@"defaults"];

    return specifier;

}

- (PSSpecifier *)customColorSpecifier {

    PSTextFieldSpecifier * specifier = [PSTextFieldSpecifier preferenceSpecifierNamed:nil
                                                    target:self
                                                       set:@selector(setCustomColor:forSpecifier:)
                                                       get:@selector(getCustomColorForSpecifier:)
                                                    detail:nil
                                                      cell:PSEditTextCell
                                                      edit:nil];

    [specifier setPlaceholder:@"RGB hex value (e.g. FFFFFF)"];
    [specifier setProperty:[self colorSettingKeyName] forKey:@"key"];
    [specifier setProperty:@"com.pNre.uniformity/settingsupdated" forKey:@"PostNotification"];
    [specifier setProperty:@"com.pNre.uniformity" forKey:@"defaults"];
    [specifier setProperty:@(YES) forKey:@"noAutoCorrect"];

    return specifier;

}

- (NSString *)getCustomColorForSpecifier:(PSSpecifier *)specifier {

    id preferenceValue = [self readPreferenceValue:specifier];
    UIColor * color = [NSKeyedUnarchiver unarchiveObjectWithData:preferenceValue];

    if (!color || [color isKindOfClass:[NSNull class]])
        return nil;

    const CGFloat * components = CGColorGetComponents(color.CGColor);

    unsigned int R = (unsigned int)(components[0] * 255);
    unsigned int G = (unsigned int)(components[1] * 255);
    unsigned int B = (unsigned int)(components[2] * 255);

    return [NSString stringWithFormat:@"%02X%02X%02X", R, G, B];

}

- (void)setCustomColor:(NSString *)color forSpecifier:(PSSpecifier *)specifier {

    if (!color)
        return;

    color = [color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([color length] != 6)
        return;

    unsigned char R, G, B;
    unsigned int RGB;

    NSScanner * scanner = [NSScanner scannerWithString:color];
    [scanner scanHexInt:&RGB];

    R = (unsigned char)(RGB >> 16);
    G = (unsigned char)(RGB >> 8);
    B = (unsigned char)(RGB);

    UIColor * selectedColor = [UIColor colorWithRed:((CGFloat)R / 255.) green:((CGFloat)G / 255.) blue:((CGFloat)B / 255.) alpha:1.];
    NSData * archivedColor = [NSKeyedArchiver archivedDataWithRootObject:selectedColor];
    
    [self setPreferenceValue:archivedColor specifier:specifier];

}

- (PSSpecifier *)groupCellSpecifierWithTitle:(NSString *)title {

    PSSpecifier * specifier = [PSSpecifier preferenceSpecifierNamed:title
                                                    target:self
                                                       set:nil
                                                       get:nil
                                                    detail:nil
                                                      cell:PSGroupCell
                                                      edit:nil];

    return specifier;

}

- (id)specifiers {
    if (!_specifiers) {

        _specifiers = [[NSMutableArray alloc] initWithObjects:
            [self groupCellSpecifierWithTitle:@"Custom color"],
            [self customColorSpecifier], 
            [self groupCellSpecifierWithTitle:@"Presets"],
            [self defaultColorSpecifier], 
            nil];
        
        NSDictionary * crayola = [UIColor crayolaColors];
        NSArray * sortedColors = [[crayola allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

        //[[UIColor crayolaColors] enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL * stop) {

        for (NSString * key in sortedColors) {

            id obj = [crayola objectForKey:key];

            PSSpecifier * specifier = [PSSpecifier preferenceSpecifierNamed:key
                                                            target:self
                                                               set:nil
                                                               get:nil
                                                            detail:nil
                                                              cell:PSListItemCell
                                                              edit:nil];

            [specifier setProperty:[UIImage imageWithColor:obj] forKey:@"iconImage"];
            [specifier setProperty:obj forKey:@"color"];
            [specifier setProperty:[self colorSettingKeyName] forKey:@"key"];
            [specifier setProperty:@"com.pNre.uniformity/settingsupdated" forKey:@"PostNotification"];
            [specifier setProperty:@"com.pNre.uniformity" forKey:@"defaults"];

            [(NSMutableArray *)_specifiers addObject:specifier];

        }
        //}];

    }

    return _specifiers;
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    PSSpecifier * cellSpecifier = [self specifierAtIndex:[self indexForIndexPath:indexPath]];

    id preferenceValue = [self readPreferenceValue:cellSpecifier];
    UIColor * color = [NSKeyedUnarchiver unarchiveObjectWithData:preferenceValue];

    BOOL checked = [[cellSpecifier propertyForKey:@"color"] isEqual:color];
    [(PSTableCell *)cell setChecked:checked];

    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        
    PSSpecifier * specifier = [self specifierAtIndex:[self indexForIndexPath:indexPath]];

    UIColor * color = [specifier propertyForKey:@"color"];
    NSData * archivedColor = [NSKeyedArchiver archivedDataWithRootObject:color];
    
    [self setPreferenceValue:archivedColor specifier:specifier];

    [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];

}

@end
