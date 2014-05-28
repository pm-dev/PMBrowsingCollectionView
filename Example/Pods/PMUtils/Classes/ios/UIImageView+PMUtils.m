//
//  UIImageView+PM.m
//  hunters-alley-ios
//
//  Created by Peter Meyers on 5/20/14.
//

#import "UIImageView+PMUtils.h"
#import <objc/runtime.h>

@implementation UIImageView (PMUtils)

- (void) setImageEntity:(id)imageEntity
{
    [self setImageEntity:imageEntity success:nil failure:nil];
}

- (void) setImageEntity:(id)imageEntity
                success:(void (^)(UIImage *image))success
                failure:(void (^)(NSError *error))failure;
{
    id<UIImageViewDelegate> delegate = [UIImageView delegate];
    NSParameterAssert(delegate);
    [delegate setImageView:self imageForEntity:imageEntity success:success failure:failure];
}

+ (void) setDelegate:(id<UIImageViewDelegate>)delegate
{
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (id<UIImageViewDelegate>)delegate
{
    return (id<UIImageViewDelegate>)objc_getAssociatedObject(self, @selector(delegate));
}

@end
