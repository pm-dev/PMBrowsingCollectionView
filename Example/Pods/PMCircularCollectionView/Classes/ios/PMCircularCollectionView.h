//
//  PMCircularCollectionView.h
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import <UIKit/UIKit.h>

@interface PMCircularCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout>

@property (nonatomic) CGFloat shadowRadius;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, readonly) NSUInteger itemCount;
@property (nonatomic) BOOL circularDisabled;
- (BOOL) circularActive;


// Overwrite Type for flow layouts
@property (nonatomic, retain) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, assign) id <UICollectionViewDelegateFlowLayout> delegate;

// delegate methods all say what index path was selected but we've multiplied the items in the row by a multiplier to allow the circular scroll. Feed that index path to this method to get the correct index.
- (NSInteger) normalizeIndex:(NSInteger)index;

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionView;

@end