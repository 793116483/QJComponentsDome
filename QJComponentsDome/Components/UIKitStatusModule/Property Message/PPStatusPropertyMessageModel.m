//
//  PPStatusPropertyMessageModel.m
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "PPStatusPropertyMessageModel.h"

@implementation PPStatusPropertyMessageModel

+(instancetype)messageWithPropertyType:(PPStatusUIKitPropertyType)propertyType propertyValue:(id)propertyValue skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [self new];
    message.propertyType = propertyType;
    message.propertyValue = propertyValue;
    message.skinStatusStyle = skinStatusStyle;
    
    return message;
}

-(NSString *)hashKey {
    return [self.class hashKeyWithPropertyType:self.propertyType skinStatusStyle:self.skinStatusStyle];
}

+(NSString *)hashKeyWithPropertyType:(PPStatusUIKitPropertyType)propertyType skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    return [NSString stringWithFormat:@"%ld_%ld",propertyType,skinStatusStyle];
}

@end
