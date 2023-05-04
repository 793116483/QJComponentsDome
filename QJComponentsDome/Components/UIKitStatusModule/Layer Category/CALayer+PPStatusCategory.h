//
//  CALayer+PPStatusCategory.h
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PPStatusPublicHeader.h"
#import "PPStatusPropertyMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (PPStatusCategory)

/// 皮肤样式，默认为当前顶部控制器的皮肤状态
@property (nonatomic) PPSkinStatusStyle skinStatusStyle;
@property (nonatomic,readonly) PPSkinStatusStyle storageSkinStatusStyle;

/// 是否手动设置了皮肤样式
@property (nonatomic) BOOL isUserSetSkinStatusStyle;

/// 设置背景色
-(void)setBackgroundColor:(nullable UIColor *)backgroundColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle;
/// 设置边框色
-(void)setBorderColor:(nullable UIColor *)borderColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle;

/// 设置当前控件的状态对应的属性信息, 子类可重写该方法，但必须调用 -[super setUIViewStatusMessage:]
-(BOOL)setCALayerStatusMessage:(PPStatusPropertyMessageModel *)message record:(BOOL)record;

/// 递归,重新设置layer及 sublayers 皮肤颜色
-(void)resetLayerAndSubLayerSkin;

@end

NS_ASSUME_NONNULL_END
