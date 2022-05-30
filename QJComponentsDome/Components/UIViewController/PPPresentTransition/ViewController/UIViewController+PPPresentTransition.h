//
//  UIViewController+PPPresentTransition.h
//  PatPat
//
//  Created by 杰 on 2021/3/26.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    /// 从未被展示
    UIViewControllerAppearModeNever ,
    
    /// 以 modal 方式展示
    UIViewControllerAppearModeWithModal ,
    
    /// 以 push 方式展示
    UIViewControllerAppearModeWithPush ,
    
    /// 以子控制器方式展示，被添加到 parent ViewController
    UIViewControllerAppearModeWithChild ,
    
    /// 以底部半弹窗方式展示
    UIViewControllerAppearModeWithSlideInOut ,
    
} UIViewControllerAppearMode;

typedef void(^UIViewControllerCompletionBlock)(void);

@interface UIViewController (PPPresentTransition)

/// 当前控制器将要显示时，隐藏系统导航栏，默认为 NO
/// 注意：不会影响其他控制器显示导航栏
@property (nonatomic , assign) BOOL hiddenSystemNavigationBarWhenAppear ;

#pragma mark 展示相关

/// 展示方式
@property (nonatomic , readonly) UIViewControllerAppearMode appearMode ;

/// 显示控制器
/// @param viewController 需要展示的控制器
/// @param animation 是否需要动画
/// @param appearMode 以什么方式展示
/// @param completion 显示完成回调 , 如果 viewController 没有展示时不会回调
-(void)appearViewController:(UIViewController *)viewController
                  animation:(BOOL)animation
             withAppearMode:(UIViewControllerAppearMode)appearMode
                 completion: (nullable UIViewControllerCompletionBlock)completion;

-(void)appearViewController:(UIViewController *)viewController
                  animation:(BOOL)animation
             withAppearMode:(UIViewControllerAppearMode)appearMode ;

-(void)appearViewController:(UIViewController *)viewController
             withAppearMode:(UIViewControllerAppearMode)appearMode ;

-(void)appearCurrentControllerAnimation:(BOOL)animation
                         withAppearMode:(UIViewControllerAppearMode)appearMode
                             completion: (nullable UIViewControllerCompletionBlock)completion;
-(void)appearCurrentControllerAnimation:(BOOL)animation
                         withAppearMode:(UIViewControllerAppearMode)appearMode ;
-(void)appearCurrentControllerWithAppearMode:(UIViewControllerAppearMode)appearMode ;


/// 移除当前控制器
/// @param animation 是否需要动画
/// @param completion 完成回调
-(void)disappearViewControllerAnimated:(BOOL)animation
                            completion: (nullable UIViewControllerCompletionBlock)completion;
-(void)disappearViewControllerAnimated:(BOOL)animation ;
-(void)disappearViewController ;

@end


#pragma mark SlideInOut ViewController 相关

static inline BOOL isIPhoneXSeries() {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}

#define kScreenWidth            [UIScreen mainScreen].bounds.size.width // MainScreen Heigh
#define kScreenHeight           [UIScreen mainScreen].bounds.size.height  // MainScreen Width
#define kNavigationBarHeight           (isIPhoneXSeries()?88.f:64.f)

#define kSlideInOutNavigationBarHeight 44
#define kSlideInOutViewControllerMaxHeight (kScreenHeight - kNavigationBarHeight - 15)

@interface UIViewController (PPSlideInOut)

/// UIViewControllerAppearModeWithSlideInOut 展示方式时的导航栏，否则为nil；title可随设置系统导航内容变动
@property (nonatomic, strong, nullable, readonly) PPNavigationBar * slideInOutNavigationBar ;

/// 控制器 view 的大小，默认为 CGSizeMake(kScreenWidth, kSlideInOutViewControllerMaxHeight)
@property (nonatomic , assign ) CGSize slideInOutViewSize ;

/// 当键盘显示时，view向上偏移y值
@property (nonatomic , assign ) CGFloat slideInOutViewMoveOffsetYWhenKeyboardShow ;

/// 展示当前控制器时，是否需要隐藏前一个以 UIViewControllerAppearModeWithSlideInOut 展示方式的控制器，默认为YES
@property (nonatomic , assign ) BOOL hiddenPreSlideInOutViewControllerWhenAppear ;

/// 手动显示出半弹窗
-(void)showSlideInOutViewIfNeed ;

@end

NS_ASSUME_NONNULL_END
