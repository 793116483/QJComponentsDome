//
//  PPGifPlayerManager.h
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PPGifImageViewModel;

@interface PPGifPlayerManager : NSObject

+(instancetype)shareManager;

/// 当加入到管理器中，就会自动播放gif
-(void)addGifImageViewModel:(nonnull PPGifImageViewModel *)model;

/// 从管理器中移除时，就会自动停止gif
-(void)removeGifImageViewModel:(nonnull PPGifImageViewModel *)model;

-(void)clearNotUsedGif;

@end

NS_ASSUME_NONNULL_END
