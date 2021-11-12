//
//  PPExtensibleLabel.h
//  PatPat
//
//  Created by 杰 on 2021/11/3.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//  带展开Label内容的按钮

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPExtensibleLabel : UILabel

@property (nonatomic , copy) void(^unflodAction)(void) ;

@end

NS_ASSUME_NONNULL_END
