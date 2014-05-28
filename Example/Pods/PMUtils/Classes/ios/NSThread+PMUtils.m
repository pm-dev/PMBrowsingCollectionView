//
//  NSThread+PMUtils.m
//  
//
//  Created by Peter Meyers on 3/2/14.
//
//

#import "NSThread+PMUtils.h"

@implementation NSThread (PMUtils)

+ (void) dispatchMainThreadAsync:(void (^)(void))block
{
	if (block) {
		
		if ([NSThread isMainThread]) {
			block();
		}
		else {
			dispatch_async(dispatch_get_main_queue(), block);
		}
	}
}

+ (void) dispatchBackgroundThreadAsync:(void (^)(void))block
{
	if (block) {
		
		if (![NSThread isMainThread]) {
			block();
		}
		else {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
		}
	}
}


@end
