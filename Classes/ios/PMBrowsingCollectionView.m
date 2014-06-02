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
{
    NSMutableArray *_sectionCollectionViews;
    NSMutableIndexSet *_expandedSectionIndices;
    NSMutableDictionary *_registeredClasses;
    NSMutableDictionary *_registeredNibs;
    PMProtocolInterceptor *_dataSourceInterceptor;
    PMProtocolInterceptor *_delegateInterceptor;
    NSUInteger _sectionsCount;
	
    BOOL _delegateRespondsToSizeForItemAtIndexPath;
    BOOL _delegateImplementsShadowRadiusForSection;
    BOOL _delegateImplementsShadowColorForSection;
    BOOL _delegateImplementsDidCenterItemAtIndexPath;
    BOOL _delegateImplementsDidSelectItemAtIndexPath;
    BOOL _delegateImplementsMinimumInteritemSpacingForSectionAtIndex;
    BOOL _delegateImplementsMinimumLineSpacingForSectionAtIndex;
    BOOL _dataSourceImplementsNumberOfSectionsInCollectionView;
}

@end


@implementation PMBrowsingCollectionView

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
        [self commonPMBrowsingCollectionViewInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonPMBrowsingCollectionViewInit];
    }
    return self;
}


- (void) commonPMBrowsingCollectionViewInit
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
	
	[super registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:PMBrowsingCollectionViewCellReuseIdentifier];
}


#pragma mark - Overwritten Methods


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
    _delegateImplementsDidCenterItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:didCenterItemAtIndexPath:)];
    _delegateImplementsDidSelectItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)];
    _delegateImplementsMinimumLineSpacingForSectionAtIndex = [delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)];
    _delegateImplementsMinimumInteritemSpacingForSectionAtIndex = [delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)];
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

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor];
	for (PMCenteredCircularCollectionView *collectionView in _sectionCollectionViews) {
		collectionView.backgroundColor = backgroundColor;
	}
}

- (id) dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
	PMCenteredCircularCollectionView *collectionView = [self _collectionViewAtSectionIndex:indexPath.section];
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPathForSection];
}


#pragma mark - Public Methods


- (void) expandSection:(NSUInteger)sectionIndex
{
    if ([self sectionExpanded:sectionIndex] == NO) {
		[_expandedSectionIndices addIndex:sectionIndex];
		[self reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
    }
}

- (void) collapseSection:(NSUInteger)sectionIndex
{
    if ([self sectionExpanded:sectionIndex]) {
		[_expandedSectionIndices removeIndex:sectionIndex];
		[self reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
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
		PMCenteredCircularCollectionView *collectionView = [self _collectionViewAtSectionIndex:indexPath.section];
		collectionView.frame = cell.contentView.bounds;
		[cell.contentView addSubview:collectionView];
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
        
		PMCenteredCircularCollectionView *collectionView = [self _collectionViewAtSectionIndex:indexPath.section];
		BOOL isExpanded = [self sectionExpanded:indexPath.section];
		collectionView.circularDisabled = isExpanded;
		collectionView.collectionViewLayout = isExpanded? [self _expandedLayout] : [self _collapsedLayout];
		if (isExpanded) {
			return collectionView.contentSize;
		}
		else {
			CGSize maxItemDimensions = [self _calculateMaxItemDimensionsForSection:indexPath.section];
			switch (self.collectionViewLayout.scrollDirection) {
				case UICollectionViewScrollDirectionHorizontal: return CGSizeMake(maxItemDimensions.width, collectionView.bounds.size.height);
				case UICollectionViewScrollDirectionVertical: return CGSizeMake(self.bounds.size.width, maxItemDimensions.height);
			}
		}
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

- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView didCenterItemAtIndex:(NSUInteger)index
{
    if (_delegateImplementsDidCenterItemAtIndexPath) {
		NSUInteger sectionIndex = [self _sectionIndexOfCollectionView:collectionView];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:sectionIndex];
        [_delegateInterceptor.receiver collectionView:self didCenterItemAtIndexPath:indexPath];
    }
}


#pragma mark - Private Methods


- (UICollectionViewFlowLayout *) _expandedLayout
{
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	layout.scrollDirection = self.collectionViewLayout.scrollDirection;
	layout.minimumLineSpacing = self.collectionViewLayout.minimumLineSpacing;
	layout.minimumInteritemSpacing = self.collectionViewLayout.minimumInteritemSpacing;
	return layout;
}

- (PMCenteredCollectionViewFlowLayout *) _collapsedLayout
{
	PMCenteredCollectionViewFlowLayout *layout = [PMCenteredCollectionViewFlowLayout new];
	layout.scrollDirection = (self.collectionViewLayout.scrollDirection & UICollectionViewScrollDirectionHorizontal)?
	UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
	layout.minimumLineSpacing = self.collectionViewLayout.minimumLineSpacing;
	layout.minimumInteritemSpacing = self.collectionViewLayout.minimumInteritemSpacing;
	return layout;
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

@end


