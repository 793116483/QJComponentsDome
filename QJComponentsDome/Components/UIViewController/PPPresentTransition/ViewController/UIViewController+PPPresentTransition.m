//
//  UIViewController+PPPresentTransition.m
//  PatPat
//
//  Created by 杰 on 2021/3/26.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "UIViewController+PPPresentTransition.h"
#import "PPSlideInOutViewController.h"
#import "UIViewController+PPOtherMessage.h"
#import "PPTransition.h"
#import <objc/runtime.h>

@interface UIViewController (PPSlideInOut)

/// 方法声明
-(void)appearSlideInOutWithViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(nullable UIViewControllerCompletionBlock)completion ;

-(void)disappearSlideInOutViewControllerAnimated:(BOOL)animation completion:(UIViewControllerCompletionBlock)completion;

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
        
        if (flag) {
            [nav.view.layer addAnimation:[PPTransition presentTransition] forKey:@"present"];
        }
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
        
        toViewController.presenting = NO ;
    }
}

-(void)_pp_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    if (self.hasCustomTransition && self.appearMode == UIViewControllerAppearModeWithModal) {
        if (flag) {
            [self.navigationController.view.layer addAnimation:[PPTransition dismissTransition] forKey:@"dismiss"];
        }
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
/// @param viewController 针对哪种控制器类的实例
+(BOOL)isForbidAddTransitionForViewControllerClass:(Class)cls {
    if (!cls || ![NSStringFromClass(cls) hasPrefix:@"PP"] // 所有非自定义的类都不添加自定义转场动画
             || [cls isKindOfClass:UIAlertController.class]
             || [cls isKindOfClass:UIActivityViewController.class]
             || [cls isKindOfClass:UINavigationController.class]
             || [cls isKindOfClass:UIImagePickerController.class]
             ) {
        return YES;
    }
    NSArray * forbidViewControllers = @[@"UIAlertController",@"UIActivityViewController",@"SCSChatLoadingViewController",@"SCSAlertController",@"MFMailComposeViewController",@"MFMessageComposeViewController",@"CardIOPaymentViewController",@"PPImagePickerController"];
    return [forbidViewControllers containsObject:NSStringFromClass(cls)];
}

-(void)appearViewController:(UIViewController *)viewController
                      animation:(BOOL)animation
                withAppearMode:(UIViewControllerAppearMode)appearMode
                 completion:(nullable UIViewControllerCompletionBlock)completion {
    
    if (!viewController) return;
    
    UINavigationController * nav = [self navController];
    if (viewController.hiddenPreSlideInOutViewControllerWhenAppear && [nav.viewControllers.lastObject isKindOfClass:[PPSlideInOutViewController class]]) {

        PPSlideInOutViewController * slidInOutVc = (PPSlideInOutViewController *)nav.viewControllers.lastObject;
        
        if (slidInOutVc.viewControllerShowed) {
            // 先隐藏前一个弹窗，再展示新的控制器
            [slidInOutVc hiddenViewControllerAnimated:slidInOutVc.viewControllerShowed complation:^{
                [self appearViewController:viewController animation:animation withAppearMode:appearMode completion:completion];
            }];
            return;
        }
    }

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
        case UIViewControllerAppearModeWithSlideInOut:
        {
            [self appearSlideInOutWithViewController:viewController animated:animation completion:completion];
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
    
    if ([self isKindOfClass:[PPSlideInOutViewController class]]) {
        PPSlideInOutViewController * slidInOutVc = (PPSlideInOutViewController *)self;
        if (slidInOutVc.viewControllerShowed) {
            [slidInOutVc.viewController disappearViewControllerAnimated:animation completion:completion];
            return;
        }
    }
    
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
        case UIViewControllerAppearModeWithSlideInOut:
        {
            [self disappearSlideInOutViewControllerAnimated:animation completion:completion];
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

#pragma mark getter & setter
-(void)setHiddenSystemNavigationBarWhenAppear:(BOOL)hiddenSystemNavigationBarWhenAppear {
    objc_setAssociatedObject(self, @selector(hiddenSystemNavigationBarWhenAppear), @(hiddenSystemNavigationBarWhenAppear), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(BOOL)hiddenSystemNavigationBarWhenAppear {
    return [objc_getAssociatedObject(self, @selector(hiddenSystemNavigationBarWhenAppear)) boolValue] ;
}

-(UIViewControllerAppearMode)appearMode {
    NSNumber * mode = objc_getAssociatedObject(self, @selector(appearMode)) ;
    return mode ? (UIViewControllerAppearMode)[mode intValue] : UIViewControllerAppearModeNever ;
}
@end


#pragma mark - SlideInOut ViewController 相关

@implementation UIViewController (PPSlideInOut)

-(void)appearSlideInOutWithViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(nullable UIViewControllerCompletionBlock)completion{
    
    if (!viewController) {
        return;
    }
    
    viewController.appearMode = UIViewControllerAppearModeWithSlideInOut;
    PPSlideInOutViewController * slidInOutVc = [[PPSlideInOutViewController alloc] initWithViewController:viewController];
    
    UIViewController * topVc = [self pp_currentTopController];
    if ([topVc isKindOfClass:[PPSlideInOutViewController class]] && viewController.hiddenPreSlideInOutViewControllerWhenAppear) {
        // 先隐藏前一个弹窗，再显示新的弹窗
        PPSlideInOutViewController * topSlidInOutVc = (PPSlideInOutViewController *)topVc;
        [topSlidInOutVc hiddenViewControllerAnimated:topSlidInOutVc.viewControllerShowed complation:^{
            
            slidInOutVc.snapshotView = [topSlidInOutVc.snapshotView snapshotViewAfterScreenUpdates:YES];
            [slidInOutVc showViewControllerAnimated:animated complation:completion];
        }];
    }else{
        [slidInOutVc showViewControllerAnimated:animated complation:completion];
    }
}

-(void)disappearSlideInOutViewControllerAnimated:(BOOL)animation completion:(UIViewControllerCompletionBlock)completion {
    [self.slideInOutFatherViewController hiddenViewControllerAnimated:animation complation:^{
        [self.slideInOutFatherViewController disappearViewControllerAnimated:NO completion:completion];
    }];
}

#pragma mark - getter & setter
-(void)setSlideInOutNavigationBar:(PPNavigationBar * _Nonnull)slideInOutNavigationBar {
    objc_setAssociatedObject(self, @selector(slideInOutNavigationBar), slideInOutNavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(PPNavigationBar *)slideInOutNavigationBar {
    PPNavigationBar * navBar = objc_getAssociatedObject(self, @selector(slideInOutNavigationBar));
    if (!navBar && self.appearMode == UIViewControllerAppearModeWithSlideInOut) {
        navBar = [[PPNavigationBar alloc] initWithViewController:self];
        self.slideInOutNavigationBar = navBar;
    }
    return navBar;
}

-(void)setSlideInOutViewSize:(CGSize)slideInOutViewSize {
    if (slideInOutViewSize.height > kSlideInOutViewControllerMaxHeight) {
        // 最大高度
        slideInOutViewSize.height = kSlideInOutViewControllerMaxHeight;
    }
    self.slideInOutFatherViewController.slideInOutViewSize = slideInOutViewSize;
    objc_setAssociatedObject(self, @selector(slideInOutViewSize), [NSValue valueWithCGSize:slideInOutViewSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(CGSize)slideInOutViewSize {
    NSValue * value = objc_getAssociatedObject(self, @selector(slideInOutViewSize));
    if (!value) {
        return CGSizeMake(kScreenWidth, kSlideInOutViewControllerMaxHeight);
    }
    return [value CGSizeValue];
}

-(void)setSlideInOutViewMoveOffsetYWhenKeyboardShow:(CGFloat)slideInOutViewMoveOffsetYWhenKeyboardShow {
    objc_setAssociatedObject(self, @selector(slideInOutViewMoveOffsetYWhenKeyboardShow), @(slideInOutViewMoveOffsetYWhenKeyboardShow), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(CGFloat)slideInOutViewMoveOffsetYWhenKeyboardShow {
    return [objc_getAssociatedObject(self, @selector(slideInOutViewMoveOffsetYWhenKeyboardShow)) floatValue];
}

-(void)setHiddenPreSlideInOutViewControllerWhenAppear:(BOOL)hiddenPreSlideInOutViewControllerWhenAppear {
    objc_setAssociatedObject(self, @selector(hiddenPreSlideInOutViewControllerWhenAppear), @(hiddenPreSlideInOutViewControllerWhenAppear), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(BOOL)hiddenPreSlideInOutViewControllerWhenAppear {
    NSNumber * hidden = objc_getAssociatedObject(self, @selector(hiddenPreSlideInOutViewControllerWhenAppear));
    if (!hidden) {
        return YES;
    }
    return [hidden boolValue];
}

@end
