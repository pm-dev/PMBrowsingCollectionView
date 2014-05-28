//
//  UIScreen+PMUtils.h
//  PMUtils-iOSExample
//
//  Created by Peter Meyers on 3/1/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (PMUtils)

/**
 *  Check for determining whether the user's device has a screen with a height of 586 points, which is the case on iPhones starting at the iPhone 5, 5s and 5c. (As of 4/29/2014).
 *
 *  @return Boolean determining whether the screen has a height of 586 points.
 */
- (BOOL) is568h;

@end
