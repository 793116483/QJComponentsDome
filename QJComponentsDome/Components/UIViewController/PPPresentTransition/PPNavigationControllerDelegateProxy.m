//
//  PPNavigationControllerDelegateProxy.m
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPNavigationControllerDelegateProxy.h"

@interface PPNavigationControllerDelegateProxy ()
@property (nonatomic, weak , readonly) id target;
@property (nonatomic, weak , readonly) UINavigationController * navigationController;
@end

@implementation PPNavigationControllerDelegateProxy

- (instancetype)initWithTarget:(id)target navigationController:(UINavigationController *)navigationController{
    _target = target;
    _navigationController = navigationController ;
    return self;
}

#pragma mark - over write
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    if ([self.navigationController respondsToSelector:selector]) {
        return [self.navigationController methodSignatureForSelector:selector];
    }
    if ([self.target respondsToSelector:selector]) {
        return [self.target methodSignatureForSelector:selector];
    }
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.target];
    }
    if (self.target != self.navigationController && [self.navigationController respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.navigationController];
    }
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.navigationController respondsToSelector:aSelector]) {
        return [self.navigationController respondsToSelector:aSelector];
    }
    return [_target respondsToSelector:aSelector];
}
@end
