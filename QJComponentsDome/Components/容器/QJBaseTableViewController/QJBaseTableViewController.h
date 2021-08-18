//
//  QJBaseTableViewController.h
//  QJSocketDome(环信SDK)
//
//  Created by 瞿杰 on 2019/12/8.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QJGroupModel.h"
#import "QJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJBaseTableViewController : UIViewController <UITableViewDelegate , UITableViewDataSource>

/// view 的可视区域在 屏幕上的 frame
@property (nonatomic , readonly) CGRect safeFrame ;
@property (nonatomic , strong) UITableView * tableView ;

/// 当控制器消失时，选中的 cell 回复原样 ， 默认为 YES
@property (nonatomic , assign) BOOL selectedNothingWhenDisappear ;
/// 当 cell 可以选中时，才显示选中背景，默认为 YES
@property (nonatomic , assign) BOOL showSelectBacgroundWhenEnable ;

@property (nonatomic , strong) NSMutableArray<QJGroupModel *> * groups ;
-(void)addGroup:(nonnull QJGroupModel *)group ;

@end

NS_ASSUME_NONNULL_END
