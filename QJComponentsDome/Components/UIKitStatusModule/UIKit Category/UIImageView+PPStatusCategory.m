//
//  UIImageView+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "UIImageView+PPStatusCategory.h"

@implementation UIImageView (PPStatusCategory)

-(BOOL)setUIViewStatusMessage:(PPStatusPropertyMessageModel *)message record:(BOOL)record{
    if(![super setUIViewStatusMessage:message record:record]) return NO;
        
    switch (message.propertyType) {
        case PPStatusUIImageViewPropertyTypeImage:{
            self.image = message.propertyValue;
            break;
        }
        default:
            break;
    }
    
    return YES;
}

-(void)setImage:(UIImage *)image forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusUIImageViewPropertyTypeImage propertyValue:image skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

@end
