//
//  PPStatusSetModel.h
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPStatusPublicHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class PPStatusCurrencyModel;

@interface PPStatusSetModel : NSObject

/// Luna项目样式标识
@property (nonatomic) BOOL isLunaStyle;

/// 皮肤样式
@property (nonatomic) PPSkinStatusStyle skinStatusStyle;
/// 状态栏样式
@property (nonatomic) UIStatusBarStyle statusBarStyle;
/// 导航栏样式
@property (nonatomic) UIBarStyle navigationBarStyle;
/// 语言
//@property (nonatomic , nullable , copy) NSString * language;
/// 货币
//@property (nonatomic , nullable) PPStatusCurrencyModel * currencyModel;

/// 是否只在当前页面有效,默认为NO
@property (nonatomic) BOOL isOnlyCurrentPageEffective;

/// 添加属性观察, 当对应的属性改变时会调用 -observeStatusChangeForPropertyType:ofStatusSetModel:
/// - Parameters:
///   - observer: 观察者,弱引用
///   - propertyType: 属性类型
-(void)addObserver:(NSObject *)observer forPropertyType:(PPStatusSetModelPropertyType)propertyType;

/// 移除属性观察
-(void)removeObserver:(NSObject *)observer forPropertyType:(PPStatusSetModelPropertyType)propertyType;

-(instancetype)copyNewStatusSetModel;

@end


/// 货币状态 与 PPCurrencyHandler 类对齐
@interface PPStatusCurrencyModel : NSObject

///currencyCode
@property(nonatomic,copy, nullable) NSString *currencyISO;
/// 货币符号
@property(nonatomic,copy)     NSString *currencySign;
/// 汇率
@property(nonatomic,copy)     NSString *exchangeRate;
/// 货币展示位置(0：系统默认，1：强制居左，2：强制居右，新加)
@property(nonatomic,copy)     NSString *currencyPlace;
/// 国家主语言（如：en，zh）
@property(nonatomic,copy)     NSString *countryLangue;
/// 国家码（如：US，CN）
@property(nonatomic,copy)     NSString *countryCode;
/// 货币名称
@property(nonatomic,copy)     NSString *countryCurrency;
/// 小数位数
@property(nonatomic,copy)     NSString *currencyAccuracy;

@property(nonatomic)            BOOL isSysDefault;


-(instancetype)copyNewStatusCurrencyModel;

@end


@interface PPStatusSetModelObserver : NSObject

@property (nonatomic , copy) NSString * key;
@property (nonatomic , weak) NSObject * observer;
@property (nonatomic) PPStatusSetModelPropertyType propertyType;

+(nullable instancetype)observerWithObjcte:(NSObject *)observer propertyType:(PPStatusSetModelPropertyType)propertyType;

+(NSString *)keyWithObjcte:(NSObject *)observer propertyType:(PPStatusSetModelPropertyType)propertyType;

@end


NS_ASSUME_NONNULL_END
