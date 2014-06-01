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
#import <objc/runtime.h>

static inline NSString * PMReuseIdentifier(NSInteger index) {
    return [[NSNumber numberWithInteger:index] stringValue];
}

@class PMBrowsingCollectionViewSection;
@interface PMCircularCollectionView (PMBrowsingCollectionView)

- (PMBrowsingCollectionViewSection *)section;
- (void) setSection:(PMBrowsingCollectionViewSection *)section;

@end

@implementation PMCircularCollectionView (PMBrowsingCollectionView)

- (PMBrowsingCollectionViewSection *)section
{
    return objc_getAssociatedObject(self, @selector(section));
}

- (void) setSection:(PMBrowsingCollectionViewSection *)section
{
    objc_setAssociatedObject(self, @selector(section), section, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface PMBrowsingCollectionViewSection : UICollectionViewCell

@property (nonatomic) NSUInteger sectionIndex;
@property (weak, nonatomic, readonly) PMCenteredCircularCollectionView *collectionView;

@end

@interface PMBrowsingCollectionViewSection ()

@property (weak, nonatomic, readwrite) PMCenteredCircularCollectionView *collectionView;

@end

@implementation PMBrowsingCollectionViewSection

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonPMBrowsingCollectionViewSectionInit];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self commonPMBrowsingCollectionViewSectionInit];
}

- (void) commonPMBrowsingCollectionViewSectionInit
{
    PMCenteredCollectionViewFlowLayout *layout = [PMCenteredCollectionViewFlowLayout new];
    PMCenteredCircularCollectionView *collectionView = [PMCenteredCircularCollectionView collectionViewWithFrame:self.bounds
                                                                                            collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:collectionView];
    self.collectionView = collectionView;
	self.collectionView.section = self;
}

@end

@interface PMBrowsingCollectionView () <UICollectionViewDataSource, PMCenteredCircularCollectionViewDelegate>
{
    NSMutableSet *_sections;
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
	_sections = [NSMutableSet set];
}

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
}

- (void) registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier
{
    [_registeredNibs setObject:nib forKey:identifier];
}

- (id) dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    PMBrowsingCollectionViewSection *section = [self _cachedSectionAtIndex:indexPath.section];
    NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
    return [section.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPathForSection];
}


- (void) expandSection:(NSUInteger)sectionIndex
{
    if ([self sectionExpanded:sectionIndex] == NO) {
		[_expandedSectionIndices addIndex:sectionIndex];
		PMBrowsingCollectionViewSection *section = [self _cachedSectionAtIndex:sectionIndex];
		if (section) {
			[self _setExpandedLayoutForSection:section];
			[self reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
		}
		else {
			section = [self _dequeuedSectionAtIndex:sectionIndex];
			[section.collectionView reloadData];
			[self reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
		}
    }
}

- (void) collapseSection:(NSUInteger)sectionIndex
{
    if ([self sectionExpanded:sectionIndex]) {
		[_expandedSectionIndices removeIndex:sectionIndex];
		PMBrowsingCollectionViewSection *section = [self _cachedSectionAtIndex:sectionIndex];
		if (section) {
			[self _setCollapsedLayoutForSection:section];
			[self reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
		}
		else {
			[self _dequeuedSectionAtIndex:sectionIndex];
		}
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
        PMBrowsingCollectionViewSection *cell = [self _cachedSectionAtIndex:sectionIndex];
        NSInteger normalizedItemIndex = [cell.collectionView normalizeIndex:itemIndex];
        return normalizedItemIndex;
    }
    @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"Index's section out of bounds." userInfo:nil]);
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    _sectionsCount = _dataSourceImplementsNumberOfSectionsInCollectionView? [_dataSourceInterceptor.receiver numberOfSectionsInCollectionView:self] : 1;
    
    for (NSUInteger i = 0; i < _sectionsCount; i++) {
		NSString *reuseIdentifier = PMReuseIdentifier(i);
        [super registerClass:[PMBrowsingCollectionViewSection class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    
    return _sectionsCount;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self == collectionView) {
		return 1;
    }
    else {
        PMCenteredCircularCollectionView *circularCollectionView = (PMCenteredCircularCollectionView *)collectionView;
        return [_dataSourceInterceptor.receiver collectionView:self numberOfItemsInSection:circularCollectionView.section.sectionIndex];
    }
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self == collectionView) {
		return [self _dequeuedSectionAtIndex:indexPath.section];
    }
    else {
        PMCenteredCircularCollectionView *circularCollectionView = (PMCenteredCircularCollectionView *)collectionView;
        NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:circularCollectionView.section.sectionIndex];
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
        
		if ([self sectionExpanded:indexPath.section]) {
			PMBrowsingCollectionViewSection *section = [self _cachedSectionAtIndex:indexPath.section];
			return section.collectionView.contentSize;
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
		
        PMCenteredCircularCollectionView *circularCollectionView = (PMCenteredCircularCollectionView *)collectionView;
        NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:circularCollectionView.section.sectionIndex];
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
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:collectionView.section.sectionIndex];
        [_delegateInterceptor.receiver collectionView:self didCenterItemAtIndexPath:indexPath];
    }
}

#pragma mark - Private Methods


- (void) _configureSection:(PMBrowsingCollectionViewSection *)section atIndex:(NSInteger)sectionIndex
{
	section.sectionIndex = sectionIndex;
	
    section.collectionView.delegate = self;
    section.collectionView.dataSource = self;
    section.collectionView.backgroundColor = self.backgroundColor;
	if ([self sectionExpanded:sectionIndex]) {
		DLog(@"Configuring expanded section %@ at index %d", section, sectionIndex);
		[self _setExpandedLayoutForSection:section];
	}
	else {
		DLog(@"Configuring collapsed section %@ at index %d", section, sectionIndex);
		[self _setCollapsedLayoutForSection:section];
	}
    
    if (_delegateImplementsShadowColorForSection) {
        section.collectionView.shadowColor = [_delegateInterceptor.receiver collectionView:self shadowColorForSection:sectionIndex];
    }
    if (_delegateImplementsShadowRadiusForSection) {
        section.collectionView.shadowRadius = [_delegateInterceptor.receiver collectionView:self shadowRadiusForSection:sectionIndex];
    }
    
    [_registeredClasses enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, Class class, BOOL *stop) {
        [section.collectionView registerClass:class forCellWithReuseIdentifier:identifier];
    }];
    
    [_registeredNibs enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, UINib *nib, BOOL *stop) {
        [section.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    }];
}

- (void) _setExpandedLayoutForSection:(PMBrowsingCollectionViewSection *)section
{
	section.collectionView.circularDisabled = YES;
	
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	layout.scrollDirection = self.collectionViewLayout.scrollDirection;
	layout.minimumLineSpacing = self.collectionViewLayout.minimumLineSpacing;
	layout.minimumInteritemSpacing = self.collectionViewLayout.minimumInteritemSpacing;
	section.collectionView.collectionViewLayout = layout;
}

- (void) _setCollapsedLayoutForSection:(PMBrowsingCollectionViewSection *)section
{
	section.collectionView.circularDisabled = NO;
	
	PMCenteredCollectionViewFlowLayout *layout = [PMCenteredCollectionViewFlowLayout new];
	layout.scrollDirection = (self.collectionViewLayout.scrollDirection & UICollectionViewScrollDirectionHorizontal)?
	UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
	layout.minimumLineSpacing = self.collectionViewLayout.minimumLineSpacing;
	layout.minimumInteritemSpacing = self.collectionViewLayout.minimumInteritemSpacing;
	section.collectionView.collectionViewLayout = layout;
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

- (PMBrowsingCollectionViewSection *) _cachedSectionAtIndex:(NSUInteger)sectionIndex
{
	for (PMBrowsingCollectionViewSection *cachedSection in _sections) {
		if (cachedSection.sectionIndex == sectionIndex) {
			return cachedSection;
		}
	}
	return nil;
}

- (PMBrowsingCollectionViewSection *) _dequeuedSectionAtIndex:(NSUInteger)sectionIndex
{
	NSString *reuseIdentifier = PMReuseIdentifier(sectionIndex);
	NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForItem:0 inSection:sectionIndex];
	PMBrowsingCollectionViewSection *section = [super dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:adjustedIndexPath];
	[_sections addObject:section];
	[self _configureSection:section atIndex:sectionIndex];
	return section;
}

@end


