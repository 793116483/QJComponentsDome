//
//  PPStatusPropertyMessageStorageObject.h
//  PatPat
//
//  Created by 杰 on 2023/3/30.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPStatusPublicHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class PPStatusPropertyMessageModel;

@interface PPStatusPropertyMessageStorageObject : NSObject

-(void)storagePropertyMessage:(PPStatusPropertyMessageModel *)message;

/// 获取肤色对应的属性信息
-(nullable NSArray<PPStatusPropertyMessageModel *> *)getPropertyMessageArrayWithSkinStatusStyle:(PPSkinStatusStyle)skinStyle;

@end


NS_ASSUME_NONNULL_END
