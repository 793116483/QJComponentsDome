//
//  QJBaseTableViewController.m
//  QJSocketDome(环信SDK)
//
//  Created by 瞿杰 on 2019/12/8.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import "QJBaseTableViewController.h"

@interface QJBaseTableViewController ()

@end

@implementation QJBaseTableViewController

static const NSString * kReuseIdentifier = @"QJBaseTableViewCell" ;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.selectedNothingWhenDisappear = YES ;
    self.showSelectBacgroundWhenEnable = YES ;
    
    // 添加 tableView
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.safeFrame ;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.selectedNothingWhenDisappear) {
        for (NSIndexPath * selectIndexPath in self.tableView.indexPathsForSelectedRows) {
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:selectIndexPath];
            cell.selected = NO ;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.groups.count == 0) return 1 ;
    return self.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.groups.count <= section) {
        return 0 ;
    }
    QJGroupModel * groupModel = [self.groups objectAtIndex:section];
    
    return groupModel.models.count;
}

#pragma mark - cell 相关
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJBaseModel * model = self.groups[indexPath.section].models[indexPath.row];
    
    QJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier forIndexPath:indexPath];
    cell = [cell initWithStyle:model.style reuseIdentifier:kReuseIdentifier];
    cell.model = model ;
    
    // 选中状态，背景是否显示
    if (!model.showSelectBacground) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    }
    else if (!self.showSelectBacgroundWhenEnable) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault ;
    } else if ([self respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault ;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight ;
}

#pragma mark - Group 相关
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.groups.count <= section) {
        return nil ;
    }
    QJGroupModel * groupModel = [self.groups objectAtIndex:section];
    return groupModel.headerTitle ;
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.groups.count <= section) {
        return nil ;
    }
    QJGroupModel * groupModel = [self.groups objectAtIndex:section];
    return groupModel.footerTitle ;
}
CGFloat deviationWH = 0.000001 ; // 设置误差，防止在显示时 0 设置无效
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.groups.count <= section) {
        return nil ;
    }
    QJGroupModel * groupModel = [self.groups objectAtIndex:section];
    UIView * headerView = groupModel.headerView ;
    if (headerView) {
        UIView * contentHeaderView = [[UIView alloc] init] ;
        contentHeaderView.tag = section ;
        contentHeaderView.backgroundColor = [UIColor clearColor];
        [contentHeaderView addSubview:headerView];
        // 先确认位置
        if (headerView.frame.size.height < deviationWH || headerView.frame.size.width < deviationWH) {
            CGFloat width = headerView.frame.size.width < deviationWH ? groupModel.headerSize.width : headerView.frame.size.width;
            CGFloat height = headerView.frame.size.height < deviationWH ? groupModel.headerSize.height : headerView.frame.size.height;
            headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, width, height);
        }
        // 添加点击事件
        if ([groupModel.delegate respondsToSelector:@selector(groupModel:didSelectHeaderView:)]) {
            [contentHeaderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewDidClicked:)]];
        }
        return contentHeaderView ;
    }
    return nil ;
}
-(void)headerViewDidClicked:(UITapGestureRecognizer *)tapGesture{
    UIView * contentView = tapGesture.view ;
    QJGroupModel * groupModel = [self.groups objectAtIndex:contentView.tag];
    if ([groupModel.delegate respondsToSelector:@selector(groupModel:didSelectHeaderView:)]) {
        [groupModel.delegate groupModel:groupModel didSelectHeaderView:groupModel.headerView];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.groups.count <= section) {
        return nil ;
    }
    QJGroupModel * groupModel = [self.groups objectAtIndex:section];
    UIView * footerView = groupModel.footerView ;
    if (footerView) {
        UIView * contentFooterView = [[UIView alloc] init] ;
        contentFooterView.tag = section ;
        contentFooterView.backgroundColor = [UIColor clearColor];
        [contentFooterView addSubview:footerView];
        // 先确认位置
        if (footerView.frame.size.height < deviationWH || footerView.frame.size.width < deviationWH) {
            CGFloat width = footerView.frame.size.width < deviationWH ? groupModel.footerSize.width : footerView.frame.size.width;
            CGFloat height = footerView.frame.size.height < deviationWH ? groupModel.footerSize.height : footerView.frame.size.height;
            footerView.frame = CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y, width, height);
        }
        // 添加点击事件
        if ([groupModel.delegate respondsToSelector:@selector(groupModel:didSelectFooterView:)]) {
            [contentFooterView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerViewDidClicked:)]];
        }
        return contentFooterView ;
    }
    return nil ;
}
-(void)footerViewDidClicked:(UITapGestureRecognizer *)tapGesture{
    UIView * contentView = tapGesture.view ;
    QJGroupModel * groupModel = [self.groups objectAtIndex:contentView.tag];
    if ([groupModel.delegate respondsToSelector:@selector(groupModel:didSelectFooterView:)]) {
        [groupModel.delegate groupModel:groupModel didSelectFooterView:groupModel.footerView];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.groups.count <= section) {
        return deviationWH ;
    }
    QJGroupModel * groupModel = [self.groups objectAtIndex:section];
    if(groupModel.section == 0) [groupModel setValue:@(section) forKeyPath:@"section"];

    CGFloat height = 0 ;
    if (groupModel.headerView.frame.size.height) {
        height = groupModel.headerView.frame.size.height ;
    } else {
        height = groupModel.headerSize.height ;
    }
    if (height < deviationWH) {
        height = deviationWH;
    }
    return height ;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.groups.count <= section) {
        return deviationWH ;
    }
    QJGroupModel * groupModel = [self.groups objectAtIndex:section];
    
    CGFloat height = 0 ;
    if (groupModel.footerView.frame.size.height) {
        height = groupModel.footerView.frame.size.height ;
    } else {
        height = groupModel.footerSize.height ;
    }
    if (height < deviationWH) {
        height = deviationWH;
    }
    return height ;
}

#pragma mark - 工具方法
-(void)addGroup:(QJGroupModel *)group {
    if (group) {
        [self.groups addObject:group];
    }
}

#pragma mark - 懒加载
-(NSMutableArray<QJGroupModel *> *)groups {
    if (!_groups) {
        _groups = [NSMutableArray array];
    }
    return _groups ;
}

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self ;
        _tableView.dataSource = self ;
        _tableView.backgroundColor = self.view.backgroundColor ;
        _tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1.0] ;
        _tableView.rowHeight = 50 ;
        _tableView.sectionHeaderHeight = 0 ;
        _tableView.sectionFooterHeight = 0 ;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        [_tableView registerClass:[QJBaseTableViewCell class] forCellReuseIdentifier:kReuseIdentifier];
        // 为了去掉多余的线条
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView ;
}

-(CGRect)safeFrame {
    if (@available(iOS 11.0, *)) {
        return CGRectMake(0, self.view.safeAreaInsets.top, self.view.frame.size.width, self.view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom);
    } else {
        return self.view.bounds ;
    }
}

@end
