//
//  PPTransition.h
//  PatPat
//
//  Created by 杰 on 2022/4/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPTransition : CATransition

/// present 转场动画
+(instancetype)presentTransition;
/// dismiss 转场动画
+(instancetype)dismissTransition;

/// push 转场动画
+(instancetype)pushTransition;

@end

NS_ASSUME_NONNULL_END
