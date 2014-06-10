//
//  PMAnimationQueue.h
//  PMDrawerController
//
//  Created by Peter Meyers on 6/21/13.
//  Copyright (c) 2013 Peter Meyers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMAnimationQueue : NSObject

- (NSUInteger) animationCount;

- (void) addAnimationWithDelay:(NSTimeInterval)delay
						  options:(UIViewAnimationOptions)options
					 preAnimation:(NSTimeInterval(^)())preAnimation
						animation:(void(^)())animation
					   completion:(void (^)(BOOL finished))completion;

@end
