//
//  UICollectionReusableView+PMUtils.m
//  Pods
//
//  Created by Peter Meyers on 4/16/14.
//
//

#import "UICollectionReusableView+PMUtils.h"
#import "UIView+PMUtils.h"

@implementation UICollectionReusableView (PMUtils)

+ (instancetype)sizingCell
{
    static NSCache *cellCache = nil;
    static dispatch_once_t cacheToken;
    dispatch_once(&cacheToken, ^{
        cellCache = [NSCache new];
    });
    
    NSString *key = NSStringFromClass(self);
    id sizingCell = [cellCache objectForKey:key];
    
    if (!sizingCell) {
        sizingCell = [self instanceFromDefaultNibWithOwner:nil];
		if (!sizingCell) {
			sizingCell = [self new];
		}
        [cellCache setObject:sizingCell?: [NSNull null] forKey:key];
    }
    else if ([sizingCell isEqual:[NSNull null]]) {
        sizingCell = nil;
    }
    
    return sizingCell;
}

+ (NSString *)defaultReuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
