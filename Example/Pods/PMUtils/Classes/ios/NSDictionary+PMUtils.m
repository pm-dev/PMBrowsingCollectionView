//
//  NSDictionary+PMUtils.m
//  Pods
//
//  Created by Peter Meyers on 5/5/14.
//
//

#import "NSDictionary+PMUtils.h"
#import "NSString+PMUtils.h"

@implementation NSDictionary (PMUtils)

- (NSDictionary *) replaceKey:(id<NSCopying>)currentKey withKey:(id<NSCopying>)newKey
{
    id value = self[currentKey];
    if (value) {
        NSMutableDictionary *mutableSelf = [self mutableCopy];
        mutableSelf[newKey] = value;
        [mutableSelf removeObjectForKey:currentKey];
        return mutableSelf;
    }
    return self;
}


- (NSDictionary *) convertUnderscoredStringKeysToCamelCase
{
    NSMutableDictionary *mutableSelf = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]]) {
            NSString *stringKey = key;
            mutableSelf[[stringKey camelCaseFromUnderscores]] = obj;
        }
        else {
            mutableSelf[key] = obj;
        }
    }];
     
    return mutableSelf;
}

- (NSDictionary *) convertCamelCaseStringKeysToUnderscored
{
    NSMutableDictionary *mutableSelf = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]]) {
            NSString *stringKey = key;
            mutableSelf[[stringKey underscoresFromCamelCase]] = obj;
        }
        else {
            mutableSelf[key] = obj;
        }
    }];
     
     return mutableSelf;
}

@end
