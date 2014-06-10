//
//  PMProtocolInterceptor.h
//  Pods
//
//  Created by Peter Meyers on 3/25/14.
//
//

#import <Foundation/Foundation.h>

@interface PMProtocolInterceptor : NSObject

@property (nonatomic, readonly, copy) NSSet * interceptedProtocols;
@property (nonatomic, weak) id receiver;
@property (nonatomic, weak, readonly) id middleMan;

- (instancetype)initWithMiddleMan:(id)middleMan forProtocol:(Protocol *)interceptedProtocol;
- (instancetype)initWithMiddleMan:(id)middleMan forProtocols:(NSSet *)interceptedProtocols;

+ (instancetype)interceptorWithMiddleMan:(id)middleMan forProtocol:(Protocol *)interceptedProtocol;
+ (instancetype)interceptorWithMiddleMan:(id)middleMan forProtocols:(NSSet *)interceptedProtocols;


@end
