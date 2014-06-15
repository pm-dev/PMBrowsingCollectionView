//
//  PMBrowsingCollectionView.h
//  hunters-alley-ios
//
//  Created by Peter Meyers on 5/23/14.
//  Copyright (c) 2014 Hunters Alley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMBrowsingCollectionView;

@protocol PMBrowsingCollectionViewDelegate <UICollectionViewDelegateFlowLayout>

@optional
- (CGFloat) collectionView:(PMBrowsingCollectionView *)collectionView shadowRadiusForSection:(NSInteger)section;
- (UIColor *) collectionView:(PMBrowsingCollectionView *)collectionView shadowColorForSection:(NSInteger)section;
- (void) collectionView:(PMBrowsingCollectionView *)collectionView willCenterItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface PMBrowsingCollectionView : UICollectionView

@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

// Overwrite type for delegate;
@property (nonatomic, assign) id <PMBrowsingCollectionViewDelegate> delegate;

- (void) expandSection:(NSUInteger)section;
- (void) collapseSection:(NSUInteger)section;
- (void) toggleExpandedForSection:(NSUInteger)seciton;
- (BOOL) sectionExpanded:(NSUInteger)section;

- (NSUInteger) normalizeItemIndex:(NSUInteger)index forSection:(NSUInteger)section;

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionView;

@end









