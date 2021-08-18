//
//  QJWavyLinesView.h
//
//  Created by 杰 on 2020/9/15.
//  Copyright © 2020 . All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJWavyLinesView : UIView
/// 每时每刻需要变的值，波动级别 > 0.0
@property (nonatomic, assign) CGFloat level;

/// 线条个数，默认 8
@property (nonatomic, assign) NSInteger lineCount ;
/// 线条颜色，默认为淡蓝色
@property (nonatomic, strong) UIColor * lineColor ;
/// 最大线宽， 默认 2.0
@property (nonatomic, assign) CGFloat maxLineWidth ;
/// 最小线宽， 默认 1.0
@property (nonatomic, assign) CGFloat minLineWidth ;

@end

NS_ASSUME_NONNULL_END
