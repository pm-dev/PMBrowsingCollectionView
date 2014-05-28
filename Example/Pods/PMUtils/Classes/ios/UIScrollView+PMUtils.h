//
//  UIScrollView+PMUtils.h
//  Pods
//
//  Created by Peter Meyers on 3/25/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PMScrollDirection) {
    PMScrollDirectionNone,
    PMScrollDirectionPositive,
    PMScrollDirectionNegative
};

@interface UIScrollView (PMUtils)

/**
 *  If the scroll view is currently animating a scroll, this method will stop the scroll at the current contentOffset.
 */
- (void) killScroll;

@end
