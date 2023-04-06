//
//  UILabel+PPStatusCategory.h
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (PPStatusCategory)

/// 设置 text color
-(void)setTextColor:(UIColor *)textColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle;
/// 设置 attributed text
-(void)setAttributedText:(NSAttributedString *)attributedText forSkinStyle:(PPSkinStatusStyle)skinStatusStyle;

@end

NS_ASSUME_NONNULL_END
