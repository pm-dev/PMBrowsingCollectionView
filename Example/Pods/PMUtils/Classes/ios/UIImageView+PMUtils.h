//
//  UIImageView+PM.h
//  hunters-alley-ios
//
//  Created by Peter Meyers on 5/20/14.
//

#import <UIKit/UIKit.h>

@protocol UIImageViewDelegate <NSObject>

- (void) setImageView:(UIImageView *)imageView
       imageForEntity:(id)imageEntity
              success:(void (^)(UIImage *image))successBlock
              failure:(void (^)(NSError *error))failureBlock;

@end


@interface UIImageView (PMUtils)

+ (void) setDelegate:(id<UIImageViewDelegate>)delegate;
+ (id<UIImageViewDelegate>)delegate;

- (void) setImageEntity:(id)imageEntity;

- (void) setImageEntity:(id)imageEntity
                success:(void (^)(UIImage *image))success
                failure:(void (^)(NSError *error))failure;
@end





