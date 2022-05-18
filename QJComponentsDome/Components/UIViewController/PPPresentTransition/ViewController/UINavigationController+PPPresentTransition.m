//
//  UINavigationController+PPPresentTransition.m
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "UINavigationController+PPPresentTransition.h"
#import "UIViewController+PPPresentTransition.h"
#import "PPNavigationControllerDelegateProxy.h"
#import "UIViewController+PPOtherMessage.h"
#import "PPTransition.h"
#import <objc/runtime.h>

@interface UINavigationController (PPPresentTransition)<UINavigationControllerDelegate>
@property (nonatomic , strong)PPNavigationControllerDelegateProxy * _pp_delegateProxy ;
@end

@implementation UINavigationController (PPPresentTransition)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method pushM = class_getInstanceMethod(self, @selector(pushViewController:animated:));
        Method pushM_pp = class_getInstanceMethod(self, @selector(_pp_pushViewController:animated:));
        method_exchangeImplementations(pushM, pushM_pp);
        
//        Method delegateM = class_getInstanceMethod(self, @selector(delegate));
//        Method delegateM_pp = class_getInstanceMethod(self, @selector(_pp_delegate));
//        method_exchangeImplementations(delegateM, delegateM_pp);
    });
}

-(void)_pp_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    self.delegate == nil ? self.delegate = self : nil ;
    
    if (!viewController.presenting) {
        viewController.appearMode = UIViewControllerAppearModeWithPush ;
    }else{
        viewController.presenting = NO ;
    }
    if ([self needDeleteViewController:viewController.class]) {
        [self deleteViewController:viewController.class continuousMaxCount:2];
    }
    [self _pp_pushViewController:viewController animated:animated];
}

#pragma mark - 移除连续控制器
/// 只保留连续 continuousCount 个的 cls 类型的控制器，移除前面连续的 cls 类型的控制器
/// @param cls 移除的控制器类型
/// @param maxCount 保留连续最大数量
-(void)deleteViewController:(Class)cls continuousMaxCount:(NSUInteger)maxCount{
    if (self.viewControllers.count <= maxCount || maxCount <= 0) {
        return;
    }
    
    NSMutableArray<UIViewController *> * vcs = [self.viewControllers mutableCopy];
    for (NSUInteger index = vcs.count - maxCount ; index < vcs.count ; index++){
        if (![vcs[index] isMemberOfClass:cls]) {
            return;
        }
    }
   
    NSUInteger count ;
    do {
        count = vcs.count - (maxCount + 1) ;
        if (count >= 0 && [vcs[count] isMemberOfClass:cls]) {
            
            [vcs removeObject:vcs[count]] ;
        }else{
            self.viewControllers = vcs ;
            return;
        }
    } while (count >= 0);
}
-(BOOL)needDeleteViewController:(Class)vc {
    return NO ;
}

#pragma mark - UINavigationControllerDelegate
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    [navigationController setNavigationBarHidden:viewController.hiddenSystemNavigationBarWhenAppear animated:animated];
//}
#pragma mark - getter & setter
-(id<UINavigationControllerDelegate>)_pp_delegate {
    id<UINavigationControllerDelegate> delegate = [self _pp_delegate];
    if (!delegate || ![NSStringFromClass(delegate.class) isEqualToString:NSStringFromClass(PPNavigationControllerDelegateProxy.class)]) {
        delegate = [[PPNavigationControllerDelegateProxy alloc] initWithTarget:delegate navigationController:self] ;
        self.delegate = delegate ;
        self._pp_delegateProxy = delegate ;
    }

    return delegate;
}

-(void)set_pp_delegateProxy:(PPNavigationControllerDelegateProxy *)_pp_delegateProxy {
    objc_setAssociatedObject(self, @selector(_pp_delegateProxy), _pp_delegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(PPNavigationControllerDelegateProxy *)_pp_delegateProxy {
    return objc_getAssociatedObject(self, @selector(_pp_delegateProxy)) ;
}

@end
