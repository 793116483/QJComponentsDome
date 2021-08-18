//
//  QJBaseModel.h
//  QJSocketDome(环信SDK)
//
//  Created by 瞿杰 on 2019/12/8.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJBaseModel : NSObject


/// cell 样式 ，默认为 UITableViewCellStyleSubtitle
@property (nonatomic , assign) UITableViewCellStyle style ;
/// 当 cell 可以选中时，才显示选中背景，默认为 YES
@property (nonatomic , assign) BOOL showSelectBacground ;

@property (nonatomic , strong , nullable) UIImage * image ;
@property (nonatomic , copy , nullable) NSString * title ;
@property (nonatomic , copy , nullable) NSString * hintText ;
/** 是否是版本更新 */
@property(nonatomic, assign) BOOL isUpgrade;
@property (nonatomic , copy , nullable) NSString * subTitle ;
/// 分割线的样式 , 默认为 UIEdgeInsetsMake(0,15,0,0)
@property (nonatomic , assign) UIEdgeInsets separatorInset ;

+(instancetype)modelWithImage:(nullable UIImage *)image
                        title:(nullable NSString *)title
                     subTitle:(nullable NSString *)subTitle;

+(instancetype)modelWithImageName:(nullable NSString *)imageName
                            title:(nullable NSString *)title
                         subTitle:(nullable NSString *)subTitle;

@end

NS_ASSUME_NONNULL_END
