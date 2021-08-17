//
//  PPMultiTargetProxy.h
//  PatPat
//
//  Created by 杰 on 2021/8/12.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPMultiTargetProxy : NSProxy

@property (nonatomic, weak, readonly) id target;
@property (nonatomic, weak, readonly) id secondTarget;

/**
 创建
 @param target Target object.
 @param secondTarget 监听 Target object 的第二选择.
 @return A new proxy object.
 */
+ (instancetype)proxyWithTarget:(nullable id)target secondTarget:(nullable id)secondTarget;

- (instancetype)initWithTarget:(nullable id)target secondTarget:(nullable id)secondTarget;


@end

NS_ASSUME_NONNULL_END
