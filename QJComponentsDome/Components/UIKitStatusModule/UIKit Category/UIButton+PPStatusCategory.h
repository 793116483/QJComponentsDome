//
//  UIButton+PPStatusCategory.h
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PPButtonStatusMessage;

@interface UIButton (PPStatusCategory)

- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;
- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;
- (void)setBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;
- (void)setAttributedTitle:(nullable NSAttributedString *)title forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;

@end


@interface PPButtonStatusMessage: PPStatusPropertyMessageModel

@property (nonatomic) UIControlState state;

+ (instancetype)messageWithTitle:(nullable NSString *)title forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;
+ (instancetype)messageWithTitleColor:(nullable UIColor *)color forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;
+ (instancetype)messageWithImage:(nullable UIImage *)image forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;
+ (instancetype)messageWithBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;
+ (instancetype)messageWithAttributedTitle:(nullable NSAttributedString *)title forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;

@end

NS_ASSUME_NONNULL_END
