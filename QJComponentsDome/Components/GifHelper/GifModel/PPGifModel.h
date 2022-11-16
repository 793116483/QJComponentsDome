//
//  PPGifImageModel.h
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PPGifFrameModel;

@interface PPGifModel : NSObject

/// gif数据 对应的 URL
@property (nonatomic , readonly) NSURL * URL;
/// 仅展示第一帧
@property (nonatomic , readonly) BOOL isOnlyFirstFrame;
///gif帧数据
@property (nonatomic , readonly) NSArray<PPGifFrameModel *> * frameModels;
/// 单帧显示最小时长
@property (nonatomic , readonly) NSTimeInterval miniDuration;
///总时长
@property (nonatomic , readonly) NSTimeInterval totalDuration;
///循环次数,当loopCount == 0时，表示无限循环
@property (nonatomic , readonly) NSInteger loopCount;

//@property (nonatomic , readonly) NSUInteger pixelWidth;
//@property (nonatomic , readonly) NSUInteger pixelHeight;

+(instancetype)gifModelWithGifData:(NSData *)gifData URL:(NSURL *)URL isOnlyFirstFrame:(BOOL)isOnlyFirstFrame;

+(instancetype)gifModelWithGifURL:(NSURL *)URL isOnlyFirstFrame:(BOOL)isOnlyFirstFrame;

/// 可用的gif图，单图为不可用的gif
-(BOOL)canUseGif;


/// 获取一帧
/// @param index 获取gif的第几帧
/// @param thumbnailSize 缩略图size
-(nullable UIImage *)getFrameImageWithFrameModel:(PPGifFrameModel*)frameModel thumbnailSize:(CGSize)thumbnailSize;

-(void)getFrameImageWithFrameModel:(PPGifFrameModel*)frameModel  thumbnailSize:(CGSize)thumbnailSize complation:(void(^)(UIImage * _Nullable image , PPGifModel * _Nullable gifModel))complation;

/// 释放持有的 gif source 资源，节省运行内存
-(void)releaseGifSourceIfNeed;

@end

NS_ASSUME_NONNULL_END
