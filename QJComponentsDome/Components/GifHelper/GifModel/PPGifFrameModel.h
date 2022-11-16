//
//  PPGifFrameModel.h
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPGifFrameModel : NSObject
///当前帧显示的时长
@property (nonatomic , readonly) NSTimeInterval duration;
/// 当前帧在gif的位置
@property (nonatomic , readonly) NSUInteger index;
/// 当前帧的图片
@property (nonatomic , nullable , weak) UIImage * image;
/// 指定的图片大小
@property (nonatomic , assign) CGSize thumbnailSize;

+(instancetype)gifFrameModelWithDuration:(NSTimeInterval)duration index:(NSUInteger)index;

-(instancetype)initWithDuration:(NSTimeInterval)duration index:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
