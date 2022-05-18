//
//  UIViewController+PPOtherMessage.h
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PPSlideInOutViewController;

@interface UIViewController (PPOtherMessage)

@property (nonatomic , strong) UIView * snapshotView ;

@property (nonatomic , assign) BOOL presenting ;

/// 展示方式
@property (nonatomic , assign) NSInteger appearMode ;

/// 是否自定义转场动画
@property (nonatomic , assign) BOOL hasCustomTransition ;

/// 当前控制器是
@property (nonatomic , weak) PPSlideInOutViewController * slideInOutFatherViewController ;

-(UINavigationController *)navController ;

//当前最上层的导航栏控制器
- (UINavigationController *)pp_currentTopNavigationController ;

//当前最上层的视图控制器
- (UIViewController *)pp_currentTopController ;

/// 在view中 解决 edgePan 与 UIScrollView 及其子类的 pan 手势冲突，edgePan手势优先
-(void)resolveConflictForEdgeGesture:(UIGestureRecognizer *)edgePan inSubView:(UIView *)view ;

@end

NS_ASSUME_NONNULL_END
