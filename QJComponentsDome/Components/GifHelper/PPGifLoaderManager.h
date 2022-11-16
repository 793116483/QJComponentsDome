//
//  PPGifLoaderManager.h
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPGifLoaderManager : NSObject

+(instancetype)shareManager;

-(BOOL)loadingGifWithURL:(NSURL *)URL imageView:(UIImageView *)imageView placeholderImage:(UIImage*)placeholderImage;

@end

NS_ASSUME_NONNULL_END
