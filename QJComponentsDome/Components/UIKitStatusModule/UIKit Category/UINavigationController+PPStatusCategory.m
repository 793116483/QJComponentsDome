//
//  UINavigationController+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "UINavigationController+PPStatusCategory.h"
#import "UIViewController+PPStatusCategory.h"
#import "PPStatusStackManager.h"

@implementation UINavigationController (PPStatusCategory)

-(PPStatusSetModel *)currentStatusSetModel {
    for (NSInteger i = self.viewControllers.count - 1; i >= 0 ; i--) {
        UIViewController * vc = self.viewControllers[i];
        // 直接拿是为了防止出现循环调用
        PPStatusSetModel * currentStatusSetModel = objc_getAssociatedObject(vc, @selector(currentStatusSetModel));
        if(currentStatusSetModel){
            if(currentStatusSetModel.isOnlyCurrentPageEffective &&
               i == self.viewControllers.count - 1) {
                return currentStatusSetModel;
            }else if (!currentStatusSetModel.isOnlyCurrentPageEffective){
                return currentStatusSetModel;
            }
        }
    }
    return nil;
}

-(void)setCurrentStatusSetModel:(PPStatusSetModel *)currentStatusSetModel {
    // 设置给顶部控制器
    self.visibleViewController.currentStatusSetModel = currentStatusSetModel;
}

@end
