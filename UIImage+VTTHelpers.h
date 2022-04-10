#import "UIImage+VTTHelpers.h"

@interface UIImage (VTTHelpers)
// Return linear gradient UIImage from colours Array
- (UIImage *)tintedWithLinearGradientColors: (NSArray *)colorsArr;
- (UIImage *) antialiasImageInRect: (CGRect) rect;
+ (UIImage *)imageWithColor:(UIColor *)color
               cornerRadius:(CGFloat)cornerRadius;
@end