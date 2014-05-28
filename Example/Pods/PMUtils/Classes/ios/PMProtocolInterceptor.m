//
//  PMProtocolInterceptor.m
//  Pods
//
//  Created by Peter Meyers on 3/25/14.
//
//

#import  <objc/runtime.h>
#import "PMProtocolInterceptor.h"

static inline BOOL selector_belongsToProtocol(SEL selector, Protocol * protocol)
{
    // Reference: https://gist.github.com/numist/3838169
    for (int optionbits = 0; optionbits < (1 << 2); optionbits++) {
        BOOL required = optionbits & 1;
        BOOL instance = !(optionbits & (1 << 1));
        
        struct objc_method_description hasMethod = protocol_getMethodDescription(protocol, selector, required, instance);
        if (hasMethod.name || hasMethod.types) {
            return YES;
        }
    }
    return NO;
}

@implementation PMProtocolInterceptor


- (instancetype)initWithMiddleMan:(id)middleMan forProtocol:(Protocol *)interceptedProtocol
{
    self = [super init];
    if (self) {
        _interceptedProtocols = [NSSet setWithObject:interceptedProtocol];
        _middleMan = middleMan;
    }
    return self;
}

- (instancetype)initWithMiddleMan:(id)middleMan forProtocols:(NSSet *)interceptedProtocols
{
    self = [super init];
    if (self) {
        _interceptedProtocols = [interceptedProtocols copy];
        _middleMan = middleMan;
    }
    return self;
}

+ (instancetype)interceptorWithMiddleMan:(id)middleMan forProtocol:(Protocol *)interceptedProtocol
{
    return [[self alloc] initWithMiddleMan:middleMan forProtocol:interceptedProtocol];
}

+ (instancetype)interceptorWithMiddleMan:(id)middleMan forProtocols:(NSSet *)interceptedProtocols
{
    return [[self alloc] initWithMiddleMan:middleMan forProtocols:interceptedProtocols];
}

- (void) setReceiver:(id)receiver
{
    NSAssert(![receiver isKindOfClass:[PMProtocolInterceptor class]],
             @"Setting a PMProtocolInterceptor as another PMProtocolInterceptor's receiver is not supported");
    _receiver = receiver;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.middleMan respondsToSelector:aSelector] &&
        [self _isSelectorContainedInInterceptedProtocols:aSelector]) {
        return self.middleMan;
    }
    if ([self.receiver respondsToSelector:aSelector]) {
        return self.receiver;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self.middleMan respondsToSelector:aSelector] &&
        [self _isSelectorContainedInInterceptedProtocols:aSelector]) {
        return YES;
    }
    if ([self.receiver respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

#pragma mark - Private Methods

- (BOOL)_isSelectorContainedInInterceptedProtocols:(SEL)aSelector
{
    __block BOOL isSelectorContainedInInterceptedProtocols = NO;
    
    [self.interceptedProtocols enumerateObjectsUsingBlock:^(Protocol * protocol, BOOL *stop) {
        isSelectorContainedInInterceptedProtocols = selector_belongsToProtocol(aSelector, protocol);
        *stop = isSelectorContainedInInterceptedProtocols;
    }];
    return isSelectorContainedInInterceptedProtocols;
}

@end
