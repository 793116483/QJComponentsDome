//
//  PPGifDiskCache.h
//  PatPat
//
//  Created by 杰 on 2022/9/22.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPGifCommonType.h"

NS_ASSUME_NONNULL_BEGIN

@interface PPGifDiskCache : NSObject

#pragma mark - 查询是否存在

/// 查询gif是否在磁盘中
/// @param URL gif 对应的 URL
/// @param complation 结果回调
- (void)gifDataExistsWithURL:(nonnull NSURL *)URL completion:(nullable PPGifCacheCheckCompletionBlock)complation;

/// 查询gif是否在磁盘中
/// @param URL gif 对应的 URL
- (BOOL)gifDataExistsWithURL:(nonnull NSURL *)URL;

#pragma mark - 保存

/// 将数据添加到磁盘缓存中
/// @param gifData 需要缓存的 gif data 数据
/// @param URL gif 对应的 URL
-(void)saveGifDataToDisk:(NSData *)gifData URL:(nonnull NSURL *)URL;

#pragma mark - 删除操作

/// 将数据从磁盘缓存中移除
/// @param URL gif 对应的 URL
-(void)removeGifDataWithURL:(nonnull NSURL *)URL;

#pragma mark - 查询

/// 将URL转成 本地文件的URL路径
- (nullable NSURL *)cachePathURLForURL:(NSURL *)URL;

/// 从磁盘中读取
/// @param URL gif 对应的 URL
/// @param isAddToMemory 取出的 gifModel 是否添加到内存缓存中
-(nullable NSData *)queryGifDataWithURL:(nullable NSURL *)URL;

/// 从磁盘中读取 data
/// @param URL gif 对应的 URL
/// @param isAddToMemory 取出的 gifModel 是否添加到内存缓存中
/// @param complation 完成回调
-(void)queryGifDataWithURL:(nullable NSURL *)URL complation:(PPQueryGifDataCacheComplationBlock)complation;

@end

NS_ASSUME_NONNULL_END
