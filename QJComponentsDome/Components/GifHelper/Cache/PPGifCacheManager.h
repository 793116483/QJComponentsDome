//
//  PPGifCacheManager.h
//  PatPat
//
//  Created by 杰 on 2022/9/22.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPGifCommonType.h"
#import "PPGifMemoryCache.h"
#import "PPGifDiskCache.h"
#import "PPGifFrameMemoryCache.h"
#import "PPSysMemory.h"

NS_ASSUME_NONNULL_BEGIN

@class PPGifModel;

@interface PPGifCacheManager : NSObject

@property (nonatomic , strong) PPGifMemoryCache * memoryCache;
@property (nonatomic , strong) PPGifFrameMemoryCache * frameMemoryCache;
@property (nonatomic , strong) PPGifDiskCache * diskCache;

+(instancetype)shareGifCacheManager;

#pragma mark - 查询是否存在

/// 查询gif是否在缓存中
/// @param URL gif 对应的 URL
/// @param completionBlock 结果回调
- (void)gifCacheExistsWithURL:(nonnull NSURL *)URL completion:(nullable PPGifCacheCheckCompletionBlock)completionBlock;

/// 查询gif是否在缓存中
/// @param URL gif 对应的 URL
- (BOOL)gifCacheExistsWithURL:(nonnull NSURL *)URL;

#pragma mark - 保存

/// 将数据添加到内存缓存中
/// @param gifModel 需要缓存的 gif model 数据
-(void)saveGifModelToMemory:(PPGifModel *)gifModel;

/// 将数据添加到磁盘缓存中
/// @param gifData 需要缓存的 gif data 数据
/// @param URL gif 对应的 URL
-(void)saveGifDataToDisk:(NSData *)gifData URL:(nonnull NSURL *)URL;

#pragma mark - 删除操作

/// 将数据从内存缓存中移除
/// @param gifModel 需要移除的 gif model 数据
-(void)removeGifModelFromMemoryWithModel:(nonnull PPGifModel *)gifModel;

/// 将数据从内存缓存中移除
/// @param URL gif 对应的 URL
-(void)removeGifModelFromMemoryWithURL:(nonnull NSURL *)URL;

/// 将数据从磁盘缓存中移除
/// @param URL gif 对应的 URL
-(void)removeGifDataFromDiskWithURL:(nonnull NSURL *)URL;

#pragma mark - 查询

/// 从内存中读取
/// @param URL gif 对应的 URL
-(nullable PPGifModel *)queryGifModelFromMemoryWithURL:(nullable NSURL *)URL ;

/// 从磁盘中读取
/// @param URL gif 对应的 URL
/// @param isAddToMemory 取出的 gifModel 是否添加到内存缓存中
-(nullable NSData *)queryGifDataFromDiskWithURL:(nullable NSURL *)URL;

/// 从磁盘中读取 data
/// @param URL gif 对应的 URL
/// @param isAddToMemory 取出的 gifModel 是否添加到内存缓存中
/// @param complation 完成回调
-(void)queryGifDataFromDiskWithURL:(nullable NSURL *)URL complation:(PPQueryGifDataCacheComplationBlock)complation;

@end

NS_ASSUME_NONNULL_END
