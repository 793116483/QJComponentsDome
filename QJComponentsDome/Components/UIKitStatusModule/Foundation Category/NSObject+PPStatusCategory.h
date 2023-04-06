//
//  NSObject+PPStatusCategory.h
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPStatusPublicHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class PPStatusSetModel;

@interface NSObject (PPStatusCategory)

// ----- 方法重写 ----
/// 当 object 的 propertyType 类型属性变化时调用当前方法
/// - Parameters:
///   - propertyType: 改变属性对应的类型
///   - statusSetModel: 状态集模型
-(void)observeStatusChangeForPropertyType:(PPStatusSetModelPropertyType)propertyType ofStatusSetModel:(PPStatusSetModel*)statusSetModel;

@end

NS_ASSUME_NONNULL_END
