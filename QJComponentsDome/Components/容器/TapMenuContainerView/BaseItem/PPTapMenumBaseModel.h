//
//  PPTapMenumBaseModel.h
//  PatPat
//
//  Created by 杰 on 2021/8/4.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPTapMenumBaseModel : NSObject


// item 的 cell 类型, 必须为 PPTapMenumBaseCell 及其子类
@property (nonatomic, strong , nonnull) Class cellClass ;
/// 复用 cellClass 标志，默认为 cellClass 类名
@property (nonatomic, strong , nonnull) NSString * reuseIdentifier ;
// item 的 size 大小
@property (nonatomic, assign) CGSize itemSize ;


// 圆角半径 , 默认为 0
@property (nonatomic, assign) CGFloat cornerRadius ;
// 边框宽度, 默认为 0.5
@property (nonatomic, assign) CGFloat borderWidth ;

//是否被选中
@property (nonatomic, assign) BOOL selected;
/// 未选中的颜色 , 默认为 #F8F8F7
@property (nonatomic, strong) UIColor * normalBorderColor ;
/// 选中的颜色，默认为 #FFD7D7
@property (nonatomic, strong) UIColor * selectedBorderColor ;

/// 未选中的背景颜色 , 默认为 #F8F8F7
@property (nonatomic, strong) UIColor * normalBackgroundColor ;
/// 选中的背景颜色，默认为 #FFF6F6
@property (nonatomic, strong) UIColor * selectedBackgroundColor ;

/// 预留的 object
@property (nonatomic,strong) id otherObject ;

@end

NS_ASSUME_NONNULL_END
