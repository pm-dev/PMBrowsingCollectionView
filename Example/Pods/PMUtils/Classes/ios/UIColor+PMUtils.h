//
//  UIColor+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/2/14.
//
//

#import <UIKit/UIKit.h>

#define RGB(value) value/255.0f

@interface UIColor (PMUtils)

+ (UIColor*)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

- (CGFloat) alpha;

@end
