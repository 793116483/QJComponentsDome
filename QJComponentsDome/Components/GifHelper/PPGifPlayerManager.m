//
//  PPGifPlayerManager.m
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPGifPlayerManager.h"
#import "PPGifImageViewModel.h"
#import "PPGifModel.h"
#import "PPGifCacheManager.h"
#import "UIImageView+PPGif.h"

@interface PPGifPlayerManager ()

@property (nonatomic , strong) NSMutableDictionary<NSString *, PPGifImageViewModel *> * needPlayerModelDic;

@property (nonatomic , strong) CADisplayLink * defaultDisplyLinker;
@property (nonatomic , strong) CADisplayLink * trackingDisplyLinker;

@end

@implementation PPGifPlayerManager
const NSInteger kDisplayRefreshRate = 60.0; // 60Hz

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    static PPGifPlayerManager * manager ;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

-(instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearNotUsedGif) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllDisplyLinker) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAllDisplyLinker) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addGifImageViewModel:(PPGifImageViewModel *)model {
    if (!model || !model.identityKey || !model.imageView || model.imageView.isOnlyShowFirstFrame ||  model.gifModel.frameModels.count <= 1) {
        return;
    }
    
    self.needPlayerModelDic[model.identityKey] = model;
    [model resume];
    
    // 添加缓存
//        [[PPGifCacheManager shareGifCacheManager] saveGifModelToMemory:model.gifModel];
    
    // 启动定时器
    [self startAllDisplyLinker];
    
    // 精准控制定时器刷新次数，降低CPU性能消耗
    if (model.gifModel.miniDuration > 0) {
        NSInteger preferredFramesPerSecond = ceil(kDisplayRefreshRate * 0.016666125 / model.gifModel.miniDuration);
        // 经过测试发现，整除10的定时次数对CPU的消耗是最优的，可能是因为定时器方便系统注册打点时间
        if (preferredFramesPerSecond % 10) {
            preferredFramesPerSecond = preferredFramesPerSecond - (preferredFramesPerSecond % 10) + 10;
        }
        if (preferredFramesPerSecond > self.defaultDisplyLinker.preferredFramesPerSecond) {
            self.defaultDisplyLinker.preferredFramesPerSecond = preferredFramesPerSecond > kDisplayRefreshRate ? kDisplayRefreshRate : preferredFramesPerSecond;
        }
    }
}

-(void)removeGifImageViewModel:(PPGifImageViewModel *)model {
    if (!model) {
        return;
    }
    
    if (model.identityKey) {
        [self.needPlayerModelDic removeObjectForKey:model.identityKey];
        [model pause];
        
        // 移除缓存
//        [[PPGifCacheManager shareGifCacheManager] removeGifModelFromMemoryWithModel:model.gifModel];
        
        // 没有内容移除定时器
        if (!self.needPlayerModelDic.count) {
            [self removeAllDisplyLinker];
        }
    }
}

-(void)clearNotUsedGif {
    NSArray<PPGifImageViewModel *> * gifs = self.needPlayerModelDic.allValues.copy;
    for (PPGifImageViewModel * model in gifs) {
        if (![model canUseGif]) {
            // view不存在，移除
            [self removeGifImageViewModel:model];
        }
    }
}

-(NSMutableDictionary<NSString *,PPGifImageViewModel *> *)needPlayerModelDic {
    if (!_needPlayerModelDic) {
        _needPlayerModelDic = [NSMutableDictionary dictionary];
    }
    return _needPlayerModelDic;
}

#pragma mark - 定时器

-(CADisplayLink *)trackingDisplyLinker {
    if (!_trackingDisplyLinker) {
        _trackingDisplyLinker = [CADisplayLink displayLinkWithTarget:self selector:@selector(trackingRun)];
        _trackingDisplyLinker.preferredFramesPerSecond = 1; // 这个定时器只用于删除数据功能，所以没必要频繁
    }
    return _trackingDisplyLinker;
}

-(CADisplayLink *)defaultDisplyLinker {
    if (!_defaultDisplyLinker) {
        _defaultDisplyLinker = [CADisplayLink displayLinkWithTarget:self selector:@selector(defaultRun)];
        _defaultDisplyLinker.preferredFramesPerSecond = 10;
    }
    return _defaultDisplyLinker;
}

-(void)defaultRun {
    NSTimeInterval changeFrameTime = 0;
    CGFloat oneRunTime = self.defaultDisplyLinker.duration * kDisplayRefreshRate / self.defaultDisplyLinker.preferredFramesPerSecond;
    NSArray<PPGifImageViewModel *> * gifs = self.needPlayerModelDic.allValues.copy;
    for (PPGifImageViewModel * model in gifs) {
        @autoreleasepool {
            if (![model canUseGif]) {
                // viewModel不可用，移除
                [self removeGifImageViewModel:model];
            }else {
                // 定时器的每次间隔时间
                NSTimeInterval oneFrameduration = oneRunTime + changeFrameTime;
                CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
                
                [model syncChangeFrameIfNeedWithOneFrameDuration:oneFrameduration];
                
                changeFrameTime += (CFAbsoluteTimeGetCurrent() - startTime) ;
            }
        }
    }
}

-(void)trackingRun {
    NSArray<PPGifImageViewModel *> * gifs = self.needPlayerModelDic.allValues.copy;
    for (PPGifImageViewModel * model in gifs) {
        if (![model canUseGif]) {
            // viewModel不可用，移除
            [self removeGifImageViewModel:model];
        }
//        else {
//            // 定时器的每次间隔时间
//            NSTimeInterval oneFrameduration = self.defaultDisplyLinker.duration * kDisplayRefreshRate / self.defaultDisplyLinker.preferredFramesPerSecond;
//            [model asyncChangeFrameIfNeedWithOneFrameDuration:oneFrameduration];
//        }
    }
}

-(void)startAllDisplyLinker {
    
    if (!_defaultDisplyLinker) {
        [self.defaultDisplyLinker addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    if (!_trackingDisplyLinker) {
        [self.trackingDisplyLinker addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
    }
}

-(void)removeAllDisplyLinker {
    [_defaultDisplyLinker removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_trackingDisplyLinker removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
    
    _defaultDisplyLinker = _trackingDisplyLinker = nil;
}

@end
