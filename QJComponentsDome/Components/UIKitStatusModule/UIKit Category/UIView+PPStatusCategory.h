//
//  UIView+PPStatusCategory.h
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPStatusPublicHeader.h"
#import "PPStatusPropertyMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (PPStatusCategory)

/// 皮肤样式，默认为当前顶部控制器的皮肤状态, 当设置该属性时会影响未设置的子 view 皮肤样式
@property (nonatomic) PPSkinStatusStyle skinStatusStyle;
@property (nonatomic,readonly) PPSkinStatusStyle storageSkinStatusStyle;

/// 是否手动设置了皮肤样式
@property (nonatomic) BOOL isUserSetSkinStatusStyle;

/// 当前 view 是否为自定义的导航view 或 导航栏 subview ,如果为YES，样式受 PPStatusSetModel.navigationBarStyle 控制，否则受 skinStatusStyle
@property (nonatomic) BOOL isCustomNavigationBar;

/// 设置背景色
-(void)setBackgroundColor:(nullable UIColor *)backgroundColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle;

/// 设置当前控件的状态对应的属性信息, 子类可重写该方法，但必须调用 -[super setUIViewStatusMessage:]
-(BOOL)setUIViewStatusMessage:(PPStatusPropertyMessageModel *)message record:(BOOL)record;

/// 重新设置view及 subviews 皮肤颜色
-(void)resetViewAndSubViewSkin;

@end

NS_ASSUME_NONNULL_END
