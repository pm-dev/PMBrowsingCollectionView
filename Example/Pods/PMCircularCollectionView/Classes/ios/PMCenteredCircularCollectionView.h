//
//  PMCenteredCircularCollectionView.h
//  Pods
//
//  Created by Peter Meyers on 3/23/14.
//
//

#import "PMCircularCollectionView.h"
#import "PMCenteredCollectionViewFlowLayout.h"


@class PMCenteredCircularCollectionView;
@protocol PMCenteredCircularCollectionViewDelegate <UICollectionViewDelegateFlowLayout>

@optional

- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView didCenterItemAtIndex:(NSUInteger)index;

@end


@interface PMCenteredCircularCollectionView : PMCircularCollectionView

// Overwrite Type
@property (nonatomic, assign) id <PMCenteredCircularCollectionViewDelegate> delegate;

- (void) centerCell:(UICollectionViewCell *)cell animated:(BOOL)animated;
- (void) centerCellAtIndex:(NSUInteger)index animated:(BOOL)animated;

+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(PMCenteredCollectionViewFlowLayout *)layout;
- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(PMCenteredCollectionViewFlowLayout *)layout;

@end




