//
//  PPSlideOutPanGestureRecognizer.h
//  PatPat
//
//  Created by 杰 on 2022/4/25.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPSlideOutPanGestureRecognizer : UIPanGestureRecognizer<UIGestureRecognizerDelegate>

@property (nonatomic,weak)UIViewController * fromVc;
@property (nonatomic,weak)UIView * targetView;

@property (nonatomic,weak)UIScrollView * mainScrollView;

/// 查找并设置 mainScrollView
-(void)setMainScrollViewFromView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
