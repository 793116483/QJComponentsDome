//
//  PPStatusPropertyMessageModel.h
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    // CALayer 属性
    PPStatusCALayerPropertyTypeBackgroundColor,
    PPStatusCALayerPropertyTypeBorderColor,
    
    // CAGradientLayer 属性
    PPStatusCAGradientLayerPropertyTypeColors,

    // UIView
    PPStatusUIViewPropertyTypeBackgroundColor,
    
    // UILabel
    PPStatusUILabelPropertyTypeTextColor,
    PPStatusUILabelPropertyTypeAttributedText,
    
    // UITextField
    PPStatusUITextFieldPropertyTypeTextColor,
    PPStatusUITextFieldPropertyTypeAttributedText,
    
    // UITextView
    PPStatusUITextViewPropertyTypeTextColor,
    PPStatusUITextViewPropertyTypeAttributedText,
    
    // UIImageView
    PPStatusUIImageViewPropertyTypeImage,
    
    // UIButton
    PPStatusUIButtonPropertyTypeTitle,
    PPStatusUIButtonPropertyTypeTitleColor,
    PPStatusUIButtonPropertyTypeImage,
    PPStatusUIButtonPropertyTypeBackgroundImage,
    PPStatusUIButtonPropertyTypeAttributedTitle,
    
} PPStatusUIKitPropertyType;


@interface PPStatusPropertyMessageModel : NSObject

@property (nonatomic) PPSkinStatusStyle skinStatusStyle;
@property (nonatomic) PPStatusUIKitPropertyType propertyType;
@property (nonatomic, nullable) id propertyValue;

+ (instancetype)messageWithPropertyType:(PPStatusUIKitPropertyType)propertyType
                          propertyValue:(id)propertyValue
                        skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle;

// 如果有继承子类需要重写方法
-(NSString *)hashKey;

@end

NS_ASSUME_NONNULL_END
