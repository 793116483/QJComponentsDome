//
//  UIViewController+PPPresentTransition.h
//  PatPat
//
//  Created by 杰 on 2021/3/26.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

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
    
} UIViewControllerAppearMode;

typedef void(^UIViewControllerCompletionBlock)(void);

@interface UIViewController (PPPresentTransition)

/// 当前控制器将要显示时，隐藏系统导航栏，默认为 NO
/// 注意：不会影响其他控制器显示导航栏
@property (nonatomic , assign) BOOL hiddenSystemNavigationBarWhenAppear ;

#pragma mark 展示相关

/// 展示方式
@property (nonatomic , readonly) UIViewControllerAppearMode appearMode ;

/// 是否自定义转场动画
@property (nonatomic , readonly) BOOL hasCustomTransition ;

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

NS_ASSUME_NONNULL_END
