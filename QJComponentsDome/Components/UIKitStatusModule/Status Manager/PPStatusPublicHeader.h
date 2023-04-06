//
//  PPStatusPublicHeader.h
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#ifndef PPStatusPublicHeader_h
#define PPStatusPublicHeader_h

typedef enum : NSUInteger {
    PPSkinStatusStyleUnSpecified,   // 未指定，则跟随顶部控制器模式
    PPSkinStatusStyleLight,         // 亮色模式
    PPSkinStatusStyleDark,          // 暗黑模式
} PPSkinStatusStyle;


/** 对应 PPStatusSetModel 类属性 */
typedef enum : NSUInteger {
    PPStatusSetModelPropertyTypeSkin = 1 << 0,        // 观察 skinStatusStyle 属性
    PPStatusSetModelPropertyTypeLanguage = 1 << 1,
    PPStatusSetModelPropertyTypeAll = 0xffffffff,
} PPStatusSetModelPropertyType;

#endif /* PPStatusPublicHeader_h */
