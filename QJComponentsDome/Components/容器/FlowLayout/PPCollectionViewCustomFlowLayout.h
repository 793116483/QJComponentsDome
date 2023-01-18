//
//  PPCollectionViewCustomFlowLayout.h
//  PatPat
//
//  Created by 杰 on 2023/1/10.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PPCollectionViewCustomFlowLayout;
@protocol PPCollectionViewCustomFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@optional
-(NSUInteger)collectionView:(UICollectionView *)collectionView layout:(PPCollectionViewCustomFlowLayout *)layout columnCountInSection:(NSInteger)section;

@end

@interface PPCollectionViewCustomFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<PPCollectionViewCustomFlowLayoutDelegate> delegate;

@property (nonatomic, assign) NSUInteger columnCount;
@property (nonatomic, assign) BOOL registerElementKindSectionHeader;
@property (nonatomic, assign) BOOL registerElementKindSectionFooter;

@end

NS_ASSUME_NONNULL_END
