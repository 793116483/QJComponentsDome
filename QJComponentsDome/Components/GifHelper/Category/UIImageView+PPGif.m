//
//  UIImageView+PPGif.m
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "UIImageView+PPGif.h"
#import "PPGifPlayerManager.h"
#import "PPGifImageViewModel.h"
#import <objc/runtime.h>

@implementation UIImageView (PPGif)

-(void)setIsOnlyShowFirstFrame:(BOOL)isOnlyShowFirstFrame {
    objc_setAssociatedObject(self, @selector(isOnlyShowFirstFrame), @(isOnlyShowFirstFrame), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)isOnlyShowFirstFrame {
    return [objc_getAssociatedObject(self, @selector(isOnlyShowFirstFrame)) boolValue];
}

-(void)setGifImageViewModel:(PPGifImageViewModel *)gifImageViewModel {
    PPGifImageViewModel * oldModel = self.gifImageViewModel;
    if (oldModel != gifImageViewModel) {
        if (oldModel.imageView == self) {
            // 旧的与view之间断开联系
            oldModel.imageView = nil;
            
            // 从播放管理器中移除
            [[PPGifPlayerManager shareManager] removeGifImageViewModel:oldModel];
        }
        objc_setAssociatedObject(self, @selector(gifImageViewModel), gifImageViewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
-(PPGifImageViewModel *)gifImageViewModel {
    return objc_getAssociatedObject(self, @selector(gifImageViewModel));
}

//判断View是否显示在屏幕上
-(BOOL)isDisplayedInScreen{

    UIView * superView = self.superview;
    if (!self.window || !superView || superView.isHidden || superView.alpha <= 0.00001 || self.isHidden || self.alpha <= 0.00001) {
        return NO;
    }

    //若size 为CGRectZero
    if(CGSizeEqualToSize(self.frame.size, CGSizeZero)){
        return NO;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    //转换view对应window的Rect
    CGRect rect = [self convertRect:self.bounds toView:self.window];
    
    if(CGRectIsEmpty(rect) || CGRectIsNull(rect)){
        return NO;
    }

    //获取 该view 与window 交叉的Rect
    if (CGRectGetMinX(rect) >= CGRectGetMaxX(screenRect) || CGRectGetMaxX(rect) <= CGRectGetMinX(screenRect) ||
        CGRectGetMinY(rect) >= CGRectGetMaxY(screenRect) || CGRectGetMaxY(rect) <= CGRectGetMinY(screenRect)) {
        return NO;
    }
    
    return YES;
}

@end
