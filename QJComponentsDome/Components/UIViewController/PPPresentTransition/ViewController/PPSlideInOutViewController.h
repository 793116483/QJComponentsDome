//
//  PPSlideInOutViewController.h
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPSlideInOutViewController : UIViewController

/// 控制器 view 的大小
@property (nonatomic , assign) CGSize viewControllerSize ;

/// 以SlideInOut方式显示的控制器
@property (nonatomic , readonly) UIViewController * viewController ;

/// viewController 是否已经显示了
@property (nonatomic , readonly) BOOL viewControllerShowed ;

-(instancetype)initWithViewController:(UIViewController *)viewController;

/// 显示
-(void)showViewControllerAnimated:(BOOL)animation complation:(void(^)(void))complation;

/// 隐藏 viewController
-(void)hiddenViewControllerAnimated:(BOOL)animation complation:(void(^)(void))complation;

@end

NS_ASSUME_NONNULL_END
