//
//  UIViewController+PPStatusCategory.h
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PPStatusSetModel;

@interface UIViewController (PPStatusCategory)

/// 当前状态集模型对象，如果没有设置，获取时会取 PPStausStackManager 管理的栈顶的状态集模型
@property (nonatomic, strong, nullable) PPStatusSetModel * currentStatusSetModel;

@end

NS_ASSUME_NONNULL_END
