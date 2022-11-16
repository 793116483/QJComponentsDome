//
//  PPGifImageViewModel.m
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPGifImageViewModel.h"
#import "UIImageView+PPGif.h"
#import "PPGifModel.h"
#import "PPGifFrameModel.h"
#import "NSString+MD5.h"

@interface PPGifImageViewModel ()
/// 是否可以播放中
@property (nonatomic , assign) BOOL playing;

/// 是否可以播放下一帧，该属性可以很大提升了滑动时
@property (nonatomic , assign) BOOL canNextPlaying;

@end

@implementation PPGifImageViewModel

+(instancetype)gifImageViewModelWithGifData:(NSData *)gifData URL:(NSURL *)URL imageView:(UIImageView *)imageView {
    return [self gifImageViewModelWithGifModel:[PPGifModel gifModelWithGifData:gifData URL:URL isOnlyFirstFrame:imageView.isOnlyShowFirstFrame] imageView:imageView];
}
+(instancetype)gifImageViewModelWithGifModel:(PPGifModel *)gifModel imageView:(nonnull UIImageView *)imageView {
    PPGifImageViewModel * model = [self new];
    model.imageView = imageView;
    model.gifModel = gifModel;
    model->_identityKey = [NSString stringWithFormat:@"%@#%p",[gifModel.URL.absoluteString toMD5],imageView];
    imageView.gifImageViewModel = model;
    
    // 启动gif
    [model start];
    
    return model;
}

-(void)start {
    self.duration = 0 ;
    self.playing = YES;
    self.canNextPlaying = YES;
    self.currentFrameIndex = 0 ;
    
    if (!self.gifModel || !self.imageView) {
        return;
    }
    
    if(self.gifModel.frameModels.count == 0){
        // 识别不了的图使用SD加载
        SDWebImageOptions options = SDWebImageDecodeFirstFrameOnly ;
        [self.imageView sd_setImageWithURL:self.gifModel.URL placeholderImage:self.imageView.image options:options completed:nil];
    }else{
        // 异步显示第一帧内容
        __weak typeof(self) weakSelf = self;
        __weak UIImageView * weakImageView = self.imageView;
        self.canNextPlaying = NO;
        [self.gifModel getFrameImageWithFrameModel:self.gifModel.frameModels.firstObject thumbnailSize:self.imageView.frame.size complation:^(UIImage * _Nullable image, PPGifModel * _Nullable gifModel) {
            if (weakSelf && image && weakSelf.gifModel == gifModel && weakSelf.imageView == weakImageView && weakSelf.currentFrameIndex == 0) {
                weakSelf.imageView.image = image;
            }
            weakSelf.canNextPlaying = !weakSelf.imageView.isOnlyShowFirstFrame;
        }];
    }
}
/// 暂停gif
-(void)pause {
    self.playing = NO;
}
/// 继续gif的方法
-(void)resume {
    self.playing = YES;
}

/// 是否正在播放gif
-(BOOL)canPlaying {
    if (!self.canNextPlaying) {
        return NO;
    }
    
    if (!self.playing || ![self canUseGif] || ![self.imageView isDisplayedInScreen]) {
        // 优化运行内存占用
        [self.gifModel releaseGifSourceIfNeed];
        
        return NO;
    }
    
    return YES;
}

-(BOOL)canUseGif {
    
    if (self.imageView.gifImageViewModel != self ||
        ![self.gifModel canUseGif] ||
        (self.loopCount > 0 && self.gifModel.loopCount <= self.loopCount)) {  // 不是无限循环，且循环次数完成，不需要再播放gif了
        // 优化运行内存占用
        [self.gifModel releaseGifSourceIfNeed];
        
        return NO;
    }
    return YES;
}

-(void)syncChangeFrameIfNeedWithOneFrameDuration:(NSTimeInterval)oneFrameDuration {
    if (![self canPlaying]) {
        return;
    }
    
    self.duration += oneFrameDuration;
    PPGifFrameModel * frameModel = self.gifModel.frameModels.count > self.currentFrameIndex ? self.gifModel.frameModels[self.currentFrameIndex] : nil;

    if (frameModel.duration <= self.duration) {
        NSUInteger nextFrameIndex = self.currentFrameIndex + 1 ;
        if (self.gifModel.loopCount > 0 && nextFrameIndex >= self.gifModel.frameModels.count) {
            nextFrameIndex = 0;
            _loopCount++;
            if (_loopCount >= self.gifModel.loopCount) {
                [self pause];
            }
        }else if(nextFrameIndex >= self.gifModel.frameModels.count){
            // 无限循环
            nextFrameIndex = 0;
        }
        
        self.duration -= frameModel.duration;
        self.currentFrameIndex = nextFrameIndex;
        PPGifFrameModel * nextFrameModel = self.gifModel.frameModels.count > self.currentFrameIndex ? self.gifModel.frameModels[self.currentFrameIndex] : nil;
        
        // 生成并设置 imageView.image
        if (nextFrameModel) {
            UIImage * image = [self.gifModel getFrameImageWithFrameModel:nextFrameModel thumbnailSize:self.imageView.frame.size];
            if (image) {
                if ([NSThread isMainThread]) {
                    self.imageView.image = image;
                }else{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        self.imageView.image = image;
                    });
                }
            }
        }
    }
}

-(void)asyncChangeFrameIfNeedWithOneFrameDuration:(NSTimeInterval)oneFrameDuration {
    if (![self canPlaying]) {
        return;
    }
    
    self.duration += oneFrameDuration;
    PPGifFrameModel * frameModel = self.gifModel.frameModels.count > self.currentFrameIndex ? self.gifModel.frameModels[self.currentFrameIndex] : nil;

    if (frameModel.duration <= self.duration) {
        NSUInteger nextFrameIndex = self.currentFrameIndex + 1 ;
        if (self.gifModel.loopCount > 0 && nextFrameIndex >= self.gifModel.frameModels.count) {
            nextFrameIndex = 0;
            _loopCount++;
            if (_loopCount >= self.gifModel.loopCount) {
                [self pause];
            }
        }else if(nextFrameIndex >= self.gifModel.frameModels.count){
            // 无限循环
            nextFrameIndex = 0;
        }
        
        self.duration = 0 ;
        self.currentFrameIndex = nextFrameIndex;
        PPGifFrameModel * nextFrameModel = self.gifModel.frameModels.count > self.currentFrameIndex ? self.gifModel.frameModels[self.currentFrameIndex] : nil;
        
        // 生成并设置 imageView.image
        if (nextFrameModel) {
            __weak typeof(self) weakSelf = self;
            __weak UIImageView * weakImageView = self.imageView;
            self.canNextPlaying = NO;
            [self.gifModel getFrameImageWithFrameModel:nextFrameModel thumbnailSize:self.imageView.frame.size complation:^(UIImage * _Nullable image, PPGifModel * _Nullable gifModel) {
                if (weakSelf && image && weakSelf.gifModel == gifModel && weakSelf.imageView == weakImageView && weakSelf.currentFrameIndex == nextFrameIndex) {
                    weakSelf.imageView.image = image;
                }
                weakSelf.canNextPlaying = YES;
            }];
        }
    }
}

@end
