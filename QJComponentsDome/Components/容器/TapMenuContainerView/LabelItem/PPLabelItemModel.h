//
//  PPLabelItemModel.h
//  PatPat
//
//  Created by 杰 on 2021/8/4.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "PPTapMenumBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PPLabelItemModel : PPTapMenumBaseModel

@property (nonatomic,strong) NSString* title;

/// 未选中的字体 , 默认为 12 大小
@property (nonatomic,strong) UIFont * normalFont ;

/// 未选中的颜色 , 默认为 #444444
@property (nonatomic, strong) UIColor * normalTitleColor ;
/// 选中的颜色，默认为 #F1435A
@property (nonatomic, strong) UIColor * selectedTitleColor ;

@end

NS_ASSUME_NONNULL_END
