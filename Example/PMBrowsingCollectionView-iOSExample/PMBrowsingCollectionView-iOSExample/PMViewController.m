//
//  PMViewController.m
//  PMBrowsingCollectionView-iOSExample
//
//  Created by Peter Meyers on 5/25/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMViewController.h"
#import "PMBrowsingCollectionView.h"
#import "PMStickyHeaderFlowLayout.h"
#import "PMUtils.h"

@interface PMViewController () <PMBrowsingCollectionViewDelegate, UICollectionViewDataSource>
@end

@implementation PMViewController {
	PMBrowsingCollectionView *_collectionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PMStickyHeaderFlowLayout *layout = [PMStickyHeaderFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 2.0f;
    layout.minimumLineSpacing = 2.0f;
    layout.stickyHeaderEndabled = YES;
	
    _collectionView = [PMBrowsingCollectionView collectionViewWithFrame:self.view.bounds
                                                       collectionViewLayout:layout];
	_collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:[UICollectionViewCell defaultReuseIdentifier]];
    [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:[UICollectionReusableView defaultReuseIdentifier]];
    [self.view addSubview:_collectionView];
}


#pragma mark - PMBrowsingCollectionViewDelegate Methods

- (CGFloat) collectionView:(PMBrowsingCollectionView *)collectionView shadowRadiusForSection:(NSInteger)section
{
    return floorf((self.view.bounds.size.width - 50.0f) / 2.0f);
}

- (UIColor *) collectionView:(PMBrowsingCollectionView *)collectionView shadowColorForSection:(NSInteger)section
{
    return [UIColor colorWithWhite:0.2f alpha:0.9];
}

- (void) collectionView:(PMBrowsingCollectionView *)collectionView didCenterItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Centered Item at %@", indexPath);
}

- (void) collectionView:(PMBrowsingCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Selected Item at %@", indexPath);
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.view.bounds.size.width, 100);
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad? 254 : 159), 100);
}


#pragma mark - UICollectionViewDataSource Methods


- (UICollectionViewCell *)collectionView:(PMBrowsingCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[UICollectionViewCell defaultReuseIdentifier] forIndexPath:indexPath];
    [cell.contentView removeSubviews];
	NSParameterAssert(!CGRectEqualToRect(CGRectZero, cell.bounds));
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
	label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	NSUInteger normalizedIndex = [collectionView normalizeItemIndex:indexPath.item forSection:indexPath.section];
    label.text = [[NSNumber numberWithInteger:normalizedIndex] stringValue];
	label.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label];
    
    switch (indexPath.section) {
        case 0: cell.contentView.backgroundColor = [UIColor redColor]; break;
        case 1: cell.contentView.backgroundColor = [UIColor blueColor]; break;
        case 2: cell.contentView.backgroundColor = [UIColor greenColor]; break;
        default: cell.contentView.backgroundColor = [UIColor whiteColor]; break;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 7;
}

- (UICollectionReusableView *) collectionView:(PMBrowsingCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:[UICollectionReusableView defaultReuseIdentifier]
                                                                               forIndexPath:indexPath];
    [view removeSubviews];
	view.backgroundColor = [UIColor cyanColor];
	view.layer.borderWidth = 2.0f;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
	[button setTitle:@"Tap to toggle row expansion" forState:UIControlStateNormal];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_headerSelected:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    button.tag = indexPath.section;
    return view;
}


#pragma mark - Private Methods


- (void) _headerSelected:(UIButton *)button
{
    [_collectionView toggleExpandedForSection:button.tag];
}

@end
