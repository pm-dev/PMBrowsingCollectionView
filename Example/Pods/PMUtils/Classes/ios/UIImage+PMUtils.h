//
//  UIImage+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import <UIKit/UIKit.h>
#import "UIView+PMUtils.h"

@interface UIImage (PMUtils)


/**
 *  Creates and returns a new resizable image with one point of flex horizontally and/or vertically. The remaining pixels will be apart of the end caps. If the images have an even width or height, the end caps will be one pixel smaller on the right and bottom, respectively. The original image remains untouched. During scaling or resizing, the middle pixel is tiled, left-to-right and top-to-bottom. This method is most useful for creating variable width buttons, whose center region grows or shrinks as needed.
 *
 *  @param direction A mask of the directions to make the image resizable in.
 *
 *  @return A new image object resizable in the specified direction.
 */
- (UIImage *) makeResizable:(PMDirection)direction;

/**
 *  Draws the entire image in a graphics context, respecting the image's orientation setting, and returns the result. This method can be called from any thread. In the default coordinate system, images are situated down and to the right of the specified point. This method draws the image at full opacity using the kCGBlendModeNormal blend mode.
 *
 *  @return An image object rendered into an offscreen graphics context.
 */
- (UIImage *) drawnImage;

/**
 *  Creates and returns an image object by loading the image data from the file at the specified path. This differs from +imageWithContentsOfFile: in that the underlying CGImage is cached in decoded form.
 *
 *  @param path The full path to the file.
 *
 *  @return A new image object for the specified file, or nil if the method could not initialize the image from the specified file.
 */
+ (UIImage *) cachedImageWithFile:(NSString *)path;

/**
 *  Creates a UIImage object with the specified image data. This differs from +imageWithData: in that the underlying CGImage is cached in decoded form.
 *
 *  @param The image data. This can be data from a file or data you create programmatically. 
 *
 *  @return A new image object for the specified data, or nil if the method could not initialize the image from the specified data.
 */
+ (UIImage *) cachedImageWithData:(NSData *)data;

/**
 *  Apply scale, blur, tint and/or saturation to the UIImage or a cropped portion of the UIImage. Important: The image must not have a size of CGSizeZero.
 *
 *  @param radius          Radius of the blur.
 *  @param iterations      How many times to apply the blur algorithm.
 *  @param scaleDownFactor Factor by which to scale down the image. If bluring the image, also scaling down the image will reduce time spent blurring.
 *  @param saturation      Amount of saturation to apply to the image. Normal saturation is 1. A saturation of 0 results in black and white.
 *  @param tintColor       Tint to apply to the image. [UIColor clearColor] or nil for no tint. Apply an alpha to the tint color to reduce the effect.
 *  @param crop            The rect in the image's bounds to apply the effects to. The returned image's size will be the same as this rect. You may pass in CGRectZero if you want to apply the effects to the entire image.
 *
 *  @see -[UIView blurredViewWithRadius:iterations:scaleDownFactor:saturation:tintColor:crop:]
 *  @return A new UIImage with the specified image effects.
 */
- (UIImage *)blurredImageWithRadius:(CGFloat)radius
						 iterations:(NSUInteger)iterations
					scaleDownFactor:(NSUInteger)scaleDownFactor
						 saturation:(CGFloat)saturation
						  tintColor:(UIColor *)tintColor
							   crop:(CGRect)crop;
@end
