//
//  PMPair.m
//  Pods
//
//  Created by Peter Meyers on 5/22/14.
//
//

#import "PMPair.h"

@implementation PMPair

+ (instancetype) pairWithObject1:(id)object1 object2:(id)object2
{
    PMPair *pair = [[self alloc] init];
    pair.object1 = object1;
    pair.object2 = object2;
    return pair;
}

@end
