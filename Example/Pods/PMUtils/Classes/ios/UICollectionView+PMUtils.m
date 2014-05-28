//
//  UICollectionView+PMUtils.m
//  
//
//  Created by Peter Meyers on 3/21/14.
//
//

#import "UICollectionView+PMUtils.h"

static inline CGFloat PMSquaredDistanceFromRectToPoint(CGRect rect, CGPoint point)
{
    CGPoint closestPoint = rect.origin;
    
    if (point.x > CGRectGetMaxX(rect)) {
        closestPoint.x += rect.size.width;
    }
    else if (point.x > CGRectGetMinX(rect)) {
        closestPoint.x = point.x;
    }
    
    if (point.y > CGRectGetMaxY(rect)) {
        closestPoint.y += rect.size.height;
    }
    else if (point.y > CGRectGetMinY(rect)) {
        closestPoint.y = point.y;
    }
    
    CGFloat dx = point.x - closestPoint.x;
    CGFloat dy = point.y - closestPoint.y;
    
    return dx*dx + dy*dy;
}

@implementation UICollectionView (PMUtils)

- (NSIndexPath *) visibleIndexPathNearestToPoint:(CGPoint)point
{
    NSIndexPath *nearestIndexPath = nil;
    CGFloat closestDistance = MAXFLOAT;
    
    for (NSIndexPath *indexPath in self.indexPathsForVisibleItems) {
        
        CGFloat distance = [self _squaredDistanceFromItemAtIndexPath:indexPath toPoint:point];
        
        if (distance < closestDistance) {
            closestDistance = distance;
            nearestIndexPath = indexPath;
        }
    }
    NSParameterAssert(nearestIndexPath);
    return nearestIndexPath;
}

- (NSIndexPath *) indexPathNearestToPoint:(CGPoint)point
{
    NSIndexPath *nearestIndexPath = nil;
    CGFloat closestDistance = MAXFLOAT;
    
    NSInteger sections = [self numberOfSections];
    
    for (NSInteger section = 0; section < sections; section++) {

        NSInteger items = [self numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < items; item++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            CGFloat distance = [self _squaredDistanceFromItemAtIndexPath:indexPath toPoint:point];
            
            if (distance < closestDistance) {
                closestDistance = distance;
                nearestIndexPath = indexPath;
            }
        }
    }
    NSParameterAssert(nearestIndexPath);
    return nearestIndexPath;
}

- (CGPoint) contentOffsetForCenteredRect:(CGRect)rect
{
    CGFloat offsetX = rect.origin.x - (self.bounds.size.width - rect.size.width) / 2.0f;
    CGFloat offsetY = rect.origin.y - (self.bounds.size.height - rect.size.height) / 2.0f;
    return CGPointMake(offsetX, offsetY);
}


- (CGPoint) contentOffsetInBoundsCenter
{
    CGPoint middlePoint = self.contentOffset;
    middlePoint.x += self.bounds.size.width / 2.0f;
    middlePoint.y += self.bounds.size.height / 2.0f;
    return middlePoint;
}

#pragma mark - Private Methods

- (CGFloat) _squaredDistanceFromItemAtIndexPath:(NSIndexPath *)indexPath toPoint:(CGPoint)point
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frame = attributes.frame;
    
    if (CGRectContainsPoint(frame, point)) {
        return 0.0f;
    }
    
    return PMSquaredDistanceFromRectToPoint(frame, point);
}

@end
