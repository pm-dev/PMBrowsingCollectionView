//
//  PMCenteredCollectionViewFlowLayout.m
//  Pods
//
//  Created by Peter Meyers on 3/25/14.
//
//

#import "PMCenteredCollectionViewFlowLayout.h"
#import "PMUtils.h"

@implementation PMCenteredCollectionViewFlowLayout


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    BOOL targetFirstIndexPath = CGPointEqualToPoint(proposedContentOffset, CGPointZero);
    BOOL targetLastIndexPath = (proposedContentOffset.x == self.collectionViewContentSize.width - self.collectionView.bounds.size.width &&
                                proposedContentOffset.y == self.collectionViewContentSize.height - self.collectionView.bounds.size.height);

    if ( !targetFirstIndexPath && !targetLastIndexPath) {

        proposedContentOffset.x += self.collectionView.bounds.size.width / 2.0f;
        proposedContentOffset.y += self.collectionView.bounds.size.height / 2.0f;

        NSIndexPath *targetedIndexPath = [self.collectionView indexPathNearestToPoint:proposedContentOffset];

        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:targetedIndexPath];

        proposedContentOffset = [self.collectionView contentOffsetForCenteredRect:attributes.frame];

    }

    return proposedContentOffset;
}

@end
