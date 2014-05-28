//
//  UICollectionView+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/21/14.
//
//

#import <UIKit/UIKit.h>

@interface UICollectionView (PMUtils)

- (NSIndexPath *) visibleIndexPathNearestToPoint:(CGPoint)point;

// Less efficient than -visibleIndexPathNearestToPoint:
- (NSIndexPath *) indexPathNearestToPoint:(CGPoint)point;

- (CGPoint) contentOffsetForCenteredRect:(CGRect)rect;

- (CGPoint) contentOffsetInBoundsCenter;

@end
