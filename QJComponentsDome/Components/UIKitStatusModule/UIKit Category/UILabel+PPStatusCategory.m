//
//  UILabel+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "UILabel+PPStatusCategory.h"
#import "UIView+PPStatusCategory.h"
#import "NSString+PPStatusCategory.h"

@implementation UILabel (PPStatusCategory)

-(BOOL)setUIViewStatusMessage:(PPStatusPropertyMessageModel *)message record:(BOOL)record{
    if(![super setUIViewStatusMessage:message record:record]) return NO;
        
    switch (message.propertyType) {
        case PPStatusUILabelPropertyTypeTextColor:{
            self.textColor = message.propertyValue;
            break;
        }
        case PPStatusUILabelPropertyTypeAttributedText:{
            self.attributedText = message.propertyValue;
            break;
        }
        default:
            break;
    }
    
    return YES;
}

-(void)setTextColor:(UIColor *)textColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusUILabelPropertyTypeTextColor propertyValue:textColor skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

-(void)setAttributedText:(NSAttributedString *)attributedText forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusUILabelPropertyTypeAttributedText propertyValue:attributedText skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

//-(void)resetViewAndSubViewSkin {
//    [super resetViewAndSubViewSkin];
//
//    NSString * languageKey = self.text.languageKey;
//    if(languageKey){
//        self.text = PPLocalizationString(languageKey, nil);
//    }
//
////    NSString * attributedTextLanguageKey = self.attributedText.string.languageKey;
////    if(attributedTextLanguageKey){
////        self.text = PPLocalizationString(languageKey, nil);
////    }
//}

@end
