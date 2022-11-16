//
//  PPSysMemory.h
//  PatPat
//
//  Created by 杰 on 2022/10/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPSysMemory : NSObject

/// 获取已经使用的运行内存大小，单位 M【获取失败为 0】
+ (CGFloat)getUsedRamMemory;

/// 获取可使用的极限运行内存大小，单位 M【获取失败为 0】
+ (CGFloat)getLimitRamMemory;

/// 运行内存使用率，取值【0~100】%
+ (CGFloat)usageRateForRamMemory;

+ (BOOL)needClearMemory;

@end

NS_ASSUME_NONNULL_END
