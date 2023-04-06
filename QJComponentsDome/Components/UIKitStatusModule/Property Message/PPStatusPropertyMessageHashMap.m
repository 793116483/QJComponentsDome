//
//  PPStatusPropertyMessageHashMap.m
//  PatPat
//
//  Created by 杰 on 2023/3/30.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "PPStatusPropertyMessageHashMap.h"
#import "PPStatusPropertyMessageModel.h"

@interface PPStatusPropertyMessageHashMap ()

@property (nonatomic, strong) NSMutableDictionary<NSString *,PPStatusPropertyMessageModel *> * hashMap;

@end

@implementation PPStatusPropertyMessageHashMap

-(void)storagePropertyMessage:(PPStatusPropertyMessageModel *)message{
    if(!message || !message.hashKey) return;

    self.hashMap[message.hashKey] = message;
}

/// 获取所有的属性信息
-(nullable NSArray<PPStatusPropertyMessageModel *> *)getAllPropertyMessages {
    return _hashMap.allValues;
}

-(NSMutableDictionary<NSString *,PPStatusPropertyMessageModel *> *)hashMap {
    if(!_hashMap){
        _hashMap = [NSMutableDictionary new];
    }
    return _hashMap;
}

@end
