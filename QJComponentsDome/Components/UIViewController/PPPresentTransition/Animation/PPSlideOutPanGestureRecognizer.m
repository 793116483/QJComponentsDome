//
//  PPSlideOutPanGestureRecognizer.m
//  PatPat
//
//  Created by 杰 on 2022/4/25.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPSlideOutPanGestureRecognizer.h"
#import "UIViewController+PPPresentTransition.h"
#import "UIView+UIViewExtension.h"

@interface PPSlideOutPanGestureRecognizer ()

@property (nonatomic , assign) CGFloat startY;
//@property (nonatomic , assign) CGFloat startOffsetY;
@property (nonatomic , assign) CGFloat startPointY;

@end

@implementation PPSlideOutPanGestureRecognizer

-(instancetype)init {
    if (self = [super initWithTarget:self action:@selector(handleGesture:)]) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //必须返回YES，否则当前手势无法滚动
    return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    // 隐藏键盘
    [self.fromVc.view endEditing:YES];
    
    if (gestureRecognizer == self) {
        CGPoint translation = [self translationInView:self.targetView];
        //判断必须属于竖直方向的拖动才能响应
        BOOL isNotVertical = fabs(translation.x / translation.y) > 1;
//        //在contentOffset.y > 0的时候才响应拖拽关闭手势
//        BOOL mainScrollViewNotAtTop = self.mainScrollView.contentOffset.y > (0.01f-self.mainScrollView.contentInset.top);
        if (isNotVertical ) {
            return NO;
        }
    }
    return YES;
}

//拖拽手势处理
- (void)handleGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:[self.targetView superview]];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.startY = self.targetView.y;
            self.startPointY = translation.y;
//            self.startOffsetY = -999999;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            //在contentOffset.y > 0的时候才响应拖拽关闭手势
            BOOL mainScrollViewNotAtTop = self.mainScrollView.contentOffset.y > (0.01f-self.mainScrollView.contentInset.top);
            if (mainScrollViewNotAtTop) {
                self.startPointY = translation.y;
//                if (self.startOffsetY != -999999) {
//                    self.mainScrollView.contentOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.startOffsetY - (translation.y - self.startPointY));
//                }
                return;
            }
            CGFloat y = self.startY + (translation.y - self.startPointY);
            if (y <= self.startY) {
                self.targetView.y = self.startY ;
//                if (self.startOffsetY != -999999) {
//                    self.mainScrollView.contentOffset = CGPointMake(self.mainScrollView.contentOffset.x, self.startOffsetY - (translation.y - self.startPointY));
//                }
                return;
            }
            
            self.targetView.y = y ;
            self.mainScrollView.scrollEnabled = NO;
//            self.startOffsetY = self.mainScrollView.contentOffset.y;

            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            self.mainScrollView.scrollEnabled = YES;
            
            if (self.targetView.y - self.startY >= self.targetView.height*0.4) {
                [self.fromVc disappearViewController];
            }else{
                //手势取消，恢复原貌
                [UIView animateWithDuration:0.2 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.targetView.y = self.startY;
                } completion:^(BOOL finished) {
                }];
            }
            break;
        }
        default:
            break;
    }
}


-(void)setMainScrollViewFromView:(UIView *)view {
    if (self.mainScrollView) {
        return;
    }
    if ([view isKindOfClass:[UIScrollView class]]) {
        self.mainScrollView = (UIScrollView*)view;
        return;
    }
    for (UIView * subView in view.subviews) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            self.mainScrollView = (UIScrollView*)subView;
            return;
        }
    }
    for (UIView * subView in view.subviews) {
        [self setMainScrollViewFromView:subView];
        if (self.mainScrollView) {
            return;
        }
    }
}

-(UIView *)targetView {
    if (!_targetView) {
        return self.view;
    }
    return _targetView;
}

@end
