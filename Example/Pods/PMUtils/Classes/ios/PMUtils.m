//
//  PMUtils.m
//  Pods
//
//  Created by Peter Meyers on 4/24/14.
//
//

#import "PMUtils.h"

NSTimeInterval const PMOneHour = (60*60);
NSTimeInterval const PMOneDay = (PMOneHour*24);
NSTimeInterval const PMOneWeek = (PMOneDay*7);
NSUInteger const PMBytesPerMegabyte = 1024 * 1024;


NSInteger PMShortestCircularDistance(NSInteger fromIndex, NSInteger toIndex, NSRange inRange)
{
    NSInteger forwardDistance = PMForwardCircularDistance(fromIndex, toIndex, inRange);
    NSInteger reverseDistance = PMReverseCircularDistance(fromIndex, toIndex, inRange);
    
    if (ABS(reverseDistance) < forwardDistance) {
        return reverseDistance;
    }
    
    return forwardDistance;
}

NSInteger PMReverseCircularDistance(NSInteger fromIndex, NSInteger toIndex, NSRange inRange)
{
    return -PMForwardCircularDistance(toIndex, fromIndex, inRange);
}

NSInteger PMForwardCircularDistance(NSInteger fromIndex, NSInteger toIndex, NSRange inRange)
{
    fromIndex -= inRange.location;
    toIndex -= inRange.location;
    
    if (fromIndex < 0 || fromIndex >= inRange.length) {
        @throw([NSException exceptionWithName:@"Index Out Of Bounds" reason:[NSString stringWithFormat:@"fromIndex %@, is out of Bounds", [NSNumber numberWithInteger:fromIndex]] userInfo:nil]);
    }
    else if (toIndex < 0 || toIndex >= inRange.length) {
       @throw([NSException exceptionWithName:@"Index Out Of Bounds" reason:[NSString stringWithFormat:@"toIndex %@, is out of Bounds", [NSNumber numberWithInteger:toIndex]] userInfo:nil]);
    }
    
    if (toIndex >= fromIndex) {
        return toIndex - fromIndex;
    }
    else {
        return inRange.length - fromIndex + toIndex;
    }
}
