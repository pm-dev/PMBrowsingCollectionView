//
//  PMCircularCollectionView.m
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import "PMCircularCollectionView.h"
#import "PMUtils.h"

static NSUInteger const ContentMultiplier = 4;

@interface PMCircularCollectionView ()
{
    CAGradientLayer *_shadowLayer;
    PMProtocolInterceptor *_delegateInterceptor;
    PMProtocolInterceptor *_dataSourceInterceptor;
    NSInteger _itemCount;
    BOOL _implicitlyDisabled;
    BOOL _delegateRespondsToScrollViewDidScroll;
}
@end

@implementation PMCircularCollectionView
@synthesize circularDisabled = _explicitlyDisabled;

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

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonCircularCollectionViewInit];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonCircularCollectionViewInit];
    }
    return self;
}

- (void) commonCircularCollectionViewInit;
{
    NSSet *delegateProtocols = [NSSet setWithObjects:
                                @protocol(UICollectionViewDelegate),
                                @protocol(UIScrollViewDelegate),
                                @protocol(UICollectionViewDelegateFlowLayout), nil];
    
    _delegateInterceptor = [PMProtocolInterceptor interceptorWithMiddleMan:self forProtocols:delegateProtocols];
    [super setDelegate:(id)_delegateInterceptor];
    
    _dataSourceInterceptor = [PMProtocolInterceptor interceptorWithMiddleMan:self forProtocol:@protocol(UICollectionViewDataSource)];
    [super setDataSource:(id)_dataSourceInterceptor];
    
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _recenterIfNecessary];
}

#pragma mark - Accessors


- (void)setDataSource:(NSObject <UICollectionViewDataSource> *)dataSource
{
    [super setDataSource:nil];
    _dataSourceInterceptor.receiver = dataSource;
    [super setDataSource:(id)_dataSourceInterceptor];
}

- (void)setDelegate:(NSObject<UICollectionViewDelegateFlowLayout> *)delegate
{
    [super setDelegate:nil];
    _delegateInterceptor.receiver = delegate;
    [super setDelegate:(id)_delegateInterceptor];
    
    _delegateRespondsToScrollViewDidScroll = [delegate respondsToSelector:@selector(scrollViewDidScroll:)];
}

- (void) setCircularDisabled:(BOOL)circularDisabled
{
    _explicitlyDisabled = circularDisabled;
    _shadowLayer.hidden = self.circularDisabled;
}

- (BOOL) circularDisabled
{
    return _explicitlyDisabled || _implicitlyDisabled;
}

- (void) setShadowRadius:(CGFloat)shadowRadius
{
    if (_shadowRadius != shadowRadius) {
        _shadowRadius = shadowRadius;
        [self _resetShadowLayer];
    }
}

- (void) setShadowColor:(UIColor *)shadowColor
{
    if (![_shadowColor isEqual:shadowColor]) {
        _shadowColor = shadowColor;
        [self _resetShadowLayer];
    }
}

- (NSUInteger) normalizedIndexFromIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.item % _itemCount;
}

#pragma mark - UICollectionViewDatasource Methods

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(PMCircularCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSParameterAssert([collectionView isKindOfClass:[PMCircularCollectionView class]]);
    
    _itemCount = [_dataSourceInterceptor.receiver collectionView:collectionView numberOfItemsInSection:section];
    _implicitlyDisabled = [self _disableCircularInternallyBasedOnContentSize];
    
    return self.circularDisabled? _itemCount : _itemCount * ContentMultiplier;
}


#pragma mark - UIScrollViewDelegate Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.shadowRadius && self.shadowColor) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _shadowLayer.position = scrollView.contentOffset;
        [CATransaction commit];
    }
    
    if (_delegateRespondsToScrollViewDidScroll) {
        [_delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

#pragma mark - Private Methods

- (void) _recenterIfNecessary
{
    if (self.circularDisabled == NO) {
        
        CGPoint currentOffset = self.contentOffset;
        
        switch (self.collectionViewLayout.scrollDirection) {
                
            case UICollectionViewScrollDirectionHorizontal: {
                
                CGFloat contentCenteredX = (self.contentSize.width - self.bounds.size.width) / 2.0f;
                CGFloat deltaFromCenter = currentOffset.x - contentCenteredX;
                CGFloat singleContentWidth = self.contentSize.width / ContentMultiplier;
                
                if (fabsf(deltaFromCenter) >= singleContentWidth ) {
                    
                    CGFloat correction = (deltaFromCenter > 0)? deltaFromCenter - singleContentWidth : deltaFromCenter + singleContentWidth;
                    
                    currentOffset.x = contentCenteredX + correction;
                }
                break;
            }
            case UICollectionViewScrollDirectionVertical: {
                
                CGFloat contentCenteredY = (self.contentSize.height - self.bounds.size.height) / 2.0f;
                CGFloat deltaFromCenter = currentOffset.y - contentCenteredY;
                CGFloat singleContentHeight = self.contentSize.height / ContentMultiplier;
                
                if (fabsf(deltaFromCenter) >= singleContentHeight) {
                    
                    CGFloat correction = (deltaFromCenter > 0)? deltaFromCenter - singleContentHeight : deltaFromCenter + singleContentHeight;
                    
                    currentOffset.y = contentCenteredY + correction;
                }
                break;
            }
        }
        self.contentOffset = currentOffset;
    }
}

- (void) _resetShadowLayer
{
    [_shadowLayer removeFromSuperlayer];
    _shadowLayer = nil;
    
    if (self.shadowRadius && self.shadowColor.alpha) {
        
        UIColor *outerColor = self.shadowColor;
        UIColor *innerColor = [self.shadowColor colorWithAlphaComponent:0.0];
        
        _shadowLayer = [CAGradientLayer layer];
        _shadowLayer.frame = self.bounds;
        _shadowLayer.colors = @[(id)outerColor.CGColor, (id)innerColor.CGColor, (id)innerColor.CGColor, (id)outerColor.CGColor];
        _shadowLayer.anchorPoint = CGPointZero;
        
        CGFloat totalDistance;
        switch (self.collectionViewLayout.scrollDirection) {
                
            case UICollectionViewScrollDirectionHorizontal:
                totalDistance = self.bounds.size.width;
                _shadowLayer.startPoint = CGPointMake(0.0f, 0.5f);
                _shadowLayer.endPoint = CGPointMake(1.0f, 0.5f);
                break;
                
            case UICollectionViewScrollDirectionVertical:
                totalDistance = self.bounds.size.height;
                _shadowLayer.startPoint = CGPointMake(0.5f, 0.0f);
                _shadowLayer.endPoint = CGPointMake(0.5f, 1.0f);
                break;
        }
        
        CGFloat location1 = self.shadowRadius / totalDistance;
        CGFloat location2 = 1.0f - location1;
        _shadowLayer.locations = @[@0.0, @(location1), @(location2), @1.0];
        
        [self.layer addSublayer:_shadowLayer];
    }
}

- (BOOL) _disableCircularInternallyBasedOnContentSize
{
    CGSize contentSize = [self _calculateContentSize];
    
    switch (self.collectionViewLayout.scrollDirection)
    {
        case UICollectionViewScrollDirectionHorizontal: return  contentSize.width < self.bounds.size.width;
        case UICollectionViewScrollDirectionVertical: return contentSize.height < self.bounds.size.height;
    }
}

- (CGSize) _calculateContentSize
{
    CGSize contentSize = CGSizeZero;
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        for (NSUInteger i = 0; i < _itemCount; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            CGSize itemSize = [self.delegate collectionView:self layout:self.collectionViewLayout sizeForItemAtIndexPath:indexPath];
            contentSize.height += itemSize.height;
            contentSize.width += itemSize.width;
        }
    }
    else {
        contentSize.height += self.collectionViewLayout.itemSize.height * _itemCount;
        contentSize.width += self.collectionViewLayout.itemSize.width * _itemCount;
    }
    
    return contentSize;
}

@end
