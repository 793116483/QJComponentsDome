//
//  UIButton+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "UIButton+PPStatusCategory.h"

@implementation UIButton (PPStatusCategory)

- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithTitle:title forState:state skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithTitleColor:color forState:state skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithImage:image forState:state skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

- (void)setBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithBackgroundImage:image forState:state skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

- (void)setAttributedTitle:(nullable NSAttributedString *)title forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithAttributedTitle:title forState:state skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

-(BOOL)setUIViewStatusMessage:(PPButtonStatusMessage *)message record:(BOOL)record{
    if(![super setUIViewStatusMessage:message record:record]) return NO;
    
    switch (message.propertyType) {
        case PPStatusUIButtonPropertyTypeTitle:{
            [self setTitle:message.propertyValue forState:message.state];
            break;
        }
        case PPStatusUIButtonPropertyTypeTitleColor:{
            [self setTitleColor:message.propertyValue forState:message.state];
            break;
        }
        case PPStatusUIButtonPropertyTypeImage:{
            [self setImage:message.propertyValue forState:message.state];
            break;
        }
        case PPStatusUIButtonPropertyTypeBackgroundImage:{
            [self setBackgroundImage:message.propertyValue forState:message.state];
            break;
        }
        case PPStatusUIButtonPropertyTypeAttributedTitle:{
            [self setAttributedTitle:message.propertyValue forState:message.state];
            break;
        }
        default:
            break;
    }
    
    return YES;
}

@end


@implementation PPButtonStatusMessage

+ (instancetype)messageWithTitle:(nullable NSString *)title forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithPropertyType:PPStatusUIButtonPropertyTypeTitle propertyValue:title skinStatusStyle:skinStatusStyle];
    message.state = state;
    return message;
}

+ (instancetype)messageWithTitleColor:(nullable UIColor *)color forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle{
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithPropertyType:PPStatusUIButtonPropertyTypeTitleColor propertyValue:color skinStatusStyle:skinStatusStyle];
    message.state = state;
    return message;
}

+ (instancetype)messageWithImage:(nullable UIImage *)image forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle{
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithPropertyType:PPStatusUIButtonPropertyTypeImage propertyValue:image skinStatusStyle:skinStatusStyle];
    message.state = state;
    return message;
}

+ (instancetype)messageWithBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle{
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithPropertyType:PPStatusUIButtonPropertyTypeBackgroundImage propertyValue:image skinStatusStyle:skinStatusStyle];
    message.state = state;
    return message;
}

+ (instancetype)messageWithAttributedTitle:(nullable NSAttributedString *)title forState:(UIControlState)state skinStatusStyle:(PPSkinStatusStyle)skinStatusStyle{
    PPButtonStatusMessage * message = [PPButtonStatusMessage messageWithPropertyType:PPStatusUIButtonPropertyTypeAttributedTitle propertyValue:title skinStatusStyle:skinStatusStyle];
    message.state = state;
    return message;
}

-(NSString *)hashKey {
    NSString * key = [super hashKey];
    return [NSString stringWithFormat:@"%@_%ld",key,self.state];
}

@end
