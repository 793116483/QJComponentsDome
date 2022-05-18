//
//  UIViewController+PPOtherMessage.m
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "UIViewController+PPOtherMessage.h"
#import "PPWeakViewController.h"
#import "UIViewController+PPPresentTransition.h"
#import <objc/runtime.h>

@implementation UIViewController (PPOtherMessage)

#pragma mark getter & setter

-(void)setSnapshotView:(UIView *)snapshotView {
    objc_setAssociatedObject(self, @selector(snapshotView), snapshotView, OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(UIView *)snapshotView {
    return objc_getAssociatedObject(self, @selector(snapshotView)) ;
}

-(void)setPresenting:(BOOL)presenting {
    objc_setAssociatedObject(self, @selector(presenting), @(presenting), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}
-(BOOL)presenting{
    return [objc_getAssociatedObject(self, @selector(presenting)) boolValue];
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

-(void)setSlideInOutFatherViewController:(PPSlideInOutViewController *)slideInOutFatherViewController {
    PPWeakViewController * weakVc = [PPWeakViewController new];
    weakVc.vc = slideInOutFatherViewController;
    objc_setAssociatedObject(self, @selector(slideInOutFatherViewController), weakVc, OBJC_ASSOCIATION_RETAIN) ;
}
-(PPSlideInOutViewController *)slideInOutFatherViewController{
    PPWeakViewController * weakVc = objc_getAssociatedObject(self, @selector(slideInOutFatherViewController));
    return (PPSlideInOutViewController *)weakVc.vc;
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

//当前最上层的视图控制器
- (UIViewController *)pp_currentTopController {
    UITabBarController *rootTabController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (![rootTabController isKindOfClass:UITabBarController.class]) {
        return nil;  // 临时方案
    }
    UINavigationController *nav = rootTabController.selectedViewController;
    UIViewController *presentedCtl = nav;
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
    return topCtl;
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

@end


