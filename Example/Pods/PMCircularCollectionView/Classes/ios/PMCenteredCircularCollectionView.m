//
//  PMCenteredCircularCollectionView.m
//  Pods
//
//  Created by Peter Meyers on 3/23/14.
//
//

#import "PMCenteredCircularCollectionView.h"
#import "PMUtils.h"

@implementation PMCenteredCircularCollectionView
{
    __weak id<PMCenteredCircularCollectionViewDelegate> _originalDelegate;
    BOOL _delegateRespondsToDidCenterItemAtIndex;
    BOOL _delegateRespondsToDidSelectItemAtIndexPath;
    BOOL _delegateRespondsToScrollViewDidEndDecelerating;
}

+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(PMCenteredCollectionViewFlowLayout *)layout
{
    return [[self alloc] initWithFrame:frame collectionViewLayout:layout];
}

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(PMCenteredCollectionViewFlowLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {

    }
    return self;
}

- (void) layoutSubviews
{
	CGSize previousContentSize = self.contentSize;
	NSIndexPath *indexPathAtMiddle = [self _indexPathAtMiddle];
	
	[super layoutSubviews];
	
	if (!CGSizeEqualToSize(previousContentSize, self.contentSize)) {
		if (!indexPathAtMiddle) {
			indexPathAtMiddle = [self _indexPathAtMiddle];
		}
		[self _centerIndexPath:indexPathAtMiddle animated:NO notifyDelegate:CGSizeEqualToSize(previousContentSize, CGSizeZero)];
	}
}

- (void) setFrame:(CGRect)frame
{
	CGRect previousFrame = self.frame;
	NSIndexPath *indexPathAtMiddle = [self _indexPathAtMiddle];
	
	[super setFrame:frame];
	
	if (indexPathAtMiddle && !CGRectEqualToRect(previousFrame, self.frame)) {
		[self _centerIndexPath:indexPathAtMiddle animated:NO notifyDelegate:NO];
	}
}


#pragma mark - Accessors


- (void) setDelegate:(id<PMCenteredCircularCollectionViewDelegate>)delegate
{
    [super setDelegate:delegate];
    _originalDelegate = delegate;
    _delegateRespondsToScrollViewDidEndDecelerating = [delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)];
    _delegateRespondsToDidSelectItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)];
    _delegateRespondsToDidCenterItemAtIndex = [delegate respondsToSelector:@selector(collectionView:didCenterItemAtIndex:)];
}


#pragma mark - Public Methods


- (void) centerCell:(UICollectionViewCell *)cell animated:(BOOL)animated;
{
    if ([self circularActive]) {
        NSIndexPath *indexPath = [self indexPathForCell:cell];
        [self centerCellAtIndex:indexPath.item animated:animated];
    }
}

- (void) centerCellAtIndex:(NSUInteger)index animated:(BOOL)animated
{	
    if ([self circularActive] && index < self.itemCount) {
			
		if (CGSizeEqualToSize(CGSizeZero, self.contentSize)) {
		
			[self layoutSubviews];
		}
		
		NSIndexPath *indexPathAtMiddle = [self _indexPathAtMiddle];
		
		if (indexPathAtMiddle) {
			
			NSInteger originalIndexOfMiddle = indexPathAtMiddle.item % self.itemCount;
			
			NSRange range = NSMakeRange(0, self.itemCount);

			NSInteger delta = PMShortestCircularDistance(originalIndexOfMiddle, index, range);
			
			NSInteger toItem = indexPathAtMiddle.item + delta;
			
			NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toItem inSection:0];
			
			[self _centerIndexPath:toIndexPath animated:animated notifyDelegate:YES];
		}
	}
}


#pragma mark - UIScrollViewDelegate Methods


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *indexPath = [self _indexPathAtMiddle];
    [self _centerIndexPath:indexPath animated:YES notifyDelegate:YES];

    if (_delegateRespondsToScrollViewDidEndDecelerating) {
        [_originalDelegate scrollViewDidEndDecelerating:scrollView];
    }
}


#pragma mark - UICollectionViewDelegate Methods


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self _centerIndexPath:indexPath animated:YES notifyDelegate:YES];
    
    if (_delegateRespondsToDidSelectItemAtIndexPath) {
        [_originalDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}


#pragma mark - Private Methods


- (NSIndexPath *) _indexPathAtMiddle
{
	if (!CGSizeEqualToSize(CGSizeZero, self.contentSize)) {
		CGPoint contentOffset = [self contentOffsetInBoundsCenter];
		
		switch (self.visibleCells.count) {
			case 0: return [self indexPathNearestToPoint:contentOffset];
			default: return [self visibleIndexPathNearestToPoint:contentOffset];
		}
	}
	return nil;
}

- (void) _centerIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate
{
    if ([self circularActive]) {
        [self scrollToItemAtIndexPath:indexPath
                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                             animated:animated];
        
        if (notifyDelegate && _delegateRespondsToDidCenterItemAtIndex) {
            [_originalDelegate collectionView:self didCenterItemAtIndex:indexPath.item];
        }
    }
}


@end
