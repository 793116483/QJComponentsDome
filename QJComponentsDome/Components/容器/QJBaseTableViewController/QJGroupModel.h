//
//  QJGroupModel.h
//  QJSocketDome(环信SDK)
//
//  Created by 瞿杰 on 2019/12/8.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QJBaseModel.h"
#import "QJArrowModel.h"
#import "QJSwitchModel.h"

NS_ASSUME_NONNULL_BEGIN

@class QJGroupModel ;

@protocol QJGroupModelDelegate <NSObject>

@optional
-(void)groupModel:(QJGroupModel *)groupModel didSelectHeaderView:(UIView *)headerView;
-(void)groupModel:(QJGroupModel *)groupModel didSelectFooterView:(UIView *)footerView;

@end


@interface QJGroupModel : NSObject

#pragma mark - 属性
// 注意: 1. header or footer size 优先级底于 header or footer view 设置的 size ;   2. 创建时设置
@property (nonatomic , assign) CGSize   headerSize ;
@property (nonatomic , strong) UIView * headerView ;
@property (nonatomic , copy) NSString * headerTitle ;

@property (nonatomic , assign) CGSize   footerSize ;
@property (nonatomic , strong) UIView * footerView ;
@property (nonatomic , copy) NSString * footerTitle ;

/// 代理
@property (nonatomic , weak) id<QJGroupModelDelegate> delegate ;
/// 当前组号
@property (nonatomic , assign , readonly) NSUInteger section ;
/// 模型数据
@property (nonatomic , strong) NSMutableArray<QJBaseModel *> * models ;

#pragma mark - 方法
/// 创建组模型
+(instancetype)groupModel ;

/// 当前组 添加 一个 QJBaseModel及其子类 模型对象
/// @param model QJBaseModel及其子类 模型对象
-(void)addBaseModel:(nonnull QJBaseModel *)model ;

@end

NS_ASSUME_NONNULL_END
