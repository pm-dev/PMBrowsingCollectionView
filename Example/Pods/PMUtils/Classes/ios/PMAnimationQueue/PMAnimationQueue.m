//
//  PMAnimationQueue.m
//  PMDrawerController
//
//  Created by Peter Meyers on 6/21/13.
//  Copyright (c) 2013 Peter Meyers. All rights reserved.
//

#import "PMAnimationQueue.h"

@interface PMAnimationQueue ()

@property (nonatomic, strong) NSMutableArray *animations;

@end

@implementation PMAnimationQueue

- (id) init
{
    self = [super init];
    if (self)
    {
        _animations = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

- (void) addAnimationWithDelay:(NSTimeInterval)delay
						  options:(UIViewAnimationOptions)options
					 preAnimation:(NSTimeInterval(^)())preAnimation
						animation:(void(^)())animation
					   completion:(void (^)(BOOL finished))completion
{
    /* If nothing is currently animating, start the animation.
     * If something is currently animating the passed in animation
     * will execute in the completion block of the current animation.
     */

    __weak PMAnimationQueue	*weakSelf = self;
    
    [self.animations addObject: ^{
        
		void (^nextAnimation)(void) = ^
		{
			[weakSelf.animations removeObjectAtIndex:0];
			if (weakSelf.animations.count)
				((void (^)(void))weakSelf.animations[0])(); // Start next animation
		};
		
		NSTimeInterval duration = 0.0;
		if (preAnimation)
			duration = preAnimation();
		
		
		if (!animation)
		{
			if (completion)
				completion(NO);
			
			nextAnimation();
			return;
		}
		
		
		if (duration <= 0.0)
		{
			if (animation)
				animation();
			if (completion)
				completion(YES);
			
			nextAnimation();
			return;
		}
		
		
        [UIView animateWithDuration:duration
                              delay:delay
                            options:options
                         animations:animation
                         completion:^(BOOL finished)
         {
             if(completion)
                 completion(finished);
			 
			 nextAnimation();
         }];
    }];
    
	
    if (self.animations.count == 1)
        ((void (^)(void))self.animations[0])(); // Kick off the first animation
}

- (NSUInteger) animationCount
{
	return self.animations.count;
}

@end
