//
//  PPGifCacheManager.m
//  PatPat
//
//  Created by 杰 on 2022/9/22.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPGifCacheManager.h"
#import <UIKit/UIKit.h>

@interface PPGifCacheManager ()


@end

@implementation PPGifCacheManager

+(instancetype)shareGifCacheManager {
    static dispatch_once_t onceToken;
    static PPGifCacheManager * manager ;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

-(instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemoryCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)clearMemoryCache {
    [self.memoryCache clearAllCache];
}

#pragma mark - 查询是否存在

/// 查询gif是否在缓存中
/// @param URL gif 对应的 URL
/// @param completionBlock 结果回调
- (void)gifCacheExistsWithURL:(nonnull NSURL *)URL completion:(nullable PPGifCacheCheckCompletionBlock)completionBlock {
    [self.memoryCache gifModelExistsWithURL:URL completion:^(BOOL isInCache) {
        if (isInCache) {
            if (completionBlock) {
                completionBlock(isInCache);
            }
            return;
        }
        
        // 磁盘
        [self.diskCache gifDataExistsWithURL:URL completion:completionBlock];
    }];
}

/// 查询gif是否在缓存中
/// @param URL gif 对应的 URL
- (BOOL)gifCacheExistsWithURL:(nonnull NSURL *)URL {
    BOOL isInCache = [self.memoryCache gifModelExistsWithURL:URL];
    if (isInCache) {
        return YES;
    }
    
    // 磁盘
    isInCache = [self.diskCache gifDataExistsWithURL:URL];
    return isInCache;
}

#pragma mark - 保存

/// 将数据添加到内存缓存中
/// @param gifModel 需要缓存的 gif model 数据
-(void)saveGifModelToMemory:(PPGifModel *)gifModel {
    [self.memoryCache saveGifModel:gifModel];
}

/// 将数据添加到磁盘缓存中
/// @param gifData 需要缓存的 gif data 数据
/// @param URL gif 对应的 URL
-(void)saveGifDataToDisk:(NSData *)gifData URL:(nonnull NSURL *)URL {
    [self.diskCache saveGifDataToDisk:gifData URL:URL];
}

#pragma mark - 删除操作

/// 将数据从内存缓存中移除
/// @param gifModel 需要移除的 gif model 数据
-(void)removeGifModelFromMemoryWithModel:(nonnull PPGifModel *)gifModel {
    [self.memoryCache removeGifModelWithModel:gifModel];
}

/// 将数据从内存缓存中移除
/// @param URL gif 对应的 URL
-(void)removeGifModelFromMemoryWithURL:(nonnull NSURL *)URL {
    [self.memoryCache removeGifModelWithURL:URL];
}

/// 将数据从磁盘缓存中移除
/// @param URL gif 对应的 URL
-(void)removeGifDataFromDiskWithURL:(nonnull NSURL *)URL {
    [self.diskCache removeGifDataWithURL:URL];
}

#pragma mark - 查询

/// 从内存中读取
/// @param URL gif 对应的 URL
-(nullable PPGifModel *)queryGifModelFromMemoryWithURL:(nullable NSURL *)URL {
    return [self.memoryCache queryGifModelWithURL:URL];
}

/// 从磁盘中读取
/// @param URL gif 对应的 URL
/// @param isAddToMemory 取出的 gifModel 是否添加到内存缓存中
-(nullable NSData *)queryGifDataFromDiskWithURL:(nullable NSURL *)URL {   
    return [self.diskCache queryGifDataWithURL:URL];
}

/// 从磁盘中读取 data
/// @param URL gif 对应的 URL
/// @param isAddToMemory 取出的 gifModel 是否添加到内存缓存中
/// @param complation 完成回调
-(void)queryGifDataFromDiskWithURL:(nullable NSURL *)URL complation:(PPQueryGifDataCacheComplationBlock)complation {
    [self.diskCache queryGifDataWithURL:URL complation:complation];
}

#pragma mark - getter

-(PPGifMemoryCache *)memoryCache {
    if (!_memoryCache) {
        _memoryCache = [PPGifMemoryCache new];
    }
    return _memoryCache;
}

-(PPGifFrameMemoryCache *)frameMemoryCache {
    if (!_frameMemoryCache) {
        _frameMemoryCache = [PPGifFrameMemoryCache new];
    }
    return _frameMemoryCache;
}

-(PPGifDiskCache *)diskCache {
    if (!_diskCache) {
        _diskCache = [PPGifDiskCache new];
    }
    return _diskCache;
}

@end
