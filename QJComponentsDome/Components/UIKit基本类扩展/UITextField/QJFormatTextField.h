//
//  QJFormatTextField.h
//  QJComponentsDome
//
//  Created by 杰 on 2022/7/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJFormatTextField : UITextField

/// 格式:XXX-XXX-XXX, X代表一个字符,其他的属于格式符
@property (nonatomic,copy) NSString * format;

@end

NS_ASSUME_NONNULL_END
