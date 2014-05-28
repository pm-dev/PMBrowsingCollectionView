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
- (void) collectionView:(PMBrowsingCollectionView *)collectionView didCenterItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface PMBrowsingCollectionView : UICollectionView

@property (nonatomic, retain) UICollectionViewFlowLayout *collectionViewLayout;

// Overwrite type for delegate;
@property (nonatomic, assign) id <PMBrowsingCollectionViewDelegate> delegate;

- (void) expandSection:(NSInteger)section;
- (void) collapseSection:(NSInteger)section;

- (NSIndexPath *) normalizeIndexPath:(NSIndexPath *)indexPath;

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionView;

@end









