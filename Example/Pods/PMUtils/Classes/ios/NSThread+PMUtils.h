//
//  NSThread+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/2/14.
//
//

#import <Foundation/Foundation.h>

@interface NSThread (PMUtils)

+ (void) dispatchMainThreadAsync:(void (^)(void))block;

+ (void) dispatchBackgroundThreadAsync:(void (^)(void))block;

@end
