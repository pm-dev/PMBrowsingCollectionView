//
//  UIScrollView+PMUtils.m
//  Pods
//
//  Created by Peter Meyers on 3/25/14.
//
//

#import "UIScrollView+PMUtils.h"

@implementation UIScrollView (PMUtils)

- (void) killScroll
{
    CGPoint offset = self.contentOffset;
    [self setContentOffset:CGPointZero animated:NO];
    [self setContentOffset:offset animated:NO];
}

@end
