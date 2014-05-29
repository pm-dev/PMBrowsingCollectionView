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

@interface PMBrowsingCollectionViewSection : UICollectionViewCell
@property (strong, nonatomic, readonly) PMCenteredCircularCollectionView *collectionView;
@end

@interface PMBrowsingCollectionViewSection ()
@property (strong, nonatomic, readwrite) PMCenteredCircularCollectionView *collectionView;
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
}

@end

@interface PMCircularCollectionView (PMBrowsingCollectionView)

- (NSInteger) sectionIndex;
- (void) setSectionIndex:(NSInteger)index;

@end

@implementation PMCircularCollectionView (PMBrowsingCollectionView)

- (NSInteger) sectionIndex
{
    NSNumber *index = objc_getAssociatedObject(self, @selector(sectionIndex));
    return [index integerValue];
}

- (void) setSectionIndex:(NSInteger)index
{
    objc_setAssociatedObject(self, @selector(sectionIndex), @(index), OBJC_ASSOCIATION_COPY);
}

@end

//@interface PMBrowsingCollectionViewSectionDelegate : NSObject <UICollectionViewDataSource, PMCenteredCircularCollectionViewDelegate>
//@property (nonatomic) NSInteger sectionIndex;
//@property (nonatomic, weak) PMBrowsingCollectionView *browsingCollectionView;
//@property (nonatomic, weak) id <UICollectionViewDataSource> forwardingDataSource;
//@property (nonatomic, weak) id <PMBrowsingCollectionViewDelegate> forwardingDelegate;
//@end
//
//@implementation PMBrowsingCollectionViewSectionDelegate
//
//
//#pragma mark - DataSource Methods
//
//
//- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//
//}
//
//- (UICollectionViewCell *) collectionView:(PMCenteredCircularCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:self.sectionIndex];
//    return [self.forwardingDataSource collectionView:collectionView cellForItemAtIndexPath:indexPathForSection];
//}
//
//#pragma mark - Delegate Methods;
//
//- (CGFloat) collectionView:(UICollectionView *)collectionView
//                    layout:(UICollectionViewLayout *)collectionViewLayout
//minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    if ([self.forwardingDelegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
//            return [self.forwardingDelegate collectionView:self.browsingCollectionView layout:self.browsingCollectionView.collectionViewLayout minimumInteritemSpacingForSectionAtIndex:self.sectionIndex];
//    }
//    
//}
//
//- (CGSize) collectionView:(PMCircularCollectionView *)collectionView
//                   layout:(UICollectionViewFlowLayout *)collectionViewLayout
//   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSParameterAssert([collectionView isKindOfClass:[PMCircularCollectionView class]]);
//    NSParameterAssert([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]);
//    
//    CGSize itemSize = collectionViewLayout.itemSize;
//    
//    if ([_delegateInterceptor.receiver respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
//        NSInteger section = [self sectionForCircularCollectionView:collectionView];
//        NSUInteger normalizedItemIndex = [collectionView normalizedIndexFromIndexPath:indexPath];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:normalizedItemIndex inSection:section];
//        itemSize = [_delegateInterceptor.receiver collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
//    }
//    
//    return itemSize;
//}
//
//
//- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_delegateInterceptor.receiver respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
//        
//        NSInteger sectionIndex = [self sectionForCircularCollectionView:collectionView];
//        NSUInteger itemIndex = [collectionView normalizedIndexFromIndexPath:indexPath];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
//        
//        if (collectionView.scrollEnabled) {
//            
//            UICollectionViewLayoutAttributes *attributes = [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
//            CGPoint cellCenter = attributes.center;
//            CGPoint contentCenter = CGPointMake(collectionView.contentOffset.x + collectionView.center.x,
//                                                collectionView.contentOffset.y + collectionView.center.y);
//            
//            if (CGPointEqualToPoint(cellCenter, contentCenter)) {
//                [_delegateInterceptor.receiver collectionView:self didSelectItemAtIndexPath:indexPath];
//            }
//        }
//        else {
//            [self.browsingCollectionView.delegateInterceptor.receiver collectionView:self didSelectItemAtIndexPath:indexPath];
//        }
//    }
//}
//
//- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView didCenterItemAtIndex:(NSUInteger)index
//{
//    
//}
//
//
//@end


@interface PMBrowsingCollectionView () <UICollectionViewDataSource, PMCenteredCircularCollectionViewDelegate>
{
    NSMutableArray *_sections;
    NSMutableDictionary *_registeredClasses;
    NSMutableDictionary *_registeredNibs;
    PMProtocolInterceptor *_dataSourceInterceptor;
    PMProtocolInterceptor *_delegateInterceptor;
    
    BOOL _delegateRespondsToSizeForItemAtIndexPath;
    BOOL _delegateImplementsShadowRadiusForSection;
    BOOL _delegateImplementsShadowColorForSection;
    BOOL _delegateImplementsDidCenterItemAtIndexPath;
    BOOL _delegateImplementsDidSelectItemAtIndexPath;
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
    
    
    
    _registeredClasses = [@{} mutableCopy];
    _registeredNibs = [@{} mutableCopy];
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
    PMBrowsingCollectionViewSection *section = _sections[indexPath.section];
    NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
    return [section.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPathForSection];
}


- (void) expandSection:(NSInteger)section
{
    
}

- (void) collapseSection:(NSInteger)section
{
    
}

- (NSIndexPath *) normalizeIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _sections.count) {
        PMBrowsingCollectionViewSection *section = _sections[indexPath.section];
        NSInteger itemIndex = [section.collectionView normalizeIndexFromIndexPath:indexPath];
        NSIndexPath *normalizedIndexPath = [NSIndexPath indexPathForItem:itemIndex inSection:indexPath.section];
        return normalizedIndexPath;
    }
    @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"Index's section out of bounds." userInfo:nil]);
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger sectionsCount = _dataSourceImplementsNumberOfSectionsInCollectionView? [_dataSourceInterceptor.receiver numberOfSectionsInCollectionView:self] : 1;

    _sections = [NSMutableArray arrayWithCapacity:sectionsCount];
    
    for (NSInteger i = 0; i < sectionsCount; i++) {
        [super registerClass:[PMBrowsingCollectionViewSection class] forCellWithReuseIdentifier:PMReuseIdentifier(i)];
    }
    
    return sectionsCount;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self == collectionView) {
        return 1;
    }
    else {
        PMCenteredCircularCollectionView *circularCollectionView = (PMCenteredCircularCollectionView *)collectionView;
        return [_dataSourceInterceptor.receiver collectionView:self numberOfItemsInSection:[circularCollectionView sectionIndex]];
    }
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self == collectionView) {
        
        PMBrowsingCollectionViewSection *section = nil;
        if (_sections.count > indexPath.section) {
            section = _sections[indexPath.section];
            [section.collectionView reloadData];
        }
        else {
        NSString *reuseIdentifier = PMReuseIdentifier(indexPath.section);
            section = [super dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
            [self _configureSection:section atIndex:indexPath.section];
        }
        return section;
    }
    else {
        PMCenteredCircularCollectionView *circularCollectionView = (PMCenteredCircularCollectionView *)collectionView;
        NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:[circularCollectionView sectionIndex]];
        return [_dataSourceInterceptor.receiver collectionView:self cellForItemAtIndexPath:indexPathForSection];
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self == collectionView) {
        
        CGSize maxItemDimensions = CGSizeZero;
        if (_delegateRespondsToSizeForItemAtIndexPath) {
            NSInteger itemsInSection = [_dataSourceInterceptor.receiver collectionView:self numberOfItemsInSection:indexPath.section];
            for (NSUInteger i = 0; i < itemsInSection; i++) {
                NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:i inSection:indexPath.section];
                CGSize itemSize = [_delegateInterceptor.receiver collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:sectionIndexPath];
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
        
        switch (self.collectionViewLayout.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal: return CGSizeMake(maxItemDimensions.width, collectionView.bounds.size.height);
            case UICollectionViewScrollDirectionVertical: return CGSizeMake(self.bounds.size.width, maxItemDimensions.height);
        }        
    }
    else if (_delegateRespondsToSizeForItemAtIndexPath) {
        PMCenteredCircularCollectionView *circularCollectionView = (PMCenteredCircularCollectionView *)collectionView;
        NSIndexPath *indexPathForSection = [NSIndexPath indexPathForItem:indexPath.item inSection:[circularCollectionView sectionIndex]];
        return [_delegateInterceptor.receiver collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPathForSection];
    }
    else {
        PMCenteredCircularCollectionView *circularCollectionView = (PMCenteredCircularCollectionView *)collectionView;
        return circularCollectionView.collectionViewLayout.itemSize;
    }
}

#pragma mark - PMCenteredCircularCollectionViewDelegate Methods

//- (CGFloat) collectionView:(UICollectionView *)collectionView
//                    layout:(UICollectionViewLayout *)collectionViewLayout
//minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    if ([self.forwardingDelegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
//            return [self.forwardingDelegate collectionView:self.browsingCollectionView layout:self.browsingCollectionView.collectionViewLayout minimumInteritemSpacingForSectionAtIndex:self.sectionIndex];
//    }
//
//}
//
//- (CGSize) collectionView:(PMCircularCollectionView *)collectionView
//                   layout:(UICollectionViewFlowLayout *)collectionViewLayout
//   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSParameterAssert([collectionView isKindOfClass:[PMCircularCollectionView class]]);
//    NSParameterAssert([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]);
//
//    CGSize itemSize = collectionViewLayout.itemSize;
//
//    if ([_delegateInterceptor.receiver respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
//        NSInteger section = [self sectionForCircularCollectionView:collectionView];
//        NSUInteger normalizedItemIndex = [collectionView normalizedIndexFromIndexPath:indexPath];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:normalizedItemIndex inSection:section];
//        itemSize = [_delegateInterceptor.receiver collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
//    }
//
//    return itemSize;
//}
//
//
- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateImplementsDidSelectItemAtIndexPath) {
        
        if (collectionView.circularDisabled == NO) {

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
    if (_delegateImplementsDidCenterItemAtIndexPath && collectionView.circularDisabled == NO) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:[collectionView sectionIndex]];
        [_delegateInterceptor.receiver collectionView:self didCenterItemAtIndexPath:indexPath];
    }
}

#pragma mark - Private Methods


- (void) _configureSection:(PMBrowsingCollectionViewSection *)section atIndex:(NSInteger)sectionIndex
{
    _sections[sectionIndex] = section;
    
    PMCenteredCollectionViewFlowLayout *layout = [PMCenteredCollectionViewFlowLayout new];
    layout.minimumLineSpacing = self.collectionViewLayout.minimumLineSpacing;
    layout.minimumInteritemSpacing = self.collectionViewLayout.minimumInteritemSpacing;
    layout.scrollDirection = ((self.collectionViewLayout.scrollDirection & UICollectionViewScrollDirectionHorizontal)?
                              UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal);
        
    section.collectionView.collectionViewLayout = layout;
    section.collectionView.delegate = self;
    section.collectionView.dataSource = self;
    section.collectionView.backgroundColor = self.backgroundColor;
    section.collectionView.sectionIndex = sectionIndex;
    
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
    
    [section.collectionView reloadData];
}


@end


