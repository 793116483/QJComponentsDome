//
//  PPExtensibleLabel.m
//  PatPat
//
//  Created by 杰 on 2021/11/3.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "PPExtensibleLabel.h"
#import <Masonry/Masonry.h>

@interface PPExtensibleLabel ()

@property (nonatomic , strong) UIView * moreContentView ;
@property (nonatomic , strong) UILabel * ellipsisLabel ;
@property (nonatomic , strong) UIButton * moreButton ;

@end

@implementation PPExtensibleLabel
-(void)awakeFromNib {
    [super awakeFromNib];
    [self initUI];
}
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}
-(void)initUI {
    self.userInteractionEnabled = YES ;
    [self addSubview:self.moreContentView];
    [self.moreContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.equalTo(self);
    }];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.moreButton sizeToFit];
    [self.moreButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.moreButton.frame.size.height);
        make.width.mas_equalTo(self.moreButton.frame.size.width + 3);
    }];
    
    if (self.font.lineHeight > 0) {
        // 计算理论上需要多少行
        CGFloat labelTextHeight = [self sizeWithMaxWidth:self.bounds.size.width font:self.font lineBreakModel:self.lineBreakMode].height;
        NSInteger labelTextLines = labelTextHeight / self.font.lineHeight ;
        // 实际显示的行数
        NSInteger labelShowLines = self.bounds.size.height / self.font.lineHeight ;
        
        self.moreContentView.hidden = labelShowLines >= labelTextLines ;
    }
}
- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth
                      font:(UIFont *)font
            lineBreakModel:(NSLineBreakMode)mode
{
    CGSize textBlockMinSize = {maxWidth,CGFLOAT_MAX};
    CGSize size = [self.text sizeWithFont:font constrainedToSize:textBlockMinSize lineBreakMode:mode];
    return size;
}

-(void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    
    self.ellipsisLabel.textColor = textColor ;
}
-(void)setFont:(UIFont *)font {
    [super setFont:font];
    
    self.ellipsisLabel.font = font ;
    self.moreButton.titleLabel.font = font ;
    [self setNeedsLayout];
}
-(void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsLayout];
}

-(UIView *)moreContentView {
    if (!_moreContentView) {
        _moreContentView = [UIView new];
        _moreContentView.backgroundColor = [UIColor whiteColor];
        
        [_moreContentView addSubview:self.ellipsisLabel];
        [_moreContentView addSubview:self.moreButton];
        
        [self.ellipsisLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.equalTo(_moreContentView);
            make.trailing.equalTo(self.moreButton.mas_leading).offset(-4);
        }];
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.bottom.equalTo(_moreContentView);
            make.height.mas_equalTo(self.moreButton.frame.size.height);
            make.width.mas_equalTo(self.moreButton.frame.size.width + 5);
        }];
    }
    return _moreContentView;
}
-(UILabel *)ellipsisLabel {
    if (!_ellipsisLabel) {
        _ellipsisLabel = [UILabel new];
        _ellipsisLabel.text = @"...";
    }
    return _ellipsisLabel;
}
-(UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setTitle:@"More" forState:UIControlStateNormal];
        [_moreButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _moreButton;
}

-(void)moreButtonAction {
    self.numberOfLines = 0 ;
    
    if (self.unflodAction) {
        self.unflodAction();
    }
}

@end
