//
//  PPGifMemoryCache.h
//  PatPat
//
//  Created by 杰 on 2022/9/22.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPGifCommonType.h"

NS_ASSUME_NONNULL_BEGIN

@class PPGifModel;

@interface PPGifMemoryCache : NSObject

#pragma mark - 查询是否存在

/// 查询gif是否在缓存中
/// @param URL gif 对应的 URL
/// @param complation 结果回调
- (void)gifModelExistsWithURL:(nonnull NSURL *)URL completion:(nullable PPGifCacheCheckCompletionBlock)complation;

/// 查询gif是否在缓存中
/// @param URL gif 对应的 URL
- (BOOL)gifModelExistsWithURL:(nonnull NSURL *)URL;

#pragma mark - 保存

/// 将数据添加到内存缓存中
/// @param gifModel 需要缓存的 gif model 数据
-(void)saveGifModel:(PPGifModel *)gifModel;

#pragma mark - 删除操作

/// 将数据从内存缓存中移除
/// @param gifModel 需要移除的 gif model 数据
-(void)removeGifModelWithModel:(nonnull PPGifModel *)gifModel;

/// 将数据从内存缓存中移除
/// @param URL gif 对应的 URL
-(void)removeGifModelWithURL:(nonnull NSURL *)URL;

/// 删除所有的内存缓存数据
-(void)clearAllCache;

#pragma mark - 查询

/// 从内存中读取
/// @param URL gif 对应的 URL
-(nullable PPGifModel *)queryGifModelWithURL:(nullable NSURL *)URL ;

/// 从内存中读取
/// @param URL gif 对应的 URL
/// @param complation 完成回调
-(void)queryGifModelWithURL:(nullable NSURL *)URL complation:(PPQueryGifModelCacheComplationBlock)complation;

@end

NS_ASSUME_NONNULL_END
