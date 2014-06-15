//
//  PMBrowsingCollectionView.m
//  hunters-alley-ios
//
//  Created by Peter Meyers on 5/23/14.
//  Copyright (c) 2014 Hunters Alley. All rights reserved.
//

#import "PMBrowsingCollectionView.h"
#import "PMCenteredCircularCollectionView.h"
#import "PMUtils.h"

static NSString * const PMBrowsingCollectionViewCellReuseIdentifier = @"PMBrowsingCollectionViewCellReuseIdentifier";

@interface PMBrowsingCollectionView () <UICollectionViewDataSource, PMCenteredCircularCollectionViewDelegate>
@end


@implementation PMBrowsingCollectionView {
	
    NSMutableArray *_sectionCollectionViews;
    NSMutableIndexSet *_expandedSectionIndices;
	NSMutableDictionary *_lastCenteredIndexInSectionBySectionIndex;
    NSMutableDictionary *_registeredClasses;
    NSMutableDictionary *_registeredNibs;
    PMProtocolInterceptor *_dataSourceInterceptor;
    PMProtocolInterceptor *_delegateInterceptor;
    NSUInteger _sectionsCount;
		
    BOOL _delegateRespondsToSizeForItemAtIndexPath;
    BOOL _delegateImplementsShadowRadiusForSection;
    BOOL _delegateImplementsShadowColorForSection;
    BOOL _delegateImplementsWillCenterItemAtIndexPath;
    BOOL _delegateImplementsDidSelectItemAtIndexPath;
    BOOL _delegateImplementsMinimumInteritemSpacingForSectionAtIndex;
    BOOL _delegateImplementsMinimumLineSpacingForSectionAtIndex;
    BOOL _dataSourceImplementsNumberOfSectionsInCollectionView;
}

+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    return [[self alloc] initWithFrame:frame collectionViewLayout:layout];
}

+ (instancetype) collectionView
{
    return [[self alloc] init];
}

- (instancetype) init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype) initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame collectionViewLayout:[UICollectionViewFlowLayout new]];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonPMBrowsingCollectionViewInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self _commonPMBrowsingCollectionViewInit];
    }
    return self;
}

- (void) registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    [_registeredClasses setObject:cellClass forKey:identifier];
	for (PMCenteredCircularCollectionView *collectionView in _sectionCollectionViews) {
		[collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
	}
}

- (void) registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier
{
    [_registeredNibs setObject:nib forKey:identifier];
	for (PMCenteredCircularCollectionView *collectionView in _sectionCollectionViews) {
		[collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
	}
}

- (id) dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
	PMCenteredCircularCollectionView *collectionView = [self _collectionViewAtSectionIndex:indexPath.section];
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPathForSection];
}

- (void)reloadSections:(NSIndexSet *)sections
{
	[super reloadSections:sections];
}

- (void) setFrame:(CGRect)frame
{
	[super setFrame:frame];
	NSAssert(CGSizeEqualToSize(CGSizeZero, self.contentSize), @"PMBrowsingCollectionView does not yet support resizing. This will come for free in iOS8 with dynamic cell sizing.");
}

#pragma mark - Accessors


- (void) setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    [super setDataSource:nil];
    _dataSourceInterceptor.receiver = dataSource;
    [super setDataSource:(id)_dataSourceInterceptor];
    
    _dataSourceImplementsNumberOfSectionsInCollectionView = [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)];
}

- (void) setDelegate:(id<PMBrowsingCollectionViewDelegate>)delegate
{
    [super setDelegate:nil];
    _delegateInterceptor.receiver = delegate;
    [super setDelegate:(id)_delegateInterceptor];
    
    _delegateRespondsToSizeForItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)];
    _delegateImplementsShadowRadiusForSection = [delegate respondsToSelector:@selector(collectionView:shadowRadiusForSection:)];
    _delegateImplementsShadowColorForSection = [delegate respondsToSelector:@selector(collectionView:shadowColorForSection:)];
    _delegateImplementsWillCenterItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:willCenterItemAtIndexPath:)];
    _delegateImplementsDidSelectItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)];
    _delegateImplementsMinimumLineSpacingForSectionAtIndex = [delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)];
    _delegateImplementsMinimumInteritemSpacingForSectionAtIndex = [delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)];
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor];
	for (PMCenteredCircularCollectionView *collectionView in _sectionCollectionViews) {
		collectionView.backgroundColor = backgroundColor;
	}
}


#pragma mark - Public Methods


- (void) expandSection:(NSUInteger)sectionIndex
{
    if ([self sectionExpanded:sectionIndex] == NO) {
		[_expandedSectionIndices addIndex:sectionIndex];
		[[self _collectionViewAtSectionIndex:sectionIndex] killScroll];
		[self reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
    }
}

- (void) collapseSection:(NSUInteger)sectionIndex
{
    if ([self sectionExpanded:sectionIndex]) {
		[_expandedSectionIndices removeIndex:sectionIndex];
		[self reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
		[self _centerSections];
    }
}

- (void) toggleExpandedForSection:(NSUInteger)section
{
    if ([self sectionExpanded:section]) {
        [self collapseSection:section];
    }
    else {
        [self expandSection:section];
    }
}

- (BOOL) sectionExpanded:(NSUInteger)section
{
    return [_expandedSectionIndices containsIndex:section];
}

- (NSUInteger) normalizeItemIndex:(NSUInteger)itemIndex forSection:(NSUInteger)sectionIndex
{
    if (sectionIndex < _sectionsCount) {
        PMCenteredCircularCollectionView *collectionView = [self _collectionViewAtSectionIndex:sectionIndex];
        NSInteger normalizedItemIndex = [collectionView normalizeIndex:itemIndex];
        return normalizedItemIndex;
    }
    @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"Index's section out of bounds." userInfo:nil]);
}


#pragma mark - UICollectionViewDataSource Methods


- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    _sectionsCount = _dataSourceImplementsNumberOfSectionsInCollectionView? [_dataSourceInterceptor.receiver numberOfSectionsInCollectionView:self] : 1;
	
    return _sectionsCount;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self == collectionView) {
		return 1;
    }
    else {
		NSUInteger sectionIndex = [self _sectionIndexOfCollectionView:collectionView];
        return [_dataSourceInterceptor.receiver collectionView:self numberOfItemsInSection:sectionIndex];
    }
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self == collectionView) {
		UICollectionViewCell *cell = [super dequeueReusableCellWithReuseIdentifier:PMBrowsingCollectionViewCellReuseIdentifier forIndexPath:indexPath];
		[cell.contentView removeSubviews];
		PMCenteredCircularCollectionView *sectionCollectionView = [self _collectionViewAtSectionIndex:indexPath.section];
		sectionCollectionView.frame = cell.contentView.bounds;
		[cell.contentView addSubview:sectionCollectionView];
		return cell;
    }
    else {
		NSUInteger sectionIndex = [self _sectionIndexOfCollectionView:collectionView];
        NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:sectionIndex];
        return [_dataSourceInterceptor.receiver collectionView:self cellForItemAtIndexPath:indexPathForSection];
    }
}


#pragma mark - PMCenteredCircularCollectionViewDelegate Methods


- (CGFloat) collectionView:(UICollectionView *)collectionView
					layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (_delegateImplementsMinimumLineSpacingForSectionAtIndex) {
        return [self.delegate collectionView:self layout:self.collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
    }
    return self.collectionViewLayout.minimumInteritemSpacing;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (_delegateImplementsMinimumInteritemSpacingForSectionAtIndex) {
            return [self.delegate collectionView:self layout:self.collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
    }
    return self.collectionViewLayout.minimumInteritemSpacing;
}

- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self == collectionView) {
        CGSize size = CGSizeZero;
		PMCenteredCircularCollectionView *sectionCollectionView = [self _collectionViewAtSectionIndex:indexPath.section];
		BOOL isExpanded = [self sectionExpanded:indexPath.section];
		sectionCollectionView.circularDisabled = isExpanded;
		sectionCollectionView.collectionViewLayout = isExpanded? [self _expandedLayout] : [self _collapsedLayout];
		if (isExpanded) {
			size = sectionCollectionView.contentSize;
		}
		else {
			CGSize maxItemDimensions = [self _calculateMaxItemDimensionsForSection:indexPath.section];
			switch (self.collectionViewLayout.scrollDirection) {
				case UICollectionViewScrollDirectionHorizontal: size = CGSizeMake(maxItemDimensions.width, self.bounds.size.height); break;
				case UICollectionViewScrollDirectionVertical: size = CGSizeMake(self.bounds.size.width, maxItemDimensions.height); break;
			}
		}
		sectionCollectionView.frame = CGRectMake(0, 0, size.width, size.height);
		return size;
    }
    else if (_delegateRespondsToSizeForItemAtIndexPath) {
		NSUInteger sectionIndex = [self _sectionIndexOfCollectionView:collectionView];
        NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:sectionIndex];
        return [_delegateInterceptor.receiver collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPathForSection];
    }
    else {
		
        PMCenteredCircularCollectionView *circularCollectionView = (PMCenteredCircularCollectionView *)collectionView;
        return circularCollectionView.collectionViewLayout.itemSize;
    }
}

- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateImplementsDidSelectItemAtIndexPath) {
        
        if ([collectionView circularActive]) {

            UICollectionViewLayoutAttributes *attributes = [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
            CGPoint cellCenter = attributes.center;
            CGPoint contentCenter = CGPointMake(collectionView.contentOffset.x + collectionView.center.x,
                                                collectionView.contentOffset.y + collectionView.center.y);

            if (CGPointEqualToPoint(cellCenter, contentCenter)) {
                [_delegateInterceptor.receiver collectionView:self didSelectItemAtIndexPath:indexPath];
            }
        }
        else {
            [_delegateInterceptor.receiver collectionView:self didSelectItemAtIndexPath:indexPath];
        }
    }
}

- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView willCenterItemAtIndex:(NSUInteger)index
{
	NSUInteger sectionIndex = [self _sectionIndexOfCollectionView:collectionView];
	_lastCenteredIndexInSectionBySectionIndex[@(sectionIndex)] = @(index);
    if (_delegateImplementsWillCenterItemAtIndexPath) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:sectionIndex];
        [_delegateInterceptor.receiver collectionView:self willCenterItemAtIndexPath:indexPath];
    }
}


#pragma mark - Private Methods


- (void) _commonPMBrowsingCollectionViewInit
{
    NSSet *delegateProtocols = [NSSet setWithObjects:
                                @protocol(UICollectionViewDelegate),
                                @protocol(UIScrollViewDelegate),
                                @protocol(UICollectionViewDelegateFlowLayout), nil];
    
    _delegateInterceptor = [PMProtocolInterceptor interceptorWithMiddleMan:self forProtocols:delegateProtocols];
    [super setDelegate:(id)_delegateInterceptor];
    
    _dataSourceInterceptor = [PMProtocolInterceptor interceptorWithMiddleMan:self forProtocol:@protocol(UICollectionViewDataSource)];
    [super setDataSource:(id)_dataSourceInterceptor];
    
    _expandedSectionIndices = [NSMutableIndexSet indexSet];
    _registeredClasses = [@{} mutableCopy];
    _registeredNibs = [@{} mutableCopy];
	_sectionCollectionViews = [@[] mutableCopy];
	_lastCenteredIndexInSectionBySectionIndex = [@{} mutableCopy];
	
	[super registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:PMBrowsingCollectionViewCellReuseIdentifier];
}

- (CGSize) _calculateMaxItemDimensionsForSection:(NSInteger)section
{
	CGSize maxItemDimensions = CGSizeZero;
	if (_delegateRespondsToSizeForItemAtIndexPath) {
		NSInteger itemsInSection = [_dataSourceInterceptor.receiver collectionView:self numberOfItemsInSection:section];
		for (NSUInteger i = 0; i < itemsInSection; i++) {
			NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:i inSection:section];
			CGSize itemSize = [_delegateInterceptor.receiver collectionView:self layout:self.collectionViewLayout sizeForItemAtIndexPath:sectionIndexPath];
			if (itemSize.width > maxItemDimensions.width) {
				maxItemDimensions.width = itemSize.width;
			}
			if (itemSize.height > maxItemDimensions.height) {
				maxItemDimensions.height = itemSize.height;
			}
		}
	}
	else {
		maxItemDimensions = self.collectionViewLayout.itemSize;
	}
	return maxItemDimensions;
}

- (NSUInteger) _sectionIndexOfCollectionView:(UICollectionView *)collectionView
{
	return [_sectionCollectionViews indexOfObjectIdenticalTo:collectionView];
}

- (PMCenteredCircularCollectionView *) _collectionViewAtSectionIndex:(NSUInteger)sectionIndex
{
	if (sectionIndex < _sectionCollectionViews.count) {
		return _sectionCollectionViews[sectionIndex];
	}
	else {
		PMCenteredCircularCollectionView *collectionView = [PMCenteredCircularCollectionView new];
		collectionView.collectionViewLayout = [self _collapsedLayout];
		collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		collectionView.delegate = self;
		collectionView.dataSource = self;
		collectionView.backgroundColor = self.backgroundColor;
		if (_delegateImplementsShadowColorForSection) {
			collectionView.shadowColor = [_delegateInterceptor.receiver collectionView:self shadowColorForSection:sectionIndex];
		}
		if (_delegateImplementsShadowRadiusForSection) {
			collectionView.shadowRadius = [_delegateInterceptor.receiver collectionView:self shadowRadiusForSection:sectionIndex];
		}
		[_registeredClasses enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, Class class, BOOL *stop) {
			[collectionView registerClass:class forCellWithReuseIdentifier:identifier];
		}];
		[_registeredNibs enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, UINib *nib, BOOL *stop) {
			[collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
		}];
		_sectionCollectionViews[sectionIndex] = collectionView;
		
		return collectionView;
	}
}

- (PMCenteredCollectionViewFlowLayout *) _expandedLayout
{
	PMCenteredCollectionViewFlowLayout *expandedLayout = [PMCenteredCollectionViewFlowLayout new];
	expandedLayout.centeringDisabled = YES;
	expandedLayout.scrollDirection = self.collectionViewLayout.scrollDirection;
	expandedLayout.minimumLineSpacing = self.collectionViewLayout.minimumLineSpacing;
	expandedLayout.minimumInteritemSpacing = self.collectionViewLayout.minimumInteritemSpacing;
	return expandedLayout;
}

- (PMCenteredCollectionViewFlowLayout *) _collapsedLayout
{
	PMCenteredCollectionViewFlowLayout *collapsedLayout = [PMCenteredCollectionViewFlowLayout new];
	collapsedLayout.scrollDirection = (self.collectionViewLayout.scrollDirection & UICollectionViewScrollDirectionHorizontal)?
	UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
	collapsedLayout.minimumLineSpacing = self.collectionViewLayout.minimumLineSpacing;
	collapsedLayout.minimumInteritemSpacing = self.collectionViewLayout.minimumInteritemSpacing;
	return collapsedLayout;
}

- (void) _centerSections
{
	[_sectionCollectionViews enumerateObjectsUsingBlock:^(PMCenteredCircularCollectionView *collectionView, NSUInteger idx, BOOL *stop) {
		
		if (collectionView.collectionViewLayout.centeringDisabled == NO) {
			
			NSNumber *lastCenteredIndex = _lastCenteredIndexInSectionBySectionIndex[@(idx)];
			NSInteger normalizedIndex = [collectionView normalizeIndex:[lastCenteredIndex integerValue]];
			collectionView.centeredIndex = normalizedIndex;
		}
	}];
}

@end


