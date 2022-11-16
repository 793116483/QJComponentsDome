//
//  PPGifImageModel.m
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPGifModel.h"
#import "PPGifFrameModel.h"
#import "PPGifCacheManager.h"

@interface PPGifModel ()

@property (nonatomic) CGImageSourceRef gifSource;
@property (nonatomic) NSOperationQueue * queue;

@end

@implementation PPGifModel
@synthesize gifSource = _gifSource;

+(instancetype)gifModelWithGifData:(NSData *)gifData URL:(nonnull NSURL *)URL isOnlyFirstFrame:(BOOL)isOnlyFirstFrame{
    PPGifModel * model = [self new];
    model->_URL = URL;
    model->_isOnlyFirstFrame = isOnlyFirstFrame;
    
    //将GIF图片转换成对应的图片源
    if (!gifData) {
        // 获取信息
        [model gifSource];
        return model;
    }
    
    CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, NULL);
    model.gifSource = gifSource;
    
    return model;
}

+(instancetype)gifModelWithGifURL:(NSURL *)URL isOnlyFirstFrame:(BOOL)isOnlyFirstFrame{
    PPGifModel * model = [self new];
    model->_URL = URL;
    model->_isOnlyFirstFrame = isOnlyFirstFrame;
    // 获取信息
    [model gifSource];
    
    return model;
}

-(void)dealloc {
    [self releaseGifSourceIfNeed];
}

- (void)configGifData:(CGImageSourceRef)gifSource{
    
    if (!gifSource) {
        return;
    }
    
    // gif帧数
    size_t frameCout = CGImageSourceGetCount(gifSource);
    
    if(frameCout == 0){
        // 无法识别的图,使用SD加载
        return;
    }

    //定义数组存储拆分出来的图片
    NSMutableArray* frameModels = [[NSMutableArray alloc] init];
    NSTimeInterval miniDuration = 60;
    NSTimeInterval totalDuration = 0;
    NSInteger loopCount = 0;
    
    if(frameCout <= 1 || self.isOnlyFirstFrame){
        // 取不到用一个占位 或 只有一帧
        PPGifFrameModel * frameModel = [PPGifFrameModel gifFrameModelWithDuration:0 index:0];
        [frameModels addObject:frameModel];
        
        // 非动图跳过取帧数据
        goto gotoAssignment;
    }
    
    // 获取动图每一帧的信息
    for (size_t i=0; i < frameCout; i++) {
        NSTimeInterval duration = 0;
        [self gifImageDeleyTime:&duration imageSource:gifSource index:i];
        
        //将图片加入数组中
        PPGifFrameModel * frameModel = [PPGifFrameModel gifFrameModelWithDuration:duration index:i];
        [frameModels addObject:frameModel];
        totalDuration += duration;
        if (miniDuration > duration) {
            miniDuration = duration;
        }
    }

    //获取循环次数 和 其他属性信息
    CFDictionaryRef properties = CGImageSourceCopyProperties(gifSource, NULL);
    if (properties) {
        // GIF
        CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gif) {
            CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
            if (loop) {
                //如果loop == NULL，表示不循环播放，当loopCount  == 0时，表示无限循环；
                CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
            }
        }else if (@available(iOS 14.0, *)){
            // WebP
            CFDictionaryRef webP = CFDictionaryGetValue(properties, kCGImagePropertyWebPDictionary);
            if(webP){
                CFTypeRef loop = CFDictionaryGetValue(webP, kCGImagePropertyWebPLoopCount);
                if (loop) {
                    //如果loop == NULL，表示不循环播放，当loopCount  == 0时，表示无限循环；
                    CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
                }
            }
        }
        
        CFRelease(properties);
    }
    
gotoAssignment:
    self->_frameModels = frameModels.copy;
    self->_totalDuration = totalDuration;
    self->_miniDuration = miniDuration;
    self->_loopCount = loopCount;
}

//获取GIF图片每帧的时长
- (void)gifImageDeleyTime:(NSTimeInterval *)duration imageSource:(CGImageSourceRef)imageSource index:(NSInteger)index {
    *duration = 0;
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL);
    if (!imageProperties) {
        return;
    }
    
    // GIF 格式
    CFDictionaryRef gifProperties = CFDictionaryGetValue(imageProperties, kCGImagePropertyGIFDictionary);
    if(gifProperties){
        // 间隔时间
        CFNumberRef durationValue = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
        if (durationValue) {
            CFNumberGetValue(durationValue, kCFNumberDoubleType, duration);
        }
        if(*duration <= 0){
            durationValue = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
            if (durationValue) {
                CFNumberGetValue(durationValue, kCFNumberDoubleType, duration);
            }
        }
        
    }else if (@available(iOS 14.0, *)) {
        // WebP 格式
        gifProperties = CFDictionaryGetValue(imageProperties, kCGImagePropertyWebPDictionary);
        if (gifProperties) {
            // 间隔时间
            CFNumberRef durationValue = CFDictionaryGetValue(gifProperties, kCGImagePropertyWebPDelayTime);
            if (durationValue) {
                CFNumberGetValue(durationValue, kCFNumberDoubleType, duration);
            }
            if(*duration <= 0){
                durationValue = CFDictionaryGetValue(gifProperties, kCGImagePropertyWebPUnclampedDelayTime);
                if (durationValue) {
                    CFNumberGetValue(durationValue, kCFNumberDoubleType, duration);
                }
            }
        }
    }
    
    // 释放
    if (imageProperties) {
        CFRelease(imageProperties);
    }
}

-(nullable UIImage *)getFrameImageWithFrameModel:(PPGifFrameModel*)frameModel thumbnailSize:(CGSize)thumbnailSize{
    
    if(thumbnailSize.width*thumbnailSize.height > frameModel.thumbnailSize.width*frameModel.thumbnailSize.width){
        frameModel.image = nil;
        frameModel.thumbnailSize = CGSizeZero;
    }
    
    if(frameModel.image){
        return frameModel.image;
    }
    
    // 取出缓存帧
    frameModel.image = [[PPGifCacheManager shareGifCacheManager].frameMemoryCache queryGifFrameImageWithURL:self.URL index:frameModel.index size:thumbnailSize];
    if(frameModel.image){
        frameModel.thumbnailSize = thumbnailSize;
        return frameModel.image;
    }
    
    if(!self.gifSource){
        return nil;
    }
    // 引用记数+1【防止在子线程创建图版时self.gifSource被释放引起崩溃】
    CGImageSourceRef gifSource = (CGImageSourceRef)CFRetain(self.gifSource);
    
    //从GIF中取出一帧图片
    CGImageRef imageRef = nil;
    if (CGSizeEqualToSize(thumbnailSize, CGSizeZero)) {
        NSDictionary * decodingOptions = @{
            (__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform : @(YES),
            (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @(YES),
            (__bridge NSString *)kCGImageSourceShouldCacheImmediately : @(NO),
            (__bridge NSString *)kCGImageSourceShouldCache : @(NO)
        };
        imageRef = CGImageSourceCreateThumbnailAtIndex(gifSource, frameModel.index, (__bridge CFDictionaryRef)[decodingOptions copy]);
    }else {
        // 获取缩略图,尺寸的 80%，降低内存消耗
        CGFloat scale = [UIScreen mainScreen].scale * 0.8;
        NSDictionary * decodingOptions = @{
            (__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform : @(YES),
            (__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize : @(MAX(thumbnailSize.width * scale, thumbnailSize.height * scale)),
            (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @(YES),
            (__bridge NSString *)kCGImageSourceShouldCacheImmediately : @(NO),
            (__bridge NSString *)kCGImageSourceShouldCache : @(NO)
        };
        imageRef = CGImageSourceCreateThumbnailAtIndex(gifSource, frameModel.index, (__bridge CFDictionaryRef)[decodingOptions copy]);
    }
    
    // 引用记数-1
    CFRelease(gifSource);
    
    
    //将图片源转换成UIimageView能使用的图片源
    UIImage * image = nil;
    if(imageRef){
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }else if(frameModel.index == 0){
        // 取第一帧
        NSData * imageData = [[SDImageCache sharedImageCache] diskImageDataForKey:self.URL.absoluteString];
        image = [UIImage sd_imageWithData:imageData scale:2 firstFrameOnly:YES];
    }
    
    frameModel.image = image;
    frameModel.thumbnailSize = thumbnailSize;

    // 缓存图片
    if(self.frameModels.count > 1){
        // 只存动图帧，不存静态图
        [[PPGifCacheManager shareGifCacheManager].frameMemoryCache saveGifFrameImage:image URL:self.URL index:frameModel.index];
    }
    
    return image;
}

-(void)getFrameImageWithFrameModel:(PPGifFrameModel*)frameModel thumbnailSize:(CGSize)thumbnailSize complation:(nonnull void (^)(UIImage * _Nullable, PPGifModel * _Nullable))complation {
    __weak typeof(self) weakSelf = self;

    if(thumbnailSize.width*thumbnailSize.height > frameModel.thumbnailSize.width*frameModel.thumbnailSize.width){
        frameModel.image = nil;
        frameModel.thumbnailSize = CGSizeZero;
    }
    
    if(!frameModel.image){
        // 读取缓存帧
        frameModel.image = [[PPGifCacheManager shareGifCacheManager].frameMemoryCache queryGifFrameImageWithURL:self.URL index:frameModel.index size:thumbnailSize];
        if(frameModel.image){
            frameModel.thumbnailSize = thumbnailSize;
        }
    }
    
    if(frameModel.image){
        if (complation) {
            if([NSThread isMainThread]){
                complation(frameModel.image , weakSelf);
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    complation(frameModel.image , weakSelf);
                });
            }
        }
        return;
    }
    
    [self.queue addOperationWithBlock:^{
        @autoreleasepool {
            UIImage * image = [weakSelf getFrameImageWithFrameModel:frameModel thumbnailSize:thumbnailSize];
            if (complation) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complation(image , weakSelf);
                });
            }
        }
    }];
   
}

-(BOOL)canUseGif {
    // 必须 > 1 才为可用的gif图
    return self.frameModels.count > 1 && self.URL.absoluteString.length;
}

-(void)releaseGifSourceIfNeed {
    // 释放资源
    if (_gifSource) {
        @autoreleasepool {
            CFRelease(_gifSource);
            _gifSource = nil;
        }
    }
}

#pragma mark - getter

-(NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.name = @"gif.model.create.image.queue";
        _queue.maxConcurrentOperationCount = 3;
    }
    return _queue;
}

-(void)setGifSource:(CGImageSourceRef)gifSource {
    @autoreleasepool {
        if (_gifSource && _gifSource != gifSource) {
            CFRelease(_gifSource);
        }
        
        _gifSource = gifSource ;
        
        if (gifSource && _frameModels.count == 0) {
            
            self->_frameModels = nil;
            self->_totalDuration = 0;
            self->_loopCount = 0;
            self->_miniDuration = 0;
            
            [self configGifData:gifSource];
        }
    }
}

-(CGImageSourceRef)gifSource {
    if(!_gifSource && self.URL.absoluteString.length){
        NSURL * URL = self.URL;
        if (![URL isFileURL] && [[PPGifCacheManager shareGifCacheManager].diskCache gifDataExistsWithURL:URL]) {
            URL = [[PPGifCacheManager shareGifCacheManager].diskCache cachePathURLForURL:URL];
        }
        
        if(URL){
            if([NSThread isMainThread]){
                self.gifSource = CGImageSourceCreateWithURL((__bridge CFURLRef)URL, NULL);
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.gifSource = CGImageSourceCreateWithURL((__bridge CFURLRef)URL, NULL);
                });
            }
        }
    }
    return _gifSource;
}

@end
