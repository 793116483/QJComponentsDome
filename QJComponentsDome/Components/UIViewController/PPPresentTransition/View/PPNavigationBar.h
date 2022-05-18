//
//  PPNavigationBar.h
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPNavigationBar : UIView

@property (nonatomic , strong , nullable) UIView * leftView ;
@property (nonatomic , strong , nullable) UIView * titleView ;
@property (nonatomic , strong , nullable) UIView * rightView ;
@property (nonatomic , strong , nullable) UIView * bottomLineView ;

-(instancetype)initWithViewController:(UIViewController *)vc;

/// 重新设置关闭按钮
-(void)resetCloseButton;

@end

NS_ASSUME_NONNULL_END
