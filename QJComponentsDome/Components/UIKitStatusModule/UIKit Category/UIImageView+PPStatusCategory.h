//
//  UIImageView+PPStatusCategory.h
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (PPStatusCategory)

-(void)setImage:(UIImage *)image forSkinStyle:(PPSkinStatusStyle)skinStatusStyle;

@end

NS_ASSUME_NONNULL_END
