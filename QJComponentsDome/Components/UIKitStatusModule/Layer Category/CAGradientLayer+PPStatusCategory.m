//
//  CAGradientLayer+PPStatusCategory.m
//  PatPat
//
//  Created by lixiao on 2023/3/23.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "CAGradientLayer+PPStatusCategory.h"

@implementation CAGradientLayer (PPStatusCategory)

-(BOOL)setCALayerStatusMessage:(PPStatusPropertyMessageModel *)message record:(BOOL)record {
    if(![super setCALayerStatusMessage:message record:record]) return NO;
        
    switch (message.propertyType) {
        case PPStatusCAGradientLayerPropertyTypeColors: {
            self.colors = message.propertyValue;
            break;
        }
        default:
            break;
    }
    
    return YES;
    
}

- (void)setColors:(NSArray *)colors forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusCAGradientLayerPropertyTypeColors propertyValue:colors skinStatusStyle:skinStatusStyle];
    [self setCALayerStatusMessage:message record:YES];
}



@end
