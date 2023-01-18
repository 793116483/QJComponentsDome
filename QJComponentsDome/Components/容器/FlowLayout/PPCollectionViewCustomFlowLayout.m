//
//  PPCollectionViewCustomFlowLayout.m
//  PatPat
//
//  Created by 杰 on 2023/1/10.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "PPCollectionViewCustomFlowLayout.h"

@interface PPFlowLayoutColumnItem : NSObject
@property (nonatomic , assign) NSUInteger column;

@property (nonatomic , assign) CGRect frame;
@end
@implementation PPFlowLayoutColumnItem
@end


@interface PPCollectionViewCustomFlowLayout ()

@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, strong) NSArray<NSArray<UICollectionViewLayoutAttributes *> *> * attributesArray;
@property (nonatomic , strong)NSMutableDictionary<NSString *,PPFlowLayoutColumnItem*> * columnItemDic;

@end


@implementation PPCollectionViewCustomFlowLayout

-(void)prepareLayout {
    [super prepareLayout];
    
    self.contentHeight = 0;
    NSMutableArray *layoutInfoArr = [NSMutableArray array];
    //获取布局信息
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *subArr = [NSMutableArray arrayWithCapacity:numberOfItems];
        
        UIEdgeInsets sectionInset = self.sectionInset;
        if([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]){
            sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }
        
        NSIndexPath * sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        // 头
        if([self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
            if(self.registerElementKindSectionHeader){
                UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:sectionIndexPath];
                if(headerAttributes){
                    [subArr addObject:headerAttributes];
                    self.contentHeight = MAX(self.contentHeight, CGRectGetMaxY(headerAttributes.frame));
                }
            }
        }
        
        for (NSInteger item = 0; item < numberOfItems; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [subArr addObject:attributes];
            
            if(attributes){
                self.contentHeight = MAX(self.contentHeight, CGRectGetMaxY(attributes.frame) + sectionInset.bottom);
            }
        }
        // 尾
        if([self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
            if(self.registerElementKindSectionFooter){
                UICollectionViewLayoutAttributes *footerAttributes = [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionFooter atIndexPath:sectionIndexPath];
                if(footerAttributes){
                    [subArr addObject:footerAttributes];
                    self.contentHeight = MAX(self.contentHeight, CGRectGetMaxY(footerAttributes.frame) + sectionInset.bottom);
                }
            }
        }
        
        [layoutInfoArr addObject:[subArr copy]];
    }
    
    self.attributesArray = [layoutInfoArr copy];
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributesArr = [NSMutableArray array];
    
    [self.attributesArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull array, NSUInteger idx, BOOL * _Nonnull stop) {
        [array enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CGRectIntersectsRect(obj.frame, rect)) { //如果item在rect内
                [layoutAttributesArr addObject:obj];
            }
        }];
    }];
    return layoutAttributesArr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *currentAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    UIEdgeInsets sectionInset = self.sectionInset;
    if([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]){
        sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:indexPath.section];
    }
    
    NSUInteger columnCount = self.columnCount;
    if([self.delegate respondsToSelector:@selector(collectionView:layout:columnCountInSection:)]){
        columnCount = [self.delegate collectionView:self.collectionView layout:self columnCountInSection:indexPath.section];
    }
    
//    CGFloat layoutWidth = CGRectGetWidth(self.collectionView.frame) - sectionInset.right;
//    CGFloat layoutHeight = CGRectGetHeight(self.collectionView.frame) - sectionInset.top - sectionInset.bottom;

//    CGSize cellSize = currentAttributes.frame.size;
    
    // cell 左右之间的间隔
    CGFloat minimumInteritemSpacing = self.minimumInteritemSpacing;
    if([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]){
        minimumInteritemSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:indexPath.section];
    }
    
    // cell 上下之间的间隔
    CGFloat minimumLineSpacing = self.minimumLineSpacing;
    if([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]){
        minimumLineSpacing = [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:indexPath.section];
    }
    
    // 最小y值的一列，用来放当前 cell
    NSUInteger minYColumn = 0;
    PPFlowLayoutColumnItem * minYColumnItem = nil;
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
    
    for (NSUInteger column = 0; column < columnCount; column++) {
        NSString * previousKey = [NSString stringWithFormat:@"%ldx%ldx%ld",previousIndexPath.section,previousIndexPath.item,column];
        PPFlowLayoutColumnItem * columnItem = self.columnItemDic[previousKey];
        
        if(!minYColumnItem || CGRectGetMaxY(minYColumnItem.frame) > CGRectGetMaxY(columnItem.frame)){
            minYColumnItem = columnItem;
            minYColumn = column;
            
            if(CGRectGetMaxY(columnItem.frame) == 0){
                // y为最小的最前一列
                break;
            }
        }
    }
    
    // 当前 indexPath 的 所有列记录的值 基于前一个indexPath对应列值，dp思想
    for (NSUInteger column = 0; column < columnCount; column++) {
        NSString * previousKey = [NSString stringWithFormat:@"%ldx%ldx%ld",previousIndexPath.section,previousIndexPath.item,column];
        NSString * key = [NSString stringWithFormat:@"%ldx%ldx%ld",indexPath.section,indexPath.item,column];
        if(self.columnItemDic[previousKey]){
            self.columnItemDic[key] = self.columnItemDic[previousKey];
        }
    }

    if(!minYColumnItem){
        // 说明是每列的头个
        UICollectionViewLayoutAttributes * headerAttributes = nil;
        if(self.registerElementKindSectionHeader){
            headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        }
        
        CGRect frame = currentAttributes.frame;
        frame.origin.y = CGRectGetMaxY(headerAttributes.frame) + sectionInset.top;

        if(minYColumn > 0){
            //
            NSString * preKey = [NSString stringWithFormat:@"%ldx%ldx%ld",previousIndexPath.section,previousIndexPath.item,minYColumn-1];
            PPFlowLayoutColumnItem * preColumnItem = self.columnItemDic[preKey];
            frame.origin.x = CGRectGetMaxX(preColumnItem.frame) + minimumInteritemSpacing;
        }else{
            frame.origin.x = sectionInset.left;
        }
        
        currentAttributes.frame = frame;
        
    }else {
        CGRect frame = currentAttributes.frame;
        frame.origin.x = minYColumnItem.frame.origin.x;
        frame.origin.y = CGRectGetMaxY(minYColumnItem.frame) + minimumLineSpacing;
        currentAttributes.frame = frame;
    }
    
    PPFlowLayoutColumnItem * columnItem = [PPFlowLayoutColumnItem new];
    columnItem.column = minYColumn;
    columnItem.frame = currentAttributes.frame;
    
    // 阿语反转
    if([PPSystemConfigUtils isCanRightToLeftShow]){
        CGRect frame = currentAttributes.frame;
        frame.origin.x = self.collectionView.frame.size.width - frame.origin.x - frame.size.width;
        currentAttributes.frame = frame;
    }
    
    // 当前cell所放在的列记录更新
    NSString * key = [NSString stringWithFormat:@"%ldx%ldx%ld",indexPath.section,indexPath.item,columnItem.column];
    self.columnItemDic[key] = columnItem;

    return currentAttributes;
}

#pragma mark - getter
-(NSMutableDictionary<NSString *,PPFlowLayoutColumnItem *> *)columnItemDic {
    if(!_columnItemDic){
        _columnItemDic = [NSMutableDictionary dictionary];
    }
    return _columnItemDic;
}

-(CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.width, self.contentHeight);
}
@end
