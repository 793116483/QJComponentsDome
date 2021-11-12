//
//  PPTapMenumContainerView.m
//  PatPat
//
//  Created by 杰 on 2021/8/3.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "PPTapMenumContainerView.h"
#import "PPTapMenumBaseCell.h"
#import "PPTapMenumBaseModel.h"
#import "NSObject+PPObserver.h"

@interface  PPTapMenumContainerView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) CGFloat interitemSpacing;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<PPTapMenumBaseModel *> *dataSource;
@property (nonatomic, strong) NSArray<PPTapMenumBaseModel *> *datas;

@property (nonatomic, assign) BOOL loopScrollEnabel;
/// 在collectionView准备好前，防止数据刷新cell导致崩溃
@property (nonatomic, assign) BOOL reloadDataEnabel;

@end

@implementation PPTapMenumContainerView

+(instancetype)tapMenumViewWithLineSpace:(CGFloat)lineSpace
                          interitemSpace:(CGFloat)interitemSpace
                            contentInset:(UIEdgeInsets)contentInset
                           pagingEnabled:(BOOL)pagingEnabled
                      didChangePageBlock:(nullable void (^)(NSInteger))didChangePageBlock {
    
    PPTapMenumContainerView * view = [self tapMenumViewWithLineSpace:lineSpace interitemSpace:interitemSpace contentInset:contentInset];
    view.collectionView.pagingEnabled = pagingEnabled ;
    
    if (pagingEnabled) {
        // 添加页码变动监听
        __weak typeof(view) weakView = view ;
        [view.collectionView addObserverForKeyPath:@"contentOffset" userInfo:nil didChangedValueBlock:^(PPObjectObserverModel * _Nonnull observerModel) {
            
            if (weakView.collectionView.frame.size.width > 0) {
                CGFloat contentOffsetX = weakView.collectionView.contentOffset.x ;

                NSInteger pageIndex  = (contentOffsetX + view.collectionView.frame.size.width * 0.5) / weakView.collectionView.frame.size.width ;
                if (pageIndex >= view.dataSource.count || pageIndex < 0) {
                    return;
                }
                
                PPTapMenumBaseModel * selectedModel = [weakView.dataSource objectAtIndex:pageIndex];
                if (view.selectedModel != selectedModel) {
                    [weakView selectedModel:selectedModel animation:NO needCallbackDelegate:NO needSetContentOffset:NO];
                }
                
                if (didChangePageBlock){
                    didChangePageBlock([weakView.datas indexOfObject:weakView.selectedModel]);
                }
            }
            
        } removeObserverWhenTargetDalloc:view];
    }
    
    return view;
}

+(instancetype)tapMenumViewWithLineSpace:(CGFloat)lineSpace interitemSpace:(CGFloat)interitemSpace contentInset:(UIEdgeInsets)contentInset{
    PPTapMenumContainerView * view = [[self alloc] init];
    view.lineSpacing = lineSpace ;
    view.interitemSpacing = interitemSpace ;
    view.collectionView.contentInset = contentInset ;
    
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _lineSpacing = 10 ;
        _interitemSpacing = 10 ;
        
        [self addSubview:self.collectionView];
    }
    return self;
}
-(void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds ;
}

#pragma mark - Public Method
-(void)loadDatas:(NSArray<PPTapMenumBaseModel *> *)datas selectedModel:(PPTapMenumBaseModel *)selectedModel {
    [self loadDatas:datas selectedModel:selectedModel loopScrollEnabel:NO];
}

-(void)loadDatas:(NSArray<PPTapMenumBaseModel *> *)datas selectedModel:(PPTapMenumBaseModel *)selectedModel loopScrollEnabel:(BOOL)loopScrollEnabel {
    [self.dataSource removeAllObjects];
    self.datas = datas ;
    self.loopScrollEnabel = NO ;
    self.reloadDataEnabel = NO ;
    
    if ([datas isKindOfClass:[NSArray class]]) {
        if (self.semanticContentAttribute == UISemanticContentAttributeForceRightToLeft) {
            [datas enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PPTapMenumBaseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.dataSource addObject:obj];
            }];
        } else {
            [self.dataSource addObjectsFromArray:datas];
        }
        
        if (self.dataSource.count >= 2 && loopScrollEnabel && self.collectionView.pagingEnabled) {
            PPTapMenumBaseModel * fisrtModel = self.dataSource.firstObject ;
            PPTapMenumBaseModel * lastModel = self.dataSource.lastObject ;
            [self.dataSource insertObject:lastModel atIndex:0];
            [self.dataSource addObject:fisrtModel];
            self.loopScrollEnabel = YES ;
        }
    }
        
    [self.dataSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PPTapMenumBaseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.collectionView registerClass:obj.cellClass forCellWithReuseIdentifier:obj.reuseIdentifier];
    }];
    
    // 关闭隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [self.collectionView setContentOffset:CGPointMake(-self.collectionView.contentInset.left, 0) animated:NO];
    [CATransaction commit];
    
    // 监听 contentSize 改变
    __weak typeof(self) weakSelf = self ;
    [self.collectionView addObserverForKeyPath:@"contentSize" userInfo:nil didChangedValueBlock:^(PPObjectObserverModel * _Nonnull observerModel) {
        // 移除 监听 contentSize 改变
        [weakSelf.collectionView removeObserverForKeyPath:@"contentSize"];
        weakSelf.reloadDataEnabel = YES ;
        
        if (weakSelf.semanticContentAttribute == UISemanticContentAttributeForceRightToLeft) {
            CGFloat contentOffset = weakSelf.collectionView.contentSize.width - weakSelf.collectionView.frame.size.width + weakSelf.collectionView.contentInset.right;
            contentOffset = contentOffset < 0 ? 0 : contentOffset ;
            [weakSelf.collectionView setContentOffset:CGPointMake(contentOffset, 0) animated:NO];
        }
        
        // 设置当前选中,并刷新
        [weakSelf selectedModel:selectedModel animation:NO needCallbackDelegate:NO];
        
    } removeObserverWhenTargetDalloc:self];
    
}

#pragma mark - 选中某个 cell 做动画
-(void)selectedModel:(PPTapMenumBaseModel *)selectedModel animation:(BOOL)animation {
    [self selectedModel:selectedModel animation:animation needCallbackDelegate:YES];
}

-(void)selectedModel:(PPTapMenumBaseModel *)selectedModel animation:(BOOL)animation needCallbackDelegate:(BOOL)needCallbackDelegate {
    [self selectedModel:selectedModel animation:animation needCallbackDelegate:needCallbackDelegate needSetContentOffset:YES];
}

-(void)selectedModel:(PPTapMenumBaseModel *)selectedModel animation:(BOOL)animation needCallbackDelegate:(BOOL)needCallbackDelegate needSetContentOffset:(BOOL)needSetContentOffset{
    
    PPTapMenumBaseModel * oldSelectedModel = _selectedModel ;
    oldSelectedModel.selected = NO ;
    selectedModel.selected = YES ;
    // 触发 KVO
    [self willChangeValueForKey:@"selectedModel"];
    _selectedModel = selectedModel ;
    [self didChangeValueForKey:@"selectedModel"];
    
    if (needSetContentOffset) {
        // 移动至对应的位置
        CGFloat startOffx = 0 , endOffx = 0 , space = self.collectionView.pagingEnabled ? 0 : 50; // 没有自动分页时才需要偏移 50
        BOOL hasSkipLoopFirstModel = self.loopScrollEnabel == NO ;
        for (PPTapMenumBaseModel * model in self.dataSource) {
            if (model == selectedModel && hasSkipLoopFirstModel) {
                endOffx = startOffx + model.itemSize.width + space;
                break;
            }
            startOffx += (self.interitemSpacing + model.itemSize.width);
            hasSkipLoopFirstModel = YES ;
        }
        
        CGFloat contentInsetLeft = self.collectionView.contentInset.left ;
        CGFloat contentInsetRight = self.collectionView.contentInset.right ;
        CGFloat contentSizeWidth = self.collectionView.contentSize.width ;
        CGFloat minContentOffsetX = - contentInsetLeft ;
        CGFloat maxContentOffsetX = contentSizeWidth + contentInsetRight - self.collectionView.frame.size.width ;
        CGFloat contentOffsetX = self.collectionView.contentOffset.x ;
        CGFloat offx = minContentOffsetX - 1 ;
        
        if (contentOffsetX + self.collectionView.frame.size.width < endOffx) {
            offx = endOffx > contentSizeWidth ? maxContentOffsetX : (endOffx - self.collectionView.frame.size.width) ;
        }else if (contentOffsetX > (startOffx - space)){
            offx = (startOffx - space) > minContentOffsetX ? (startOffx - space) : minContentOffsetX ;
            offx = offx > contentOffsetX ? contentOffsetX : offx ;
        }
        
        if (offx >= minContentOffsetX) {
            [self.collectionView setContentOffset:CGPointMake(offx, 0) animated:animation];
        }
    }
    
    NSMutableArray * models = [NSMutableArray array];
    if(oldSelectedModel)[models addObject:oldSelectedModel];
    if(selectedModel && ![models containsObject:selectedModel])[models addObject:selectedModel];
    
    NSArray<NSIndexPath *> * indexPaths = [self findIndexPathWithModels:models];
    if (indexPaths.count) {
        NSMutableArray * needReloadIndexPaths = [NSMutableArray array];
        
        for (NSIndexPath * indexPath in indexPaths) {
            PPTapMenumBaseCell * cell = (PPTapMenumBaseCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            if (!cell) {
                [needReloadIndexPaths addObject:indexPath];
            }else if(self.dataSource.count > indexPath.row){
                cell.model = [self.dataSource objectAtIndex:indexPath.row];
            }
        }
        
        if (needReloadIndexPaths.count && self.reloadDataEnabel) {
            [self.collectionView reloadItemsAtIndexPaths:needReloadIndexPaths];
        }
    }
    
    if (needCallbackDelegate && selectedModel) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tapMenumContainerView:selectedModel:)]) {
            [self.delegate tapMenumContainerView:self selectedModel:selectedModel];
        }
    }
}

-(NSArray<NSIndexPath *> *)findIndexPathWithModels:(NSArray<PPTapMenumBaseModel *> *)models {
    
    NSUInteger row = 0 , section = 0;
    NSMutableArray<NSIndexPath *> * indexPaths = [NSMutableArray array];
    
    for (PPTapMenumBaseModel * model in self.dataSource) {
        if ([models containsObject:model]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        }
        row++ ;
    }
    return indexPaths.copy ;
}

#pragma mark - UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PPTapMenumBaseModel *model = self.dataSource[indexPath.row];
    PPTapMenumBaseCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:model.reuseIdentifier forIndexPath:indexPath];
    cell.model = model ;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.dataSource.count;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PPTapMenumBaseModel *model = self.dataSource[indexPath.row];
    
    self.selectedModel = model ;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayou sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PPTapMenumBaseModel *model = self.dataSource[indexPath.row];

    return model.itemSize;
}

#pragma mark - Getter/Setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = self.lineSpacing;
        layout.minimumInteritemSpacing = self.interitemSpacing ;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
        _collectionView.pagingEnabled = NO ;
        // 设置了这个属性，系统不会将内容view自动翻转!!!!!
        _collectionView.semanticContentAttribute = UISemanticContentAttributeSpatial ;
    }
    return _collectionView;
}

-(void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing ;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = lineSpacing ;
    
    [self selectedModel:self.selectedModel animation:NO needCallbackDelegate:NO];
}
-(void)setInteritemSpacing:(CGFloat)interitemSpacing {
    _interitemSpacing = interitemSpacing ;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = interitemSpacing ;
    
    [self selectedModel:self.selectedModel animation:NO needCallbackDelegate:NO];
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

-(void)setSelectedModel:(PPTapMenumBaseModel *)selectedModel {
    if (selectedModel && ![self.dataSource containsObject:selectedModel]) {
        return;
    }
    
    [self selectedModel:selectedModel animation:YES];
}

@end
