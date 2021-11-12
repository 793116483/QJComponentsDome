//
//  PPTapMenumContainerView.h
//  PatPat
//
//  Created by 杰 on 2021/8/3.
//  Copyright © 2021 All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PPTapMenumContainerView , PPTapMenumBaseModel;

@protocol PPTapMenumContainerViewDelegate <NSObject>

- (void)tapMenumContainerView:(PPTapMenumContainerView *)tapMenumView selectedModel:(PPTapMenumBaseModel *)model;

@end


@interface PPTapMenumContainerView : UIView

@property (nonatomic, weak)id <PPTapMenumContainerViewDelegate>delegate;

+(instancetype)tapMenumViewWithLineSpace:(CGFloat)lineSpace interitemSpace:(CGFloat)interitemSpace contentInset:(UIEdgeInsets)contentInset;

+(instancetype)tapMenumViewWithLineSpace:(CGFloat)lineSpace
                          interitemSpace:(CGFloat)interitemSpace
                            contentInset:(UIEdgeInsets)contentInset
                           pagingEnabled:(BOOL)pagingEnabled
                      didChangePageBlock:(nullable void(^)(NSInteger pageIndex))didChangePageBlock ;

/// @param datas 对应的每个item数据
- (void)loadDatas:(nonnull NSArray<PPTapMenumBaseModel *> *)datas selectedModel:(PPTapMenumBaseModel *)selectedModel;

/// 更换数据
/// @param datas 对应的每个item数据
/// @param selectedModel 选中的模型
/// @param loopScrollEnabel 是否支持循环滑动，当且仅当支持分页功能时才有用
- (void)loadDatas:(nonnull NSArray<PPTapMenumBaseModel *> *)datas selectedModel:(PPTapMenumBaseModel *)selectedModel loopScrollEnabel:(BOOL)loopScrollEnabel;

/// 在 datas 选中的模型
/// 1.如果支持分页：滑动结束时为当前页显示对应的数据模型 或 主动选中的模型；
/// 2.如果不支持分页则为主动选中的模型
@property (nonatomic, strong) PPTapMenumBaseModel * selectedModel;

-(void)selectedModel:(PPTapMenumBaseModel *)selectedModel animation:(BOOL)animation ;
-(void)selectedModel:(PPTapMenumBaseModel *)selectedModel animation:(BOOL)animation needCallbackDelegate:(BOOL)needCallbackDelegate;

/// 获取 datas
- (NSArray<PPTapMenumBaseModel *> *)datas ;

@end

NS_ASSUME_NONNULL_END
