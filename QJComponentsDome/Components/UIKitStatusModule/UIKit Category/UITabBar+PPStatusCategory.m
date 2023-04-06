//
//  UITabBar+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/19.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "UITabBar+PPStatusCategory.h"

@implementation UITabBar (PPStatusCategory)

-(void)resetViewAndSubViewSkin {
    [super resetViewAndSubViewSkin];
    
    switch (self.skinStatusStyle) {
        case PPSkinStatusStyleUnSpecified:
        case PPSkinStatusStyleLight: {
            if (@available(iOS 13.0, *)) {
                self.barStyle = UIBarStyleDefault;
                /**
                 iOS13跟不跟随系统都需要设置为Default
                 iOS13的NavigationBar的亮/暗，不是设置barStyle而是设置overrideUserInterfaceStyle来实现的
                 因为barStyle没有Light的值~.~，如果不设置override会跟着系统模式而更改。
                 */
                self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            } else {
                self.barStyle = UIBarStyleDefault;
            }
            break;
        }
        case PPSkinStatusStyleDark: {
            if (@available(iOS 13.0, *)) {
                self.barStyle = UIBarStyleDefault;
                self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            } else {
                self.barStyle = UIBarStyleBlack;
            }
            break;
        }
        default:
            break;
    }
}

@end
