//
//  CAGradientLayer+PPStatusCategory.h
//  PatPat
//
//  Created by lixiao on 2023/3/23.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAGradientLayer (PPStatusCategory)

/// 设置颜色
-(void)setColors:(nullable NSArray *)colors forSkinStyle:(PPSkinStatusStyle)skinStatusStyle;


@end

NS_ASSUME_NONNULL_END
