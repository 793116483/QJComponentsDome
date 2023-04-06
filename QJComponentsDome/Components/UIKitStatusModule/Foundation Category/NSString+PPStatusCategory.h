//
//  NSString+PPStatusCategory.h
//  PatPat
//
//  Created by 杰 on 2023/3/22.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PPStatusCategory)

/// 当前多语言对应的 key
@property (nonatomic, strong) NSString * languageKey;

@end

NS_ASSUME_NONNULL_END
