//
//  PPLabelItemCell.m
//  PatPat
//
//  Created by 杰 on 2021/8/4.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "PPLabelItemCell.h"
#import "PPLabelItemModel.h"

@interface PPLabelItemCell ()

@property (nonatomic , strong) UILabel * titleLabel ;

@end

@implementation PPLabelItemCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds ;
}

-(void)setModel:(PPLabelItemModel *)model {
    [super setModel:model];
    
    self.titleLabel.text = model.title ;
    self.titleLabel.font = model.normalFont ;
    
    if (model.selected) {
        self.titleLabel.textColor = model.selectedTitleColor ;
    }else{
        self.titleLabel.textColor = model.normalTitleColor ;
    }
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 0 ;
        _titleLabel.textAlignment = NSTextAlignmentCenter ;
    }
    return _titleLabel;
}

@end
