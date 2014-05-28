//
//  PMViewController.m
//  PMBrowsingCollectionView-iOSExample
//
//  Created by Peter Meyers on 5/25/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMViewController.h"
#import "PMBrowsingCollectionView.h"
#import "PMUtils.h"

@interface PMViewController () <PMBrowsingCollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) PMBrowsingCollectionView *collectionView;
@end

@implementation PMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 10.0f;
    layout.minimumLineSpacing = 10.0f;
    
    self.collectionView = [PMBrowsingCollectionView collectionViewWithFrame:self.view.bounds
                                                       collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:[UICollectionViewCell defaultReuseIdentifier]];
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:[UICollectionReusableView defaultReuseIdentifier]];
    [self.view addSubview:self.collectionView];
}


#pragma mark - Delegate

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
    return CGSizeMake(150, 100);
}


#pragma mark - Datasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[UICollectionViewCell defaultReuseIdentifier] forIndexPath:indexPath];
    [cell.contentView removeSubviews];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.text = [[NSNumber numberWithInteger:indexPath.item] stringValue];
    [cell.contentView addSubview:label];
    
    switch (indexPath.section) {
        case 0: cell.contentView.backgroundColor = [UIColor orangeColor]; break;
        case 1: cell.contentView.backgroundColor = [UIColor grayColor]; break;
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

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:[UICollectionReusableView defaultReuseIdentifier]
                                                                               forIndexPath:indexPath];
    view.backgroundColor = [UIColor cyanColor];
    return view;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
