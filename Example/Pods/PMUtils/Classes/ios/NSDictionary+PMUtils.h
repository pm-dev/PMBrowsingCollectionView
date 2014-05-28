//
//  NSDictionary+PMUtils.h
//  Pods
//
//  Created by Peter Meyers on 5/5/14.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PMUtils)

- (NSDictionary *) replaceKey:(id<NSCopying>)currentKey withKey:(id<NSCopying>)newKey;

- (NSDictionary *) convertUnderscoredStringKeysToCamelCase;

- (NSDictionary *) convertCamelCaseStringKeysToUnderscored;

@end
