//
//  NSIndexPath+PMUtils.h
//  PMUtils-iOSExample
//
//  Created by Peter Meyers on 3/2/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (PMUtils)

- (NSIndexPath *) indexPathByRemovingFirstIndex;
- (NSIndexPath *) indexPathByAddingFirstIndex:(NSUInteger)index;
- (NSIndexPath *) indexPathByReplacingLastIndex:(NSUInteger)index;
- (NSIndexPath *) indexPathByReplacingFirstIndex:(NSUInteger)index;

@end
