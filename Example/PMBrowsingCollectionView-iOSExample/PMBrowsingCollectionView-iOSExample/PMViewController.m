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
    return 10.0f;
}

- (UIColor *) collectionView:(PMBrowsingCollectionView *)collectionView shadowColorForSection:(NSInteger)section
{
    return [UIColor whiteColor];
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
    return CGSizeMake(320, 100);
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(159, 100);
}


#pragma mark - UICollectionViewDataSource Methods


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[UICollectionViewCell defaultReuseIdentifier] forIndexPath:indexPath];
    [cell.contentView removeSubviews];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.text = [[NSNumber numberWithInteger:indexPath.item] stringValue];
    [cell.contentView addSubview:label];
    
    switch (indexPath.section) {
        case 0: cell.contentView.backgroundColor = [UIColor redColor]; break;
        case 1: cell.contentView.backgroundColor = [UIColor blueColor]; break;
        case 2: cell.contentView.backgroundColor = [UIColor greenColor]; break;
        default:
            break;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (UICollectionReusableView *) collectionView:(PMBrowsingCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:[UICollectionReusableView defaultReuseIdentifier]
                                                                               forIndexPath:indexPath];
    [view removeSubviews];
	view.backgroundColor = [UIColor cyanColor];
	view.layer.borderWidth = 3.0f;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
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
