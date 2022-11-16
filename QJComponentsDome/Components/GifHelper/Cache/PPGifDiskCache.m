//
//  PPGifDiskCache.m
//  PatPat
//
//  Created by 杰 on 2022/9/22.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPGifDiskCache.h"
#import "PPGifModel.h"

@interface PPGifDiskCache ()
@property (nonatomic, strong, nullable) dispatch_queue_t ioQueue;

@end

@implementation PPGifDiskCache

#pragma mark - 查询是否存在

-(BOOL)isExistsWithURL:(nonnull NSURL *)URL {
    if(!URL || !URL.absoluteString.length) return NO;
    
    if([[SDImageCache sharedImageCache] diskImageDataExistsWithKey:URL.absoluteString]){
        return YES;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:URL.path];
}

/// 查询gif是否在磁盘中
/// @param URL gif 对应的 URL
/// @param completionBlock 结果回调
- (void)gifDataExistsWithURL:(nonnull NSURL *)URL completion:(nullable PPGifCacheCheckCompletionBlock)complation {
    dispatch_async(self.ioQueue, ^{
        BOOL isExists = [self isExistsWithURL:URL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(complation) complation(isExists);
        });
    });
}

/// 查询gif是否在磁盘中
/// @param URL gif 对应的 URL
- (BOOL)gifDataExistsWithURL:(nonnull NSURL *)URL {
    if (!URL) {
        return NO;
    }
    
    __block BOOL isExists = NO;
    dispatch_sync(self.ioQueue, ^{
        isExists = [self isExistsWithURL:URL];
    });
    return isExists;
}

#pragma mark - 保存

/// 将数据添加到磁盘缓存中
/// @param gifData 需要缓存的 gif data 数据
/// @param URL gif 对应的 URL
-(void)saveGifDataToDisk:(NSData *)gifData URL:(nonnull NSURL *)URL {
    if (!gifData || !URL) {
        return;
    }
    dispatch_barrier_sync(self.ioQueue, ^{
        [[SDImageCache sharedImageCache] storeImageDataToDisk:gifData forKey:URL.absoluteString];
    });
}

#pragma mark - 删除操作

/// 将数据从磁盘缓存中移除
/// @param URL gif 对应的 URL
-(void)removeGifDataWithURL:(nonnull NSURL *)URL {
    if (!URL) {
        return;
    }
    dispatch_barrier_sync(self.ioQueue, ^{
        if([URL isFileURL]){
            [[NSFileManager defaultManager] removeItemAtURL:URL error:nil];
        }else{
            [[SDImageCache sharedImageCache] removeImageFromDiskForKey:URL.absoluteString];
        }
    });
}

#pragma mark - 查询

-(NSURL *)cachePathURLForURL:(NSURL *)URL {
    if (![URL isFileURL]) {
        NSString *filePath = [[SDImageCache sharedImageCache] cachePathForKey:URL.absoluteString];
        URL = nil;
        if(filePath){
            URL = [NSURL fileURLWithPath:filePath];
        }
    }
    return URL;
}

/// 从磁盘中读取
/// @param URL gif 对应的 URL
/// @param isAddToMemory 取出的 gifModel 是否添加到内存缓存中
-(nullable NSData *)queryGifDataWithURL:(nullable NSURL *)URL {
    if (!URL) {
        return nil;
    }
    
    __block NSData * gifData = nil;
    dispatch_sync(self.ioQueue, ^{
        gifData = [[SDImageCache sharedImageCache] diskImageDataForKey:URL.absoluteString];
        if(!gifData){
            gifData = [NSData dataWithContentsOfURL:URL];
        }
    });
    
    return gifData;
}

/// 从磁盘中读取 data
/// @param URL gif 对应的 URL
/// @param isAddToMemory 取出的 gifModel 是否添加到内存缓存中
/// @param complation 完成回调
-(void)queryGifDataWithURL:(nullable NSURL *)URL complation:(PPQueryGifDataCacheComplationBlock)complation {
    if (!complation) {
        return;
    }
    if (!URL) {
        complation(nil);
        return;
    }
    
    dispatch_async(self.ioQueue, ^{
        NSData * gifData = [[SDImageCache sharedImageCache] diskImageDataForKey:URL.absoluteString];
        if(!gifData){
            gifData = [NSData dataWithContentsOfURL:URL];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complation) complation(gifData);
        });
    });
}

#pragma mark - getter

-(dispatch_queue_t)ioQueue {
    if (!_ioQueue) {
        _ioQueue = dispatch_queue_create("gif.io.disk.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _ioQueue;
}


@end
