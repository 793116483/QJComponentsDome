//
//  QJGroupModel.m
//  QJSocketDome(环信SDK)
//
//  Created by 瞿杰 on 2019/12/8.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import "QJGroupModel.h"

@implementation QJGroupModel

+(instancetype)groupModel{
    QJGroupModel * model = [[self alloc] init];
    return model ;
}

-(void)addBaseModel:(QJBaseModel *)model {
    if (model) {
        [self.models addObject:model];
    }
}

#pragma mark - 懒加载
-(void)setHeaderSize:(CGSize)headerSize {
    _headerSize = headerSize ;
    if (self.headerView.frame.size.height <= 0) {
        self.headerView.frame = CGRectMake(0, 0, headerSize.width, headerSize.height);
    }
}
-(void)setHeaderView:(UIView *)headerView {
    _headerView = headerView ;
    if (_headerView.frame.size.height <= 0) {
        self.headerView.frame = CGRectMake(0, 0, self.headerSize.width, self.headerSize.height);
    }
}
-(void)setFooterSize:(CGSize)footerSize {
    _footerSize = footerSize ;
    if (self.footerView.frame.size.height <= 0) {
        self.footerView.frame = CGRectMake(0, 0, footerSize.width, footerSize.height);
    }
}
-(void)setFooterView:(UIView *)footerView {
    _footerView = footerView ;
    if (_footerView.frame.size.height <= 0) {
        _footerView.frame = CGRectMake(0, 0, self.footerSize.width, self.footerSize.height);
    }
}

-(NSMutableArray<QJBaseModel *> *)models {
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models ;
}

@end
