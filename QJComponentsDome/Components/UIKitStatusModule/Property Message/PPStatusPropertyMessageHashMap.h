//
//  PPStatusPropertyMessageHashMap.h
//  PatPat
//
//  Created by 杰 on 2023/3/30.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPStatusPropertyMessageHashMap : NSObject

-(void)storagePropertyMessage:(PPStatusPropertyMessageModel *)message;

/// 获取所有的属性信息
-(nullable NSArray<PPStatusPropertyMessageModel *> *)getAllPropertyMessages;

@end

NS_ASSUME_NONNULL_END
