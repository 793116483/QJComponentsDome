//
//  QJBaseTableViewCell.m
//  QJSocketDome(环信SDK)
//
//  Created by 瞿杰 on 2019/12/8.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import "QJBaseTableViewCell.h"
#import "QJSwitchModel.h"
#import "QJArrowModel.h"

#define kDefaultSelectedBackground [UIColor colorWithWhite:0.85 alpha:1.0]

@interface QJBaseTableViewCell()

@property (nonatomic , strong) UILabel * hintLabel ;
@property (nonatomic , strong) UIView *  hintUpgrade; // 一个点

@end

@implementation QJBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView * selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = kDefaultSelectedBackground;
    self.selectedBackgroundView = selectedBackgroundView ;
    
    [self.contentView addSubview:self.hintLabel];
    self.imageView.clipsToBounds = YES ;
    self.imageView.layer.cornerRadius = 3 ;
    
    [self.contentView addSubview:self.hintUpgrade];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView * selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = kDefaultSelectedBackground;
        self.selectedBackgroundView = selectedBackgroundView ;
        self.detailTextLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        
        [self.contentView addSubview:self.hintLabel];
        
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.numberOfLines = 0 ;
        self.imageView.clipsToBounds = YES ;
        self.imageView.layer.cornerRadius = 3 ;
        
        [self.contentView addSubview:self.hintUpgrade];
    }
    return self ;
}

-(void)setModel:(QJBaseModel *)model {
    
    _model = model ;
    
    [self.imageView setImage:model.image];
    self.textLabel.text = model.title ;
    self.hintLabel.text = model.hintText ;
    self.hintUpgrade.hidden = !model.isUpgrade ;
    self.detailTextLabel.text = model.subTitle ;
    self.separatorInset = model.separatorInset ;
    
    // 设置 accessory
    self.accessoryType = UITableViewCellAccessoryNone ;
    self.accessoryView = nil ;
    if ([model isKindOfClass:[QJArrowModel class]]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
    } else if ([model isKindOfClass:[QJSwitchModel class]]) {
        UISwitch * switchView = [[UISwitch alloc] init];
        switchView.on = ((QJSwitchModel *)model).on ;
        switchView.onTintColor = [UIColor colorWithRed:47.0/255 green:143.0/255 blue:248.0/255 alpha:1.0];
        [switchView addTarget:self action:@selector(switchViewDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = switchView ;
    }
    self.selected = NO ;
    
    [self layoutIfNeeded];
}

-(void)switchViewDidClicked:(UISwitch *)switchView {
    QJSwitchModel * model = (QJSwitchModel *)self.model ;
    switchView.on = !switchView.on ;
    if ([model.delegate respondsToSelector:@selector(switchModel:switchClicked:)]) {
        [model.delegate switchModel:model switchClicked:switchView];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.hintLabel sizeToFit];
    CGFloat w = self.hintLabel.frame.size.width ;
    CGFloat h = w > 10 ? self.hintLabel.frame.size.height : w ;
    CGFloat x = CGRectGetMaxX(self.textLabel.frame) + 10 ;
    CGFloat y = (self.frame.size.height - h)  / 2.0 ;
    self.hintLabel.frame = CGRectMake(x, y , w , h);
    self.hintLabel.layer.cornerRadius = h / 2 ;
    
    self.hintUpgrade.frame = CGRectMake(self.detailTextLabel.frame.origin.x - 10, (self.frame.size.height - 6)  / 2.0 , 6 , 6);
}

#pragma mark - 懒加载
-(UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.font = [UIFont systemFontOfSize:12];
        _hintLabel.backgroundColor = [UIColor redColor];
        _hintLabel.textColor = [UIColor whiteColor];
        _hintLabel.textAlignment = UITextAlignmentCenter ;
        _hintLabel.clipsToBounds = YES ;
    }
    return _hintLabel ;
}
-(UIView *)hintUpgrade {
    if (!_hintUpgrade) {
        _hintUpgrade = [[UIView alloc] init];
        _hintUpgrade.backgroundColor = [UIColor colorWithRed:47.0/255 green:143.0/255 blue:248.0/255 alpha:1.0] ;
        _hintUpgrade.layer.cornerRadius = 3 ;
        _hintUpgrade.clipsToBounds = YES ;
    }
    return _hintUpgrade ;
}
@end
