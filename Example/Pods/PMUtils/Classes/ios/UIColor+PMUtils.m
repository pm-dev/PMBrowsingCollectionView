//
//  UIColor+PMUtils.m
//  
//
//  Created by Peter Meyers on 3/2/14.
//
//

#import "UIColor+PMUtils.h"

@implementation UIColor (PMUtils)

+ (UIColor*)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	unsigned int colors;
	
	if ([scanner scanHexInt:&colors])
	{
		unsigned int red = (colors >> 16) & 0x00FF;
		unsigned int green = (colors >> 8) & 0x00FF;
		unsigned int blue = colors & 0x00FF;
		
		return [UIColor colorWithRed:RGB(red) green:RGB(green) blue:RGB(blue) alpha:alpha];
	}
	
	return [UIColor colorWithWhite:0.0f alpha:alpha];
}

- (CGFloat) alpha
{
    CGFloat alpha = 0.0f;
    [self getRed:NULL green:NULL blue:NULL alpha:&alpha];
    return alpha;
}

@end
