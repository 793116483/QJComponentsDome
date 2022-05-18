//
//  PPNavigationBar.m
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPNavigationBar.h"
#import "UIViewController+PPPresentTransition.h"
#import "NSObject+PPObserver.h"
#import <Masonry/Masonry.h>

@interface PPNavigationBar ()

@property (nonatomic , weak) UIViewController * vc ;

@end

@implementation PPNavigationBar

-(instancetype)initWithViewController:(UIViewController *)vc {
    if (self = [super init]) {
        self.vc = vc;
        self.bounds = CGRectMake(0, 0, 0, kSlideInOutNavigationBarHeight);
        self.backgroundColor = [UIColor whiteColor];
        
        
//        self.leftView = self.vc.navigationItem.leftBarButtonItem.customView;
        [self resetTitleView];
        [self resetCloseButton];
        
        self.bottomLineView = [UIView new];
        self.bottomLineView.backgroundColor = [UIColor colorWithRed:241/255.0 green:243/255.0 blue:242/255.0 alpha:1.0];
        
        __weak typeof(self) weakSelf = self ;
        [self.vc addObserverForKeyPath:@"title" userInfo:nil didChangedValueBlock:^(PPObjectObserverModel * _Nonnull observerModel) {
            [weakSelf resetTitleView];
        } removeObserverWhenTargetDalloc:self];
        [self.vc.navigationItem addObserverForKeyPath:@"titleView" userInfo:nil didChangedValueBlock:^(PPObjectObserverModel * _Nonnull observerModel) {
            if ([weakSelf.vc.navigationItem.titleView isKindOfClass:[UILabel class]]) {
                [weakSelf resetTitleView];
            }
        } removeObserverWhenTargetDalloc:self];
        
//        [self.vc.navigationItem addObserverForKeyPath:@"leftBarButtonItem" userInfo:nil didChangedValueBlock:^(PPObjectObserverModel * _Nonnull observerModel) {
//            weakSelf.leftView = weakSelf.vc.navigationItem.leftBarButtonItem.customView;
//        } removeObserverWhenTargetDalloc:self];
//
//        [self.vc.navigationItem addObserverForKeyPath:@"rightBarButtonItem" userInfo:nil didChangedValueBlock:^(PPObjectObserverModel * _Nonnull observerModel) {
//            weakSelf.rightView = weakSelf.vc.navigationItem.rightBarButtonItem.customView;
//        } removeObserverWhenTargetDalloc:self];
    }
    return self;
}

-(void)closeAction:(UIButton *)btn {
    // 关闭可能出现的键盘
    [self.vc.view endEditing:YES];
    
    [self.vc disappearViewController];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
//    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(12, 12)];
}

-(void)resetTitleView {
    UIFont * titleFont = [UIFont systemFontOfSize:16];
    UIColor * titleColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0];
    
    NSString * title = self.vc.title;
    if ([self.vc.navigationItem.titleView isKindOfClass:[UILabel class]]) {
        UILabel * label = (UILabel*)self.vc.navigationItem.titleView;
        if (label.text.length) {
            title = label.text;
        }
    }
    UILabel * titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = titleFont;
    titleLabel.textColor = titleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleView = titleLabel;
}

-(void)resetCloseButton {
//    UIButton * closeBtn = [UIButton createButton:CGRectZero action:@selector(closeAction:) delegate:self normalImage:Image(@"close") highlightedImage:Image(@"close")];
//    closeBtn.bounds = CGRectMake(0, 0, 30, 30);
//    self.rightView = closeBtn;
}

-(void)setLeftView:(UIView *)leftView {
    
    if (_leftView != leftView) {
        [_leftView removeFromSuperview];
        _leftView = leftView;
        if (_leftView) {
            [self addSubview:_leftView];
        }
    }
    
    if ([_leftView superview]) {
        if (_leftView.frame.size.width < 1 || _leftView.frame.size.height < 1) {
            [_leftView sizeToFit];
        }
        [_leftView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(15);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(_leftView.frame.size);
        }];
    }
    
    self.titleView = self.titleView;
}

-(void)setTitleView:(UIView *)titleView {
    
    if (_titleView != titleView) {
        [_titleView removeFromSuperview];
        _titleView = titleView;
        if (_titleView) {
            [self insertSubview:_titleView atIndex:0];
        }
    }
    
    if ([_titleView superview]) {
        if (_titleView.frame.size.width < 1 || _titleView.frame.size.height < 1) {
            [_titleView sizeToFit];
        }
        [_titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            if ([_titleView isKindOfClass:[UILabel class]]) { // 自适应
                // 左
                if ([self.leftView superview] == [_titleView superview]) {
                    make.leading.greaterThanOrEqualTo(self.leftView.mas_trailing).offset(8);
                }else{
                    make.leading.greaterThanOrEqualTo(self).offset(15);
                }
                // 右
                if ([self.rightView superview] == [_titleView superview]) {
                    make.trailing.lessThanOrEqualTo(self.rightView.mas_leading).offset(-8);
                }else{
                    make.trailing.lessThanOrEqualTo(self).offset(-15);
                }
            }else{
                make.size.mas_equalTo(_titleView.frame.size);
            }
        }];
    }
}

-(void)setRightView:(UIView *)rightView {
    
    if (_rightView != rightView) {
        [_rightView removeFromSuperview];
        _rightView = rightView;
        if (_rightView) {
            [self addSubview:_rightView];
        }
    }
    
    if ([_rightView superview]) {
        if (_rightView.frame.size.width < 1 || _rightView.frame.size.height < 1) {
            [_rightView sizeToFit];
        }
        [_rightView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-15);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(_rightView.frame.size);
        }];
    }
    
    self.titleView = self.titleView;
}

-(void)setBottomLineView:(UIView *)bottomLineView {
    if (_bottomLineView != bottomLineView) {
        [_bottomLineView removeFromSuperview];
        _bottomLineView = bottomLineView;
        if (_bottomLineView) {
            [self addSubview:_bottomLineView];
        }
    }
    if ([_bottomLineView superview]) {
        [_bottomLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self);
            make.height.mas_equalTo(_bottomLineView.frame.size.height?:0.5);
        }];
    }
}

@end
