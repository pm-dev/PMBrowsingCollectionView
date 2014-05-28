//
//  NSData+PMUtils.m
//  PMUtils-iOSExample
//
//  Created by Peter Meyers on 3/1/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "NSData+PMUtils.h"

@implementation NSData (PMUtils)

- (NSString *) hexString
{
	const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
	
	if (dataBuffer) {
		
		NSUInteger dataLength  = [self length];
		NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
		
		for (int i = 0; i < dataLength; ++i) {
			[hexString appendString:[NSString stringWithFormat:@"%02x", (unsigned int)dataBuffer[i]]];
		}
		
		return [hexString copy];
	}

	return nil;
}

@end
