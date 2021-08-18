//
//  QJBaseTableViewCell.h
//  QJSocketDome(环信SDK)
//
//  Created by 瞿杰 on 2019/12/8.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QJBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJBaseTableViewCell : UITableViewCell

@property (nonatomic , strong) QJBaseModel * model ;

@end

NS_ASSUME_NONNULL_END
