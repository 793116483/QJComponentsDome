//
//  UITextField+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/21.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "UITextField+PPStatusCategory.h"

@implementation UITextField (PPStatusCategory)

-(BOOL)setUIViewStatusMessage:(PPStatusPropertyMessageModel *)message record:(BOOL)record{
    if(![super setUIViewStatusMessage:message record:record]) return NO;
        
    switch (message.propertyType) {
        case PPStatusUITextFieldPropertyTypeTextColor:{
            self.textColor = message.propertyValue;
            break;
        }
        case PPStatusUITextFieldPropertyTypeAttributedText:{
            self.attributedText = message.propertyValue;
            break;
        }
        default:
            break;
    }
    
    return YES;
}

-(void)setTextColor:(UIColor *)textColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusUITextFieldPropertyTypeTextColor propertyValue:textColor skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

-(void)setAttributedText:(NSAttributedString *)attributedText forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusUITextFieldPropertyTypeAttributedText propertyValue:attributedText skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

@end
