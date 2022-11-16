//
//  PPGifFrameMemoryCache.m
//  PatPat
//
//  Created by 杰 on 2022/9/22.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPGifFrameMemoryCache.h"
#import "PPSysMemory.h"
#import "UIImage+PPGifImage.h"
#import "NSString+MD5.h"

@interface PPGifFrameMemoryCache ()

// 用于监测内存变动及时清除内存
@property (nonatomic) CFRunLoopObserverRef mainRunloopObserver ;

@property (nonatomic, strong, nullable) dispatch_queue_t ioQueue;

@property (nonatomic , strong)NSMutableDictionary<NSString *, UIImage *> * gifFrameDictionary;
@property (nonatomic , strong)NSMutableArray<UIImage *> * gifImageArray;

@end

@implementation PPGifFrameMemoryCache

#pragma mark - 保存

/// 将数据添加到内存缓存中
/// @param gifModel 需要缓存的 gif frmae model 数据
-(void)saveGifFrameImage:(UIImage *)image URL:(NSURL *)URL index:(NSInteger)index {
    if (!URL || !image) {
        return;
    }
    dispatch_barrier_sync(self.ioQueue, ^{
        NSString * key = [self keyWithURL:URL index:index];
        UIImage * savedImage = self.gifFrameDictionary[key];
        
        if(!savedImage || image.size.width * image.size.height >= savedImage.size.width * savedImage.size.height){
            image.gifFrameKey = key;
            self.gifFrameDictionary[key] = image;
            
            if(savedImage){
                [self.gifImageArray removeObject:savedImage];
            }
            [self.gifImageArray addObject:image];
            
            [self mainRunloopObserver];
        }
    });
}

#pragma mark - 删除操作

/// 将数据从内存缓存中移除
/// @param URL gifFrameModel 对应的 URL
/// @param index gifFrameModel 对应的 位置
-(void)removeGifFrameModelWithURL:(nonnull NSURL *)URL index:(NSInteger)index {
    if (!URL) {
        return;
    }
    dispatch_barrier_sync(self.ioQueue, ^{
        NSString * key = [self keyWithURL:URL index:index];
        UIImage * savedImage = self.gifFrameDictionary[key];
        [self.gifFrameDictionary removeObjectForKey:key];
        if(savedImage){
            [self.gifImageArray removeObject:savedImage];
        }
    });
}

/// 删除溢出的内存缓存数据
-(void)clearOverflowCache {
    if(!self.gifImageArray.count) return;
    
    dispatch_barrier_sync(self.ioQueue, ^{
        // FIFO 策略删除
        NSUInteger len = self.gifImageArray.count > 20 ? 20 : self.gifImageArray.count;
        for (int i = 0; i < len; i++) {
            UIImage * image = self.gifImageArray[i];
            NSString * key = image.gifFrameKey;
            if(key.length){
                [self.gifFrameDictionary removeObjectForKey:key];
            }
        }
        [self.gifImageArray removeObjectsInRange:NSMakeRange(0, len)];

        if(!self.gifFrameDictionary.count){
            // 移除监听
            [self removeRunLoopObserver];
        }
    });
}

-(void)clearAllCacheIfMemoryUsageRateMoreThen70Percent {
    // 如果内存使用率 > 70，就清除内存
    if([PPSysMemory needClearMemory]){
        @autoreleasepool {
            [self clearOverflowCache];
        }
    }
}

#pragma mark - 查询

/// 从内存中读取
/// - Parameters:
///   - URL: gif 对应的 URL
///   - index: 第几帧
-(nullable UIImage *)queryGifFrameImageWithURL:(nullable NSURL *)URL index:(NSInteger)index{
    return [self queryGifFrameImageWithURL:URL index:index size:CGSizeZero];
}

/// 从内存中读取
/// - Parameters:
///   - URL: gif 对应的 URL
///   - index: 第几帧
///   - size: 帧图的显示大小, 如果为zero表示不限制大小
-(nullable UIImage *)queryGifFrameImageWithURL:(nullable NSURL *)URL index:(NSInteger)index size:(CGSize)size{
    if (!URL) {
        return nil;
    }
    __block UIImage * gifFrameImage = nil;
    dispatch_sync(self.ioQueue, ^{
        NSString * key = [self keyWithURL:URL index:index];
        UIImage * savedImage = self.gifFrameDictionary[key];
        if(size.width*size.height <= savedImage.size.width * savedImage.size.height){
            gifFrameImage = savedImage;
        }
    });
    return gifFrameImage;
}

#pragma mark - getter

-(NSString *)keyWithURL:(NSURL *)URL index:(NSInteger)index{
    return [NSString stringWithFormat:@"%@_%ld",[URL.absoluteString toMD5],index];
}

-(dispatch_queue_t)ioQueue {
    if (!_ioQueue) {
        _ioQueue = dispatch_queue_create("gif.io.memory.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _ioQueue;
}

-(NSMutableDictionary<NSString *,UIImage *> *)gifFrameDictionary {
    if (!_gifFrameDictionary) {
        _gifFrameDictionary = [NSMutableDictionary dictionary];
    }
    return _gifFrameDictionary;
}

-(NSMutableArray<UIImage *> *)gifImageArray {
    if (!_gifImageArray){
        _gifImageArray = [NSMutableArray array];
    }
    return _gifImageArray;
}

-(CFRunLoopObserverRef)mainRunloopObserver {
    if(!_mainRunloopObserver){
        __weak typeof(self) weakSelf = self;
        _mainRunloopObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            [weakSelf clearAllCacheIfMemoryUsageRateMoreThen70Percent];
        });
        
        CFRunLoopAddObserver(NSRunLoop.mainRunLoop.getCFRunLoop, _mainRunloopObserver, kCFRunLoopCommonModes);
    }
    return _mainRunloopObserver;
}

-(void)removeRunLoopObserver{
    if(_mainRunloopObserver){
        CFRunLoopRemoveObserver(NSRunLoop.mainRunLoop.getCFRunLoop, _mainRunloopObserver, kCFRunLoopCommonModes);
        CFRelease(_mainRunloopObserver);
        _mainRunloopObserver = nil;
    }
}

-(void)dealloc {
    [self removeRunLoopObserver];
}

@end
