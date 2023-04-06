//
//  CALayer+PPStatusCategory.m
//  PatPat
//
//  Created by 杰 on 2023/3/16.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "CALayer+PPStatusCategory.h"
#import "PPStatusPropertyMessageModel.h"
#import "PPStatusPropertyMessageStorageObject.h"

@implementation CALayer (PPStatusCategory)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method addSublayerM = class_getInstanceMethod(self, @selector(addSublayer:));
        Method addSublayerM_pp = class_getInstanceMethod(self, @selector(__pp_status_category_addSublayer:));
        method_exchangeImplementations(addSublayerM, addSublayerM_pp);
    });
}

-(BOOL)setCALayerStatusMessage:(PPStatusPropertyMessageModel *)message record:(BOOL)record{
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
    
    UIColor * propertyValue = message.propertyValue;
    
    switch (message.propertyType) {
        case PPStatusCALayerPropertyTypeBackgroundColor:{
            self.backgroundColor = propertyValue.CGColor;
            break;
        }
        case PPStatusCALayerPropertyTypeBorderColor:{
            self.borderColor = propertyValue.CGColor;
            break;
        }
            
        default:
            break;
    }
    
    return YES;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusCALayerPropertyTypeBackgroundColor propertyValue:backgroundColor skinStatusStyle:skinStatusStyle];
    [self setCALayerStatusMessage:message record:YES];
}

-(void)setBorderColor:(UIColor *)borderColor forSkinStyle:(PPSkinStatusStyle)skinStatusStyle {
    PPStatusPropertyMessageModel * message = [PPStatusPropertyMessageModel messageWithPropertyType:PPStatusCALayerPropertyTypeBorderColor propertyValue:borderColor skinStatusStyle:skinStatusStyle];
    [self setCALayerStatusMessage:message record:YES];
}

-(void)resetLayerAndSubLayerSkin {
    
    if(![self isSystemViewLayer]){
        [self setNeedsDisplay];
    }

    // 肤色
    NSArray<PPStatusPropertyMessageModel *> * messageArray = [self.messageStorageObject getPropertyMessageArrayWithSkinStatusStyle:self.skinStatusStyle];
    for (PPStatusPropertyMessageModel * message in messageArray) {
        [self setCALayerStatusMessage:message record:NO];
    }
    
    // sublayers
    for (CALayer * subLayer in self.sublayers) {
        [subLayer resetLayerAndSubLayerSkin];
    }
}


-(PPSkinStatusStyle)skinStatusStyle {
    PPSkinStatusStyle skinStatusStyle = [objc_getAssociatedObject(self, @selector(skinStatusStyle)) integerValue];
    if(skinStatusStyle == PPSkinStatusStyleUnSpecified){
        skinStatusStyle = [PPStatusStackManager shareManager].currentStatusSetModel.skinStatusStyle;
    }
    return skinStatusStyle;
}
-(void)setSkinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    
    PPSkinStatusStyle oldSkinStyle = self.skinStatusStyle;
    
    objc_setAssociatedObject(self, @selector(skinStatusStyle), @(skinStatusStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    PPSkinStatusStyle newSkinStatusStyle = skinStatusStyle;

    // 标记设置了 skinStatusStyle
    self.isUserSetSkinStatusStyle = YES;
    
    // 影响已经加入的子控件
    for (CALayer * subLayer in self.sublayers) {
        if(!subLayer.isUserSetSkinStatusStyle && subLayer.skinStatusStyle != newSkinStatusStyle){
            subLayer.skinStatusStyle = newSkinStatusStyle;
            subLayer.isUserSetSkinStatusStyle = NO;
        }
    }
    
    if(oldSkinStyle == newSkinStatusStyle) return;

    // 肤色
    NSArray<PPStatusPropertyMessageModel *> * messageArray = [self.messageStorageObject getPropertyMessageArrayWithSkinStatusStyle:newSkinStatusStyle];
    for (PPStatusPropertyMessageModel * message in messageArray) {
        [self setCALayerStatusMessage:message record:NO];
    }
}

-(void)__pp_status_category_addSublayer:(CALayer *)subLayer {
    [self __pp_status_category_addSublayer:subLayer];
    
    if(!subLayer.isUserSetSkinStatusStyle && subLayer.skinStatusStyle != self.skinStatusStyle){
        subLayer.skinStatusStyle = self.skinStatusStyle;
        subLayer.isUserSetSkinStatusStyle = NO;
    }
}


-(BOOL)isUserSetSkinStatusStyle {
    return [objc_getAssociatedObject(self, @selector(isUserSetSkinStatusStyle)) boolValue];
}
-(void)setIsUserSetSkinStatusStyle:(BOOL)isUserSetSkinStatusStyle {
    objc_setAssociatedObject(self, @selector(isUserSetSkinStatusStyle), @(isUserSetSkinStatusStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(PPStatusPropertyMessageStorageObject *)messageStorageObject {
    return objc_getAssociatedObject(self, @selector(messageStorageObject));
}
-(void)setMessageStorageObject:(PPStatusPropertyMessageStorageObject *)messageStorageObject {
    objc_setAssociatedObject(self, @selector(messageStorageObject), messageStorageObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSystemViewLayer
{
    return [NSStringFromClass(self.delegate.class) hasPrefix:@"UI"] || [NSStringFromClass(self.delegate.class) hasPrefix:@"_UI"];
}

@end
