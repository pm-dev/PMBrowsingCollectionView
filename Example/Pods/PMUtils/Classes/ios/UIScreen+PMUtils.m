//
//  UIScreen+PMUtils.m
//  PMUtils-iOSExample
//
//  Created by Peter Meyers on 3/1/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "UIScreen+PMUtils.h"

@implementation UIScreen (PMUtils)

- (BOOL) is568h
{
    CGRect screenBounds = [self bounds];
	return CGRectGetHeight(screenBounds) == 568.0f || CGRectGetWidth(screenBounds) == 568.0f;
}

@end
