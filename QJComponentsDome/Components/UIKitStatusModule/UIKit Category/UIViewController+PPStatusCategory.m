//
//  UIViewController+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "UIViewController+PPStatusCategory.h"
#import "UIView+PPStatusCategory.h"
#import "PPStatusSetModel.h"

@implementation UIViewController (PPStatusCategory)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method viewDidLoadM = class_getInstanceMethod(self, @selector(viewDidLoad));
        Method viewDidLoadM_pp = class_getInstanceMethod(self, @selector(__pp_status_category_viewDidLoad));
        method_exchangeImplementations(viewDidLoadM, viewDidLoadM_pp);
        
        Method preferredStatusBarStyleM = class_getInstanceMethod(self, @selector(preferredStatusBarStyle));
        Method preferredStatusBarStyleM_pp = class_getInstanceMethod(self, @selector(__pp_status_category_preferredStatusBarStyle));
        method_exchangeImplementations(preferredStatusBarStyleM, preferredStatusBarStyleM_pp);
    });
}
-(void)__pp_status_category_viewDidLoad {
    [self __pp_status_category_viewDidLoad];
    
    PPStatusSetModel * currentStatusSetModel = self.currentStatusSetModel;
    if(currentStatusSetModel){
        // 设置默认值
        self.view.skinStatusStyle = currentStatusSetModel.skinStatusStyle;
    }
}

-(UIStatusBarStyle)__pp_status_category_preferredStatusBarStyle {
    
    [[PPStatusStackManager shareManager] resetCurrentStatusSetModel];
    
    // 系统导航栏肤色
    [self.navigationController.navigationBar resetViewAndSubViewSkin];
    
    // 系统底部导航栏肤色
//    if(!self.hidesBottomBarWhenPushed){
//        [self.tabBarController.tabBar resetViewAndSubViewSkin];
//    }
    
    PPStatusSetModel * currentStatusSetModel = self.currentStatusSetModel;
    if(currentStatusSetModel){
        // 系统状态栏肤色
        return currentStatusSetModel.statusBarStyle;
    }else {
        return [self __pp_status_category_preferredStatusBarStyle];
    }
}


-(PPStatusSetModel *)currentStatusSetModel {
    PPStatusSetModel * currentStatusSetModel = objc_getAssociatedObject(self, @selector(currentStatusSetModel));
    if(!currentStatusSetModel) {
        currentStatusSetModel = [PPStatusStackManager shareManager].currentStatusSetModel;
    }
    return currentStatusSetModel;
}
-(void)setCurrentStatusSetModel:(PPStatusSetModel *)currentStatusSetModel {
    PPStatusSetModel * oldStatusSetModel = objc_getAssociatedObject(self, @selector(currentStatusSetModel));

    objc_setAssociatedObject(self, @selector(currentStatusSetModel), currentStatusSetModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[PPStatusStackManager shareManager] resetCurrentStatusSetModel];

    if((currentStatusSetModel || oldStatusSetModel) && self.isViewLoaded){
        [self setNeedsStatusBarAppearanceUpdate];
        // 更新设置的默认值
        if(self.view.storageSkinStatusStyle != currentStatusSetModel.skinStatusStyle){
            self.view.skinStatusStyle = currentStatusSetModel.skinStatusStyle;
        }
        [self.view resetViewAndSubViewSkin];
    }
}

@end
