//
//  PPGifImageViewModel.h
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PPGifModel;

@interface PPGifImageViewModel : NSObject

/// 用于展示gif
@property (nonatomic , weak) UIImageView * imageView;
/// gif数据
@property (nonatomic , strong) PPGifModel * gifModel;
///播放当前gif循环次数,当loopCount == 0时，表示无限循环
@property (nonatomic , readonly) NSInteger loopCount;
/// 当前播放的帧位置
@property (nonatomic , assign) NSUInteger currentFrameIndex;
///当前帧已经显示的时长
@property (nonatomic , assign) NSTimeInterval duration;

/// 用于标识,格式为: [URL的md5值]#[imageView的地址]
@property (nonatomic , readonly) NSString * identityKey;

/// 创建模型
/// @param gifData gif data
/// @param URL gif URL
/// @param imageView 展示gif
+(instancetype)gifImageViewModelWithGifData:(NSData *)gifData URL:(NSURL *)URL imageView:(UIImageView *)imageView;
+(instancetype)gifImageViewModelWithGifModel:(PPGifModel *)gifModel imageView:(UIImageView *)imageView;

/// 重新开始播放gif
-(void)start;
/// 暂停gif
-(void)pause;
/// 继续gif的方法
-(void)resume;

/// 是否正在播放gif
-(BOOL)canPlaying;

/// 当前gif是否可用
-(BOOL)canUseGif;

/// 同步改变当前显示的帧，如果允许的话
/// @param oneFrameDuration 刷新一帧的经过时长
-(void)syncChangeFrameIfNeedWithOneFrameDuration:(NSTimeInterval)oneFrameDuration;

/// 同步改变当前显示的帧，如果允许的话
/// @param oneFrameDuration 刷新一帧的经过时长
-(void)asyncChangeFrameIfNeedWithOneFrameDuration:(NSTimeInterval)oneFrameDuration;

@end

NS_ASSUME_NONNULL_END
