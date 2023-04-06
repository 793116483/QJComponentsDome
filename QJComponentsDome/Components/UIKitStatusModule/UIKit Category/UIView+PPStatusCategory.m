//
//  UIView+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "UIView+PPStatusCategory.h"
#import "UIViewController+PPStatusCategory.h"
#import "PPStatusSetModel.h"
#import "PPStatusPropertyMessageModel.h"
#import "PPStatusPropertyMessageStorageObject.h"


@implementation UIView (PPStatusCategory)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method addSubviewM = class_getInstanceMethod(self, @selector(addSubview:));
        Method addSubviewM_pp = class_getInstanceMethod(self, @selector(__pp_status_category_addSubview:));
        method_exchangeImplementations(addSubviewM, addSubviewM_pp);
    });
}

-(BOOL)setUIViewStatusMessage:(PPStatusPropertyMessageModel *)message record:(BOOL)record{
    if(!message) return NO;
    
    if(record){
        PPStatusPropertyMessageStorageObject * messageStorageObject = self.messageStorageObject;
        if(!messageStorageObject){
            messageStorageObject = [PPStatusPropertyMessageStorageObject new];
            self.messageStorageObject = messageStorageObject;
        }
        [messageStorageObject storagePropertyMessage:message];
    }
    if(self.skinStatusStyle != message.skinStatusStyle){
        return NO;
    }
        
    switch (message.propertyType) {
        case PPStatusUIViewPropertyTypeBackgroundColor:{
            self.backgroundColor = message.propertyValue;
            break;
        }
        default:
            break;
    }
    
    return YES;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusUIViewPropertyTypeBackgroundColor propertyValue:backgroundColor skinStatusStyle:skinStatusStyle];
    [self setUIViewStatusMessage:message record:YES];
}

-(void)resetViewAndSubViewSkin {
    
    // 需要优化
    if(![self isSystemView]){
        [self setNeedsDisplay];
    }

    // 肤色
    NSArray<PPStatusPropertyMessageModel *> * messageArray = [self.messageStorageObject getPropertyMessageArrayWithSkinStatusStyle:self.skinStatusStyle];
    for (PPStatusPropertyMessageModel * message in messageArray) {
        [self setUIViewStatusMessage:message record:NO];
    }
    
    [self.layer resetLayerAndSubLayerSkin];

    // subview 肤色
    BOOL isCustomNavigationBar = self.isCustomNavigationBar;
    for (UIView * subView in self.subviews) {
        if(isCustomNavigationBar && subView.isCustomNavigationBar != isCustomNavigationBar){
            subView.isCustomNavigationBar = isCustomNavigationBar;
        }
        [subView resetViewAndSubViewSkin];
    }
}


-(PPSkinStatusStyle)skinStatusStyle {
    
    if(self.isCustomNavigationBar){
        // 自定义的导航栏，则直接取导航栏皮肤样式
        return [PPStatusStackManager shareManager].currentStatusSetModel.navigationBarStyle == UIBarStyleBlack ? PPSkinStatusStyleDark : PPSkinStatusStyleLight;
    }
    
    PPSkinStatusStyle skinStatusStyle = [objc_getAssociatedObject(self, @selector(skinStatusStyle)) integerValue];
    if(skinStatusStyle == PPSkinStatusStyleUnSpecified){
        skinStatusStyle = [PPStatusStackManager shareManager].currentStatusSetModel.skinStatusStyle;
    }
    return skinStatusStyle;
}
-(void)setSkinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
        
    PPSkinStatusStyle oldSkinStyle = self.skinStatusStyle;
    
    // 如果是自定义的导航栏，设置无效
    objc_setAssociatedObject(self, @selector(skinStatusStyle), @(skinStatusStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    PPSkinStatusStyle newSkinStatusStyle = self.skinStatusStyle;
    
    // 标记设置了 skinStatusStyle
    self.isUserSetSkinStatusStyle = YES;
    
    if(!self.layer.isUserSetSkinStatusStyle && self.layer.skinStatusStyle != newSkinStatusStyle){
        self.layer.skinStatusStyle = newSkinStatusStyle;
        self.layer.isUserSetSkinStatusStyle = NO;
    }
    
    // 影响已经加入的子控件
    for (UIView * subView in self.subviews) {
        if(!subView.isUserSetSkinStatusStyle && subView.skinStatusStyle != newSkinStatusStyle){
            subView.skinStatusStyle = newSkinStatusStyle;
            subView.isUserSetSkinStatusStyle = NO;
        }
    }
    
    if(oldSkinStyle == newSkinStatusStyle) return;

    // 肤色
    NSArray<PPStatusPropertyMessageModel *> * messageArray = [self.messageStorageObject getPropertyMessageArrayWithSkinStatusStyle:newSkinStatusStyle];
    for (PPStatusPropertyMessageModel * message in messageArray) {
        [self setUIViewStatusMessage:message record:NO];
    }
}

-(void)__pp_status_category_addSubview:(UIView *)subView {
    [self __pp_status_category_addSubview:subView];
    
    BOOL isCustomNavigationBar = self.isCustomNavigationBar;
    if(isCustomNavigationBar && subView.isCustomNavigationBar != isCustomNavigationBar){
        subView.isCustomNavigationBar = isCustomNavigationBar;
    }
    
    if(!subView.isUserSetSkinStatusStyle && subView.skinStatusStyle != self.skinStatusStyle){
        subView.skinStatusStyle = self.skinStatusStyle;
        subView.isUserSetSkinStatusStyle = NO;
    }
}

-(BOOL)isUserSetSkinStatusStyle {
    return [objc_getAssociatedObject(self, @selector(isUserSetSkinStatusStyle)) boolValue];
}
-(void)setIsUserSetSkinStatusStyle:(BOOL)isUserSetSkinStatusStyle {
    objc_setAssociatedObject(self, @selector(isUserSetSkinStatusStyle), @(isUserSetSkinStatusStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isCustomNavigationBar {
    return [objc_getAssociatedObject(self, @selector(isCustomNavigationBar)) boolValue];
}
-(void)setIsCustomNavigationBar:(BOOL)isCustomNavigationBar {
    
    PPSkinStatusStyle oldSkinStyle = self.skinStatusStyle;

    objc_setAssociatedObject(self, @selector(isCustomNavigationBar), @(isCustomNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 影响已经加入的子控件
    for (UIView * subView in self.subviews) {
        if(subView.isCustomNavigationBar != isCustomNavigationBar){
            subView.isCustomNavigationBar = isCustomNavigationBar;
        }
    }
    
    if(oldSkinStyle != self.skinStatusStyle){
        // 肤色
        NSArray<PPStatusPropertyMessageModel *> * messageArray = [self.messageStorageObject getPropertyMessageArrayWithSkinStatusStyle:self.skinStatusStyle];
        for (PPStatusPropertyMessageModel * message in messageArray) {
            [self setUIViewStatusMessage:message record:NO];
        }
    }
}

-(PPStatusPropertyMessageStorageObject *)messageStorageObject {
    return objc_getAssociatedObject(self, @selector(messageStorageObject));
}
-(void)setMessageStorageObject:(PPStatusPropertyMessageStorageObject *)messageStorageObject {
    objc_setAssociatedObject(self, @selector(messageStorageObject), messageStorageObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSystemView
{
    return [NSStringFromClass(self.class) hasPrefix:@"UI"] || [NSStringFromClass(self.class) hasPrefix:@"_UI"];
}

@end
