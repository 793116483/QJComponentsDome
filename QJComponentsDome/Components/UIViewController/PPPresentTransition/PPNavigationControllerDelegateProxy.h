//
//  PPNavigationControllerDelegateProxy.h
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPNavigationControllerDelegateProxy : NSProxy <UINavigationControllerDelegate>

- (instancetype)initWithTarget:(id)target navigationController:(UINavigationController *)navigationController;

@end

NS_ASSUME_NONNULL_END
