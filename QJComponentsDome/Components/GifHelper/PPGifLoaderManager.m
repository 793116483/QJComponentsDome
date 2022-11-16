//
//  PPGifLoaderManager.m
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPGifLoaderManager.h"
#import "PPGifImageViewModel.h"
#import "UIImageView+PPGif.h"
#import "PPGifPlayerManager.h"
#import "PPGifModel.h"
#import "PPGifCacheManager.h"

@interface PPGifLoaderManager ()
/// 标记
@property (nonatomic , strong)NSMutableDictionary * flagDictionary;

@end

@implementation PPGifLoaderManager

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    static PPGifLoaderManager * manager ;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

-(BOOL)isSupportWithURL:(NSURL *)URL {
    NSString * url = URL.absoluteString.lowercaseString;

    return url.length && ([url hasSuffix:@".gif"] || [url hasSuffix:@".webp"]);
    
    // http://patpat-test-static.s3.ap-southeast-1.amazonaws.com/origin/other/cms/position/62cfb5cae8e41.webp
//  URL = [NSURL URLWithString:@"http://patpatwebstatic.s3.us-west-2.amazonaws.com/origin/other/cms/position/6329391d93dfe.gif"];
}

-(BOOL)loadingGifWithURL:(NSURL *)URL imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage {
    if (![self isSupportWithURL:URL]) {
        imageView.gifImageViewModel = nil;
        return NO;
    }
    
    // 一样的数据
    if ([imageView.gifImageViewModel.gifModel.URL.absoluteString isEqualToString:URL.absoluteString]) {
        // 添加到播放管理器中
        [[PPGifPlayerManager shareManager] addGifImageViewModel:imageView.gifImageViewModel];
        return YES;
    }
    
    // 清除旧数据,防止数据重叠
    imageView.gifImageViewModel = nil;
    imageView.image = placeholderImage;
    
    if (imageView) {
        NSString * flagKey = [NSString stringWithFormat:@"%p",imageView];
        self.flagDictionary[flagKey] = URL;
    }
    
    // 高频，磁盘缓存中数据不直接读取出来
    if([[PPGifCacheManager shareGifCacheManager].diskCache gifDataExistsWithURL:URL]){
        [self dealWithURL:URL imageView:imageView];
        return YES;
    }
    
    // 下载
    __weak typeof(self) weakSelf = self;
    SDWebImageDownloaderOptions options = SDWebImageDownloaderUseNSURLCache|SDWebImageDownloaderContinueInBackground | SDWebImageDownloaderDecodeFirstFrameOnly ;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:URL options:options progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (data && finished){

            // 同步写入磁盘
            [[PPGifCacheManager shareGifCacheManager] saveGifDataToDisk:data URL:URL];

            if (imageView && !imageView.isOnlyShowFirstFrame) {
                // 处理gif播放
                [weakSelf dealWithData:data URL:URL imageView:imageView];
            }
        }
    }];
    
    return YES;
}

-(void)dealWithURL:(NSURL *)URL imageView:(UIImageView *)imageView {
    if (!URL || !imageView) {
        return;
    }
    NSString * flagKey = [NSString stringWithFormat:@"%p",imageView];
    if (self.flagDictionary[flagKey] == nil || self.flagDictionary[flagKey] != URL) {
        // 快速滑动时图片对应的URL发生变化了
        return;
    }

    [self dealWithModel:[PPGifModel gifModelWithGifURL:URL isOnlyFirstFrame:imageView.isOnlyShowFirstFrame] imageView:imageView];
}

-(void)dealWithData:(NSData *)data URL:(NSURL *)URL imageView:(UIImageView *)imageView {
    if (!data || !URL || !imageView) {
        return;
    }
    NSString * flagKey = [NSString stringWithFormat:@"%p",imageView];
    if (self.flagDictionary[flagKey] == nil || self.flagDictionary[flagKey] != URL) {
        // 快速滑动时图片对应的URL发生变化了
        return;
    }

    [self dealWithModel:[PPGifModel gifModelWithGifData:data URL:URL isOnlyFirstFrame:imageView.isOnlyShowFirstFrame] imageView:imageView];
}

-(void)dealWithModel:(PPGifModel *)gifModel imageView:(UIImageView *)imageView {
    if (!gifModel || !gifModel.URL || !imageView) {
        return;
    }
    NSString * flagKey = [NSString stringWithFormat:@"%p",imageView];
    if (self.flagDictionary[flagKey] == nil || self.flagDictionary[flagKey] != gifModel.URL) {
        // 快速滑动时图片对应的URL发生变化了
        return;
    }
    [self.flagDictionary removeObjectForKey:flagKey];

    PPGifImageViewModel * gifImageViewModel = [PPGifImageViewModel gifImageViewModelWithGifModel:gifModel imageView:imageView];
    // 添加到播放管理器中
    [[PPGifPlayerManager shareManager] addGifImageViewModel:gifImageViewModel];
    
}

-(NSMutableDictionary *)flagDictionary {
    if (!_flagDictionary) {
        _flagDictionary = [NSMutableDictionary dictionary];
    }
    return _flagDictionary;
}

@end
