#import "UIImage+Colorize.h"

@implementation UIImage (MaskedImage)
 
//  Adapted from: https://gist.github.com/omz/1102091
- (UIImage *)imageMaskedWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [self drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    return result;
}
 
@end
