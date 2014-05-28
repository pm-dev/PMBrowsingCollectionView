//
//  UICollectionViewFlowLayout+PMUtils.m
//  Pods
//
//  Created by Peter Meyers on 4/9/14.
//
//

#import "UICollectionViewFlowLayout+PMUtils.h"

@implementation UICollectionViewFlowLayout (PMUtils)

- (BOOL) requiresScrollAnimationToIndexPath:(NSIndexPath *)indexPath atPosition:(UICollectionViewScrollPosition)scrollPosition
{
    NSParameterAssert(indexPath);
    
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    CGPoint itemOrigin = attributes.frame.origin;
    CGPoint contentOffset = self.collectionView.contentOffset;
    CGSize collectionViewBoundsSize = self.collectionView.bounds.size;
    CGPoint targetOffset = itemOrigin;
    
    switch (self.scrollDirection)
    {
        case UICollectionViewScrollDirectionHorizontal:
        {
            if (scrollPosition & UICollectionViewScrollPositionCenteredHorizontally) {
                
                targetOffset.x += collectionViewBoundsSize.width/2.0f;
            }
            else if (scrollPosition & UICollectionViewScrollPositionRight) {
                
                targetOffset.x += collectionViewBoundsSize.width - attributes.frame.size.width;
            }
            
            CGFloat maxOffset = self.collectionViewContentSize.width - collectionViewBoundsSize.width;
            CGFloat scrollDelta = targetOffset.x - contentOffset.x;
            
            BOOL endOfScroll = ((scrollDelta > 0.0f && contentOffset.x == maxOffset) ||
                                (scrollDelta < 0.0f && contentOffset.x == 0.0f));
            
            return (scrollDelta != 0.0f && !endOfScroll);
        }
            
        case UICollectionViewScrollDirectionVertical:
        {
            if (scrollPosition & UICollectionViewScrollPositionCenteredVertically) {
                
                targetOffset.y -= (collectionViewBoundsSize.height - attributes.frame.size.height)/2.0f;
            }
            else if (scrollPosition & UICollectionViewScrollPositionBottom) {
                
                targetOffset.y -= (collectionViewBoundsSize.height - attributes.frame.size.height);
            }
            
            CGFloat maxOffset = self.collectionViewContentSize.height - collectionViewBoundsSize.height;
            CGFloat scrollDelta = targetOffset.y - contentOffset.y;
            
            BOOL endOfScroll = ((scrollDelta > 0.0f && contentOffset.y == maxOffset) ||
                                (scrollDelta < 0.0f && contentOffset.y == 0.0f));
            
            return (scrollDelta != 0.0f && !endOfScroll);
        }
    }
}


@end
