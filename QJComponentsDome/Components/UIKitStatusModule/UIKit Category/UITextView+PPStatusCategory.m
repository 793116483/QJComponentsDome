//
//  UITextView+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/21.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "UITextView+PPStatusCategory.h"

@implementation UITextView (PPStatusCategory)

-(BOOL)setUIViewStatusMessage:(PPStatusPropertyMessageModel *)message record:(BOOL)record{
    if(![super setUIViewStatusMessage:message record:record]) return NO;
        
    switch (message.propertyType) {
        case PPStatusUITextViewPropertyTypeTextColor:{
            self.textColor = message.propertyValue;
            break;
        }
        case PPStatusUITextViewPropertyTypeAttributedText:{
            self.attributedText = message.propertyValue;
            break;
        }
        default:
            break;
    }
    
    return YES;
}

-(void)setTextColor:(UIColor *)textColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusUITextViewPropertyTypeTextColor propertyValue:textColor skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

-(void)setAttributedText:(NSAttributedString *)attributedText forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusUITextViewPropertyTypeAttributedText propertyValue:attributedText skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

@end
