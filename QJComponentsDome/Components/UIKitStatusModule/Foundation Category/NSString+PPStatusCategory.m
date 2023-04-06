//
//  NSString+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/22.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "NSString+PPStatusCategory.h"

@implementation NSString (PPStatusCategory)

-(NSString *)languageKey {
    return objc_getAssociatedObject(self, @selector(languageKey));
}
-(void)setLanguageKey:(NSString *)languageKey {
    objc_setAssociatedObject(self, @selector(languageKey), languageKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
