//
//  PPMultiTargetProxy.m
//  PatPat
//
//  Created by 杰 on 2021/8/12.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "PPMultiTargetProxy.h"

@implementation PPMultiTargetProxy

- (instancetype)initWithTarget:(nullable id)target secondTarget:(nullable id)secondTarget{
    _target = target;
    _secondTarget = secondTarget ;
    return self;
}

//类方法
+ (instancetype)proxyWithTarget:(nullable id)target secondTarget:(nullable id)secondTarget{
    return [[self alloc] initWithTarget:target secondTarget:secondTarget];
}

#pragma mark - over write
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    if ([_target respondsToSelector:selector]) {
        return [_target methodSignatureForSelector:selector];
    }
    if (_target && [_secondTarget respondsToSelector:selector]) {
        return [_secondTarget methodSignatureForSelector:selector];
    }
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

//重写NSProxy如下两个方法，在处理消息转发时，将消息转发给真正的Target处理
- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = invocation.selector ;
    if ([_target respondsToSelector:selector]) {
        [invocation invokeWithTarget:_target];
    }
    if (_target && [_secondTarget respondsToSelector:selector]) {
        [invocation invokeWithTarget:_secondTarget];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([_target respondsToSelector:aSelector]) {
        return YES;
    }
    if (_target && [_secondTarget respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

#pragma mark - <NSObject>

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end

