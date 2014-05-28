//
//  UITableView+PMUtils.m
//  PMUtils-iOSExample
//
//  Created by Peter Meyers on 3/2/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "UITableView+PMUtils.h"

@implementation UITableView (PMUtils)

- (void) reloadRowsVisibleRowsWithRowAnimation:(UITableViewRowAnimation)animation
{
	NSArray *visibleRows = [self indexPathsForVisibleRows];
	[self reloadRowsAtIndexPaths:visibleRows withRowAnimation:animation];
}

@end
