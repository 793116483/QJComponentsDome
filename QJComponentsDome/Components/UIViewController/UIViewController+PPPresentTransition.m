//
//  UIViewController+PPPresentTransition.m
//  PatPat
//
//  Created by 杰 on 2021/3/26.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "UIViewController+PPPresentTransition.h"
#import <objc/runtime.h>

@interface UIViewController (snapshotView)

//@property (nonatomic , strong) UIView * snapshotView ;

@property (nonatomic , assign) BOOL presenting ;

@end
@implementation UIViewController (snapshotView)
//-(void)setSnapshotView:(UIView *)snapshotView {
//    objc_setAssociatedObject(self, @selector(snapshotView), snapshotView, OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
//}
//-(UIView *)snapshotView {
//    snapshotView = [[UIApplication sharedApplication].keyWindow snapshotViewAfterScreenUpdates:YES];
//    return objc_getAssociatedObject(self, @selector(snapshotView)) ;
//}

-(void)setPresenting:(BOOL)presenting {
    objc_setAssociatedObject(self, @selector(presenting), @(presenting), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(BOOL)presenting{
    return [objc_getAssociatedObject(self, @selector(presenting)) boolValue];
}
@end


@implementation UIViewController (PPPresentTransition)

#pragma mark lifecycle
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method presentM = class_getInstanceMethod(self, @selector(presentViewController:animated:completion:));
        Method presentM_pp = class_getInstanceMethod(self, @selector(_pp_presentViewController:animated:completion:));
        method_exchangeImplementations(presentM, presentM_pp);
        
        Method dismissM = class_getInstanceMethod(self, @selector(dismissViewControllerAnimated:completion:));
        Method dismissM_pp = class_getInstanceMethod(self, @selector(_pp_dismissViewControllerAnimated:completion:));
        method_exchangeImplementations(dismissM, dismissM_pp);
        
        Method addChildM = class_getInstanceMethod(self, @selector(addChildViewController:));
        Method addChildM_pp = class_getInstanceMethod(self, @selector(_pp_addChildViewController:));
        method_exchangeImplementations(addChildM, addChildM_pp);
        
        Method viewWillAppearM = class_getInstanceMethod(self, @selector(viewWillAppear:));
        Method viewWillAppearM_pp = class_getInstanceMethod(self, @selector(_pp_viewWillAppear:));
        method_exchangeImplementations(viewWillAppearM, viewWillAppearM_pp);
    });
}

-(void)_pp_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(UIViewControllerCompletionBlock)completion {
    
    UIViewController * toViewController = viewControllerToPresent ;
    while ([toViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController * navVc = (UINavigationController *)toViewController ;
        toViewController = navVc.viewControllers.lastObject ;
    }
    
    toViewController.presenting = YES ;
    
    toViewController.appearMode = UIViewControllerAppearModeWithModal ;
    
    if (![[self class] isForbidAddTransitionForViewControllerClass:toViewController.class]) {
        toViewController.hasCustomTransition = YES ;
        UINavigationController * nav = [self navController];
        
        [nav.view.layer addAnimation:[self.class transitionWithAppear:YES animation:flag] forKey:@"present"];
        [nav pushViewController:toViewController animated:NO];
        
        if (flag && completion) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion();
            });
        }else if (completion){
            completion();
        }
        
    }else{
        viewControllerToPresent.appearMode = UIViewControllerAppearModeWithModal ;

        [self _pp_presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
    
    toViewController.presenting = NO ;
}

-(void)_pp_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    if (self.hasCustomTransition && self.appearMode == UIViewControllerAppearModeWithModal) {
        
        [self.navigationController.view.layer addAnimation:[self.class transitionWithAppear:NO animation:flag] forKey:@"dismiss"];
        [self.navigationController popViewControllerAnimated:NO];
        
        if (flag && completion) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion();
            });
        }else if (completion){
            completion();
        }
        
    } else {
        [self _pp_dismissViewControllerAnimated:flag completion:completion];
    }
    [self clearData];
}

-(void)_pp_addChildViewController:(UIViewController *)childController {
    
    childController.presenting = YES ;
    
    childController.appearMode = UIViewControllerAppearModeWithChild ;
    [self _pp_addChildViewController:childController];
    
    childController.presenting = NO ;
}

-(void)_pp_viewWillAppear:(BOOL)animated {
    [self _pp_viewWillAppear:animated];
    
    [self resolveConflictForEdgeGesture:self.navigationController.interactivePopGestureRecognizer inSubView:self.view];
}

#pragma mark 展示相关

/// 是否禁止添加自定义转场动画
/// @param cls 针对哪种控制器类的实例
+(BOOL)isForbidAddTransitionForViewControllerClass:(Class)cls {
    if (!cls || ![NSStringFromClass(cls) hasPrefix:@"PP"] // 所有非自定义的类都不添加自定义转场动画
             || [cls isKindOfClass:UIAlertController.class]
             || [cls isKindOfClass:UIActivityViewController.class]
             || [cls isKindOfClass:UINavigationController.class]
             || [cls isKindOfClass:UIImagePickerController.class]
             ) {
        return YES;
    }
    NSArray * forbidViewControllers = @[@"UIAlertController",@"UIActivityViewController",@"MFMailComposeViewController",@"MFMessageComposeViewController"];
    return [forbidViewControllers containsObject:NSStringFromClass(cls)];
}

+(CATransition *)transitionWithAppear:(BOOL)isAppear animation:(BOOL)animation{
    CATransition * transition = [CATransition animation];
    transition.duration = animation ? 0.25f : 0.0 ;
    transition.type = isAppear ? kCATransitionMoveIn : kCATransitionReveal ;
    transition.subtype = isAppear ? kCATransitionFromTop : kCATransitionFromBottom ;
    transition.removedOnCompletion = YES ;
    
    return transition ;
}

-(UINavigationController *)navController {
    UINavigationController * navc = [self isKindOfClass:UINavigationController.class] ? (UINavigationController *)self : self.navigationController ;
    if (!navc) navc = [self pp_currentTopNavigationController];
    
    return navc;
}
//当前最上层的导航栏控制器
- (UINavigationController *)pp_currentTopNavigationController {
    UITabBarController *rootTabController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav = rootTabController.selectedViewController;
    UIViewController* presentedCtl = nav;
    while (presentedCtl.presentedViewController) {
        presentedCtl = presentedCtl.presentedViewController;
    }
    UIViewController *topCtl = nil;
    if ([presentedCtl isKindOfClass:[UINavigationController class]]) {
        UINavigationController *baseNav = (UINavigationController *)presentedCtl;
        topCtl = baseNav.viewControllers.lastObject;
        while (topCtl.presentedViewController) {
            topCtl = topCtl.presentedViewController;
        }
    } else {
        topCtl = presentedCtl;
        while (topCtl.presentedViewController) {
            topCtl = topCtl.presentedViewController;
        }
    }
    return (UINavigationController*)topCtl.navigationController;
}

-(void)appearViewController:(UIViewController *)viewController
                      animation:(BOOL)animation
                withAppearMode:(UIViewControllerAppearMode)appearMode
                 completion:(nullable UIViewControllerCompletionBlock)completion {
    
    if (!viewController) return;
    
    switch (appearMode) {
        case UIViewControllerAppearModeWithModal:
        {
            [self presentViewController:viewController animated:animation completion:completion];
            break;
        }
        case UIViewControllerAppearModeWithPush:
        {
            [[self navController] pushViewController:viewController animated:animation];
            
            if (animation && completion) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion();
                });
            }else if (completion){
                completion();
            }
            break;
        }
        case UIViewControllerAppearModeWithChild:
        {
            viewController.view.alpha = animation ? 0.0 : 1.0 ;
            [self addChildViewController:viewController];
            [self.view addSubview:viewController.view];
            
            if (animation) {
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.view.alpha = 1.0 ;
                }completion:^(BOOL finished) {
                    [viewController didMoveToParentViewController:self];
                    if (completion) {
                        completion();
                    }
                }];
            }else{
                [viewController didMoveToParentViewController:self];
                if (completion) {
                    completion();
                }
            }
            break;
        }
        default:
            break;
    }
}
-(void)appearViewController:(UIViewController *)viewController animation:(BOOL)animation withAppearMode:(UIViewControllerAppearMode)appearMode {
    [self appearViewController:viewController animation:animation withAppearMode:appearMode completion:nil];
}
-(void)appearViewController:(UIViewController *)viewController withAppearMode:(UIViewControllerAppearMode)appearMode {
    [self appearViewController:viewController animation:YES withAppearMode:appearMode];
}
-(void)appearCurrentControllerAnimation:(BOOL)animation withAppearMode:(UIViewControllerAppearMode)appearMode completion:(UIViewControllerCompletionBlock)completion {
    
    [[self pp_currentTopNavigationController].viewControllers.lastObject appearViewController:self animation:animation withAppearMode:appearMode completion:completion];
}
-(void)appearCurrentControllerAnimation:(BOOL)animation withAppearMode:(UIViewControllerAppearMode)appearMode {
    [self appearCurrentControllerAnimation:animation withAppearMode:appearMode completion:nil];
}
-(void)appearCurrentControllerWithAppearMode:(UIViewControllerAppearMode)appearMode {
    [self appearCurrentControllerAnimation:YES withAppearMode:appearMode];
}


-(void)disappearViewControllerAnimated:(BOOL)animation completion:(UIViewControllerCompletionBlock)completion{
    
    switch (self.appearMode) {
        case UIViewControllerAppearModeWithModal:
        {
            [self dismissViewControllerAnimated:animation completion:completion];
            break;
        }
        case UIViewControllerAppearModeWithPush:
        {
            UIViewController * vc = nil;
            for (UIViewController * viewController in self.navigationController.viewControllers.reverseObjectEnumerator) {
                if (self == vc) {
                    vc = viewController;
                    break;
                }
                vc = viewController ;
                [viewController clearData] ;
            }
            [self.navigationController popToViewController:vc animated:animation];
            if (animation && completion) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion();
                });
            }else if (completion){
                completion();
            }
            break;
        }
        case UIViewControllerAppearModeWithChild:
        {
            if (animation) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.view.alpha = 0.0 ;
                }completion:^(BOOL finished) {
                    [self willMoveToParentViewController:nil];
                    [self.view removeFromSuperview];
                    [self removeFromParentViewController];
                    if (completion) {
                        completion();
                    }
                }];
            }else{
                [self willMoveToParentViewController:nil];
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                if (completion) {
                    completion();
                }
            }
            break;
        }
        default:
        {
            if (self == [UIApplication sharedApplication].keyWindow.rootViewController) {
                [self dismissViewControllerAnimated:animation completion:completion];
            }
            break;
        }
    }
    
    [self clearData] ;
}
-(void)disappearViewControllerAnimated:(BOOL)animation {
    [self disappearViewControllerAnimated:animation completion:nil];
}
-(void)disappearViewController {
    [self disappearViewControllerAnimated:YES];
}

-(void)clearData {
    self.appearMode = UIViewControllerAppearModeNever ;
    self.hasCustomTransition = NO ;
}

#pragma mark 侧滑相关

/// 在view中 解决 edgePan 与 UIScrollView 及其子类的 pan 手势冲突，edgePan手势优先
-(void)resolveConflictForEdgeGesture:(UIGestureRecognizer *)edgePan inSubView:(UIView *)view {
    if (!edgePan) {
        return;
    }
    if ([view convertRect:view.frame toView:self.view].origin.x > 8) { // 不是在边缘的view不需要处理手势冲突
        return;
    }
    
    if ([view isKindOfClass:UIScrollView.class]) {
        UIScrollView * scr = (UIScrollView *)view;
        [scr.panGestureRecognizer requireGestureRecognizerToFail:edgePan];
    }
    for (UIView * subView in view.subviews) {
        [self resolveConflictForEdgeGesture:edgePan inSubView:subView];
    }
}

#pragma mark getter & setter
-(void)setHiddenSystemNavigationBarWhenAppear:(BOOL)hiddenSystemNavigationBarWhenAppear {
    objc_setAssociatedObject(self, @selector(hiddenSystemNavigationBarWhenAppear), @(hiddenSystemNavigationBarWhenAppear), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(BOOL)hiddenSystemNavigationBarWhenAppear {
    return [objc_getAssociatedObject(self, @selector(hiddenSystemNavigationBarWhenAppear)) boolValue] ;
}

-(void)setAppearMode:(UIViewControllerAppearMode)appearMode {
    objc_setAssociatedObject(self, @selector(appearMode), @(appearMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(UIViewControllerAppearMode)appearMode {
    NSNumber * mode = objc_getAssociatedObject(self, @selector(appearMode)) ;
    return mode ? (UIViewControllerAppearMode)[mode intValue] : UIViewControllerAppearModeNever ;
}

-(void)setHasCustomTransition:(BOOL)hasCustomTransition {
    objc_setAssociatedObject(self, @selector(hasCustomTransition), @(hasCustomTransition), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(BOOL)hasCustomTransition {
    return [objc_getAssociatedObject(self, @selector(hasCustomTransition)) boolValue] ;
}

@end


#pragma mark - UINavigationController 相关

@interface PPNavigationControllerDelegateProxy : NSProxy <UINavigationControllerDelegate>
@property (nonatomic, weak , readonly) id target;
@property (nonatomic, weak , readonly) UINavigationController * navigationController;
@end
@implementation PPNavigationControllerDelegateProxy
@synthesize target = _target , navigationController = _navigationController ;

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
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController setNavigationBarHidden:viewController.hiddenSystemNavigationBarWhenAppear animated:animated];
}
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
