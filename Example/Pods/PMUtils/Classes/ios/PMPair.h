//
//  PMPair.h
//  Pods
//
//  Created by Peter Meyers on 5/22/14.
//
//

#import <Foundation/Foundation.h>

@interface PMPair : NSObject

@property (nonatomic, strong) id object1;
@property (nonatomic, strong) id object2;

+ (instancetype) pairWithObject1:(id)object1 object2:(id)object2;

@end
