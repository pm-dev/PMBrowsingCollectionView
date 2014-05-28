//
//  NSIndexPath+PMUtils.m
//  PMUtils-iOSExample
//
//  Created by Peter Meyers on 3/2/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "NSIndexPath+PMUtils.h"

@implementation NSIndexPath (PMUtils)

- (NSIndexPath *) indexPathByAddingFirstIndex:(NSUInteger)index
{
	NSUInteger newLength = self.length + 1;
	NSUInteger newarray[newLength];
	
	newarray[0] = index;
	
	for (NSUInteger position = 0; position < self.length; position++)
	{
		newarray[position+1] = [self indexAtPosition:position];
	}
	
	return [NSIndexPath indexPathWithIndexes:newarray length:newLength];
}


- (NSIndexPath *) indexPathByRemovingFirstIndex
{
	NSUInteger newLength = self.length - 1;
	NSUInteger newarray[newLength];
	
	for (NSUInteger position = 1; position < self.length; position++)
	{
		newarray[position-1] = [self indexAtPosition:position];
	}
	
	return [NSIndexPath indexPathWithIndexes:newarray length:newLength];
}

- (NSIndexPath *) indexPathByReplacingLastIndex:(NSUInteger)index
{
	NSUInteger newarray[self.length];
	
    newarray[self.length-1] = index;
    
	for (NSUInteger position = 0; position < self.length-1; position++)
	{
		newarray[position] = [self indexAtPosition:position];
	}
	
	return [NSIndexPath indexPathWithIndexes:newarray length:self.length];
}

- (NSIndexPath *) indexPathByReplacingFirstIndex:(NSUInteger)index
{
	NSUInteger newarray[self.length];
	
    newarray[0] = index;
    
	for (NSUInteger position = 1; position < self.length; position++)
	{
		newarray[position] = [self indexAtPosition:position];
	}
	
	return [NSIndexPath indexPathWithIndexes:newarray length:self.length];
}

@end
