//
//  UIImageView+PPGif.h
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PPGifImageViewModel;

@interface UIImageView (PPGif)

/// 如果是动图，仅展示第一帧
@property (nonatomic , assign) BOOL isOnlyShowFirstFrame;

/// 当前正在展示的gif
@property (nonatomic , nullable , strong) PPGifImageViewModel * gifImageViewModel;

//判断View是否显示在屏幕上
-(BOOL)isDisplayedInScreen;

@end

NS_ASSUME_NONNULL_END
