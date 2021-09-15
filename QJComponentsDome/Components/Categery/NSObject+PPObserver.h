//
//  NSObject+PPObserver.h
//
//  Created by 杰 on 2021/9/14.
//  Copyright © 2021 All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PPObjectObserverModel ;

@interface NSObject (PPObserver)

/// 添加 block 监听
/// @param keyPath 观察属性名
/// @param userInfo 用户绑定的数据，可以从回调参数 observerModel 对象中获取
/// @param didChangedValueBlock 监听回调 block
-(void)addObserverForKeyPath:(NSString *)keyPath
                    userInfo:(nullable id)userInfo
        didChangedValueBlock:(void(^)(PPObjectObserverModel * observerModel))didChangedValueBlock ;

/// 添加 block 监听
/// @param keyPath 观察属性名
/// @param userInfo 用户绑定的数据，可以从回调参数 observerModel 对象中获取
/// @param didChangedValueBlock 监听回调 block
/// @param target 如果 target 对象被释放了，当前监听则会被移除
-(void)addObserverForKeyPath:(NSString *)keyPath
                    userInfo:(nullable id)userInfo
        didChangedValueBlock:(void(^)(PPObjectObserverModel * observerModel))didChangedValueBlock
removeObserverWhenTargetDalloc:(nullable id)target;

/// 添加监听
/// @param keyPath 观察属性名
/// @param userInfo 用户绑定的数据，可以从 action方法接收 PPObjectObserverModel 类型的参数对象中获取
/// @param target 回调对象 ，如果被释放了则当前监听自动会被移除
/// @param action 回调方法，方法是无参 或 有一个参数【这个参数为 PPObjectObserverModel 类型的对象】
-(void)addObserverForKeyPath:(NSString *)keyPath
                    userInfo:(nullable id)userInfo
                      target:(id)target
                      action:(SEL)action ;

/// 移除所有监听
-(void)removeObserverForKeyPath:(NSString *)keyPath ;
/// 移除监听
-(void)removeObserverForKeyPath:(NSString *)keyPath target:(id)target;
/// 移除监听
-(void)removeObserverForKeyPath:(NSString *)keyPath target:(id)target action:(SEL)action;

@end


@interface PPObjectObserverModel : NSObject

/// 用户绑定的数据
@property (nonatomic , strong , nullable) id userInfo ;

/// 被观察的对象
-(id)object ;

/// 观察的属性
-(NSString *)keyPath ;

@end
NS_ASSUME_NONNULL_END
