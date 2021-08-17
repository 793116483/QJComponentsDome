//
//  PPTapMenumContainerView.h
//  PatPat
//
//  Created by 杰 on 2021/8/3.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
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

/// @param datas 对应的每个item数据
- (void)loadDatas:(nonnull NSArray<PPTapMenumBaseModel *> *)datas selectedModel:(PPTapMenumBaseModel *)selectedModel;


/// 在 datas 选中的模型
@property (nonatomic, strong) PPTapMenumBaseModel * selectedModel;

-(void)selectedModel:(PPTapMenumBaseModel *)selectedModel animation:(BOOL)animation ;
-(void)selectedModel:(PPTapMenumBaseModel *)selectedModel animation:(BOOL)animation needCallbackDelegate:(BOOL)needCallbackDelegate;

@end

NS_ASSUME_NONNULL_END
