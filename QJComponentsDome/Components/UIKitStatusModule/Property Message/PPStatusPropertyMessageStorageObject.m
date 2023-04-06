//
//  PPStatusPropertyMessageStorageObject.m
//  PatPat
//
//  Created by 杰 on 2023/3/30.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "PPStatusPropertyMessageStorageObject.h"
#import "PPStatusPropertyMessageModel.h"
#import "PPStatusPropertyMessageHashMap.h"


@interface PPStatusPropertyMessageStorageObject ()

@property (nonatomic, strong) NSMutableDictionary<NSString *,PPStatusPropertyMessageHashMap *> * hashMap;

@end

@implementation PPStatusPropertyMessageStorageObject

-(NSString *)hasKeyWithSkinStyle:(PPSkinStatusStyle)skinStyle{
    return [NSString stringWithFormat:@"%ld",skinStyle];
}

-(void)storagePropertyMessage:(PPStatusPropertyMessageModel *)message {
    if(!message) return;
    
    NSString * key = [self hasKeyWithSkinStyle:message.skinStatusStyle];
    PPStatusPropertyMessageHashMap * map = self.hashMap[key];
    if(!map){
        map = [PPStatusPropertyMessageHashMap new];
        self.hashMap[key] = map;
    }
    
    [map storagePropertyMessage:message];
}

-(NSArray<PPStatusPropertyMessageModel *> *)getPropertyMessageArrayWithSkinStatusStyle:(PPSkinStatusStyle)skinStyle {
    NSString * key = [self hasKeyWithSkinStyle:skinStyle];
    PPStatusPropertyMessageHashMap * map = _hashMap[key];
    
    return [map getAllPropertyMessages];
}

-(NSMutableDictionary<NSString *,PPStatusPropertyMessageHashMap *> *)hashMap {
    if(!_hashMap){
        _hashMap = [NSMutableDictionary new];
    }
    return _hashMap;
}

@end
