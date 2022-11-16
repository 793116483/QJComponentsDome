//
//  PPGifMemoryCache.m
//  PatPat
//
//  Created by 杰 on 2022/9/22.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPGifMemoryCache.h"
#import "PPGifModel.h"
#import "NSString+MD5.h"

@interface PPGifMemoryCache ()

@property (nonatomic, strong, nullable) dispatch_queue_t ioQueue;

@property (nonatomic , strong)NSMutableDictionary<NSString *, PPGifModel *> * gifModelDictionary;

@end

@implementation PPGifMemoryCache

#pragma mark - 查询是否存在

/// 查询gif是否在缓存中
/// @param URL gif 对应的 URL
/// @param completionBlock 结果回调
- (void)gifModelExistsWithURL:(nonnull NSURL *)URL completion:(nullable PPGifCacheCheckCompletionBlock)complation {
    if (!complation) {
        return;
    }
    if (!URL) {
        complation(NO);
        return;
    }
    
    dispatch_async(self.ioQueue, ^{
        NSString * key = [URL.absoluteString toMD5];
        BOOL isExists = NO;
        
        if (key) {
            isExists = self.gifModelDictionary[key] != nil ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complation(isExists);
        });
    });
}

/// 查询gif是否在缓存中
/// @param URL gif 对应的 URL
- (BOOL)gifModelExistsWithURL:(nonnull NSURL *)URL {
    if (!URL) {
        return NO;
    }
    
    __block BOOL isExists = NO;
    dispatch_sync(self.ioQueue, ^{
        NSString * key = [URL.absoluteString toMD5];
        if (key) {
            isExists = self.gifModelDictionary[key] != nil ;
        }
    });
    return isExists;
}

#pragma mark - 保存

/// 将数据添加到内存缓存中
/// @param gifModel 需要缓存的 gif model 数据
-(void)saveGifModel:(PPGifModel *)gifModel {
    if (!gifModel.URL) {
        return;
    }
    dispatch_barrier_async(self.ioQueue, ^{
        NSString * key = [gifModel.URL.absoluteString toMD5];
        if (key && self.gifModelDictionary[key] != gifModel) {
            self.gifModelDictionary[key] = gifModel;
        }
    });
}

#pragma mark - 删除操作

/// 将数据从内存缓存中移除
/// @param gifModel 需要移除的 gif model 数据
-(void)removeGifModelWithModel:(nonnull PPGifModel *)gifModel {
    [self removeGifModelWithURL:gifModel.URL];
}

/// 将数据从内存缓存中移除
/// @param URL gif 对应的 URL
-(void)removeGifModelWithURL:(nonnull NSURL *)URL {
    if (!URL) {
        return;
    }
    dispatch_barrier_async(self.ioQueue, ^{
        NSString * key = [URL.absoluteString toMD5];
        if (key) {
            [self.gifModelDictionary removeObjectForKey:key];
        }
    });
}

/// 删除所有的内存缓存数据
-(void)clearAllCache {
    dispatch_barrier_async(self.ioQueue, ^{
        self.gifModelDictionary = nil;
    });
}

#pragma mark - 查询

/// 从内存中读取
/// @param URL gif 对应的 URL
-(nullable PPGifModel *)queryGifModelWithURL:(nullable NSURL *)URL {
    if (!URL) {
        return nil;
    }
    
    __block PPGifModel * gifModel = nil;
    dispatch_sync(self.ioQueue, ^{
        NSString * key = [URL.absoluteString toMD5];
        if (key) {
            gifModel = self.gifModelDictionary[key];
        }
    });
    return gifModel;
}

/// 从内存中读取
/// @param URL gif 对应的 URL
/// @param complation 完成回调
-(void)queryGifModelWithURL:(nullable NSURL *)URL complation:(PPQueryGifModelCacheComplationBlock)complation {
    if (!complation) {
        return;
    }
    if (!URL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            complation(nil);
        });
        return;
    }
    
    dispatch_async(self.ioQueue, ^{
        NSString * key = [URL.absoluteString toMD5];
        PPGifModel * gifModel = nil;
        
        if (key) {
            gifModel = self.gifModelDictionary[key];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complation(gifModel);
        });
    });
}

#pragma mark - getter

-(dispatch_queue_t)ioQueue {
    if (!_ioQueue) {
        _ioQueue = dispatch_queue_create("gif.io.memory.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _ioQueue;
}

-(NSMutableDictionary<NSString *,PPGifModel *> *)gifModelDictionary {
    if (!_gifModelDictionary) {
        _gifModelDictionary = [NSMutableDictionary dictionary];
    }
    return _gifModelDictionary;
}

@end
