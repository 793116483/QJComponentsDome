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

@interface  PPTapMenumContainerView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) CGFloat interitemSpacing;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation PPTapMenumContainerView

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
    [self.dataSource removeAllObjects];
    
    if ([datas isKindOfClass:[NSArray class]]) {
        // 一个神奇的问题，带图片的View,在阿语情况下能自动翻转，不带图片的不行， 所以将数据翻转
//        if ([PPSystemConfigUtils isRightToLeftShow]) {
//            [datas enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PPTapMenumBaseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [self.dataSource addObject:obj];
//            }];
//        } else {
            [self.dataSource addObjectsFromArray:datas];
//        }
    }
        
    [self.dataSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PPTapMenumBaseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.collectionView registerClass:obj.cellClass forCellWithReuseIdentifier:obj.reuseIdentifier];
    }];
    
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(-self.collectionView.contentInset.left, 0) animated:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if ([PPSystemConfigUtils isRightToLeftShow]) {
//            CGFloat contentOffset = self.collectionView.contentSize.width - self.collectionView.width + self.collectionView.contentInset.right;
//            [self.collectionView setContentOffset:CGPointMake(contentOffset, 0) animated:NO];
//        }
        
        // 设置当前选中,并刷新
        [self selectedModel:selectedModel animation:NO needCallbackDelegate:NO];
    });
    
}

#pragma mark - 选中某个 cell 做动画
-(void)selectedModel:(PPTapMenumBaseModel *)selectedModel animation:(BOOL)animation {
    [self selectedModel:selectedModel animation:animation needCallbackDelegate:YES];
}

-(void)selectedModel:(PPTapMenumBaseModel *)selectedModel animation:(BOOL)animation needCallbackDelegate:(BOOL)needCallbackDelegate{
    
    PPTapMenumBaseModel * oldSelectedModel = _selectedModel ;
    _selectedModel.selected = NO ;
    _selectedModel = selectedModel ;
    _selectedModel.selected = YES ;
    
    // 移动至对应的位置
    CGFloat startOffx = 0 , endOffx = 0 , space = 50;
    for (PPTapMenumBaseModel * model in self.dataSource) {
        if (model == selectedModel) {
            endOffx = startOffx + model.itemSize.width + space;
            break;
        }
        startOffx += (self.interitemSpacing + model.itemSize.width);
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
    
    NSMutableArray * models = [NSMutableArray array];
    if(oldSelectedModel)[models addObject:oldSelectedModel];
    if(selectedModel)[models addObject:selectedModel];
    
    NSArray<NSIndexPath *> * indexPaths = [self findIndexPathWithModels:models];
    if (indexPaths.count) {
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }
    
    if (needCallbackDelegate && _selectedModel) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tapMenumContainerView:selectedModel:)]) {
            [self.delegate tapMenumContainerView:self selectedModel:_selectedModel];
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
    
//    [self.exposeObject recordClickWithIndex:indexPath.row];
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
