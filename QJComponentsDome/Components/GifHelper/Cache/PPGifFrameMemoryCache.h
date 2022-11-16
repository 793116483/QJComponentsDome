//
//  PPGifFrameMemoryCache.h
//  PatPat
//
//  Created by 杰 on 2022/9/22.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPGifCommonType.h"

NS_ASSUME_NONNULL_BEGIN

@class PPGifFrameModel , UIImage;

@interface PPGifFrameMemoryCache : NSObject

#pragma mark - 保存

/// 将数据添加到内存缓存中
/// @param gifModel 需要缓存的 gif frmae model 数据
-(void)saveGifFrameImage:(UIImage *)image URL:(NSURL *)URL index:(NSInteger)index;

#pragma mark - 查询

/// 从内存中读取
/// - Parameters:
///   - URL: gif 对应的 URL
///   - index: 第几帧
-(nullable UIImage *)queryGifFrameImageWithURL:(nullable NSURL *)URL index:(NSInteger)index;

/// 从内存中读取
/// - Parameters:
///   - URL: gif 对应的 URL
///   - index: 第几帧
///   - size: 帧图的显示大小, 如果为zero表示不限制大小
-(nullable UIImage *)queryGifFrameImageWithURL:(nullable NSURL *)URL index:(NSInteger)index size:(CGSize)size;


#pragma mark - 删除操作

/// 将数据从内存缓存中移除
/// @param URL gifFrameModel 对应的 URL
/// @param index gifFrameModel 对应的 位置
-(void)removeGifFrameModelWithURL:(nonnull NSURL *)URL index:(NSInteger)index;

/// 删除溢出的内存缓存数据
-(void)clearOverflowCache;

/// 当运行内存使用率 > 65时，清除所有内存缓存
//-(void)clearAllCacheIfMemoryUsageRateMoreThen70Percent;

@end

NS_ASSUME_NONNULL_END
