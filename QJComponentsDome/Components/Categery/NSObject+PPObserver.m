//
//  NSObject+PPObserver.m
//
//  Created by 杰 on 2021/9/14.
//  Copyright © 2021 All rights reserved.
//

#import "NSObject+PPObserver.h"
#import <objc/runtime.h>


@interface PPPrivacyObserver : NSObject
@end


@interface PPObjectObserverModel ()
/// 被观察的对象
@property (nonatomic , weak) id ofObject ;

@property (nonatomic , strong) PPPrivacyObserver * observer ;

/// 观察的属性
@property (nonatomic , copy) NSString * keyPath ;

/// 回调对象 和 方法
@property (nonatomic , weak) id target ;
@property (nonatomic)        SEL action ;

/// 是否指定了 target 被释放时 didChangedValueBlock 监听被移除
@property (nonatomic)        BOOL removeWhenTargetDalloc ;
/// 回调block
@property (nonatomic , strong) void (^didChangedValueBlock)(PPObjectObserverModel * observerModel) ;

@end



@interface NSObject (PPObserverProperty)
@property (nonatomic , strong) NSMutableDictionary<NSString *,NSMutableArray<PPObjectObserverModel *> *> * privacyKeyObserversDictionary ;
@end
@implementation NSObject (PPObserver)

/// 监听回调
-(void)pp_custom_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    [self removeLoseEfficacyModelsWithKeyPath:keyPath];

    NSMutableArray * observers = [self privacyKeyObserverArrayWithKeyPath:keyPath];
    
    [observers enumerateObjectsUsingBlock:^(PPObjectObserverModel * observerModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (object != observerModel.ofObject) {
            return;
        }
        
        observerModel.change = change ;
        
        if (observerModel.didChangedValueBlock) {
            observerModel.didChangedValueBlock(observerModel) ;
            
        }else if ([observerModel.target respondsToSelector:observerModel.action]) {
            
            NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[observerModel.target methodSignatureForSelector:observerModel.action]];
            invocation.target = observerModel.target ;
            invocation.selector = observerModel.action ;
            // 设置方法参数
            if (invocation.methodSignature.numberOfArguments == 3) {
                PPObjectObserverModel * model = observerModel ;
                [invocation setArgument:&model atIndex:2];
            }
            
            [invocation invoke];
        }
    }];
}

#pragma mark - 添加 和 删除 监听功能
-(void)addObserverForKeyPath:(NSString *)keyPath
                    userInfo:(nullable id)userInfo
        didChangedValueBlock:(nonnull void (^)(PPObjectObserverModel * _Nonnull))didChangedValueBlock {
    
    [self addObserverForKeyPath:keyPath userInfo:userInfo didChangedValueBlock:didChangedValueBlock removeObserverWhenTargetDalloc:nil];
}

-(void)addObserverForKeyPath:(NSString *)keyPath
                    userInfo:(nullable id)userInfo
        didChangedValueBlock:(nonnull void (^)(PPObjectObserverModel * _Nonnull))didChangedValueBlock
removeObserverWhenTargetDalloc:(nullable id)target{
    
    if (!keyPath || !didChangedValueBlock) {
        return;
    }
    
    [self removeLoseEfficacyModelsWithKeyPath:keyPath];
        
    NSMutableArray * observers = [self privacyKeyObserverArrayWithKeyPath:keyPath];
    for (PPObjectObserverModel *observerModel  in observers) {
        if (observerModel.didChangedValueBlock == didChangedValueBlock) {
            return;
        }
    }
    
    PPObjectObserverModel * model = [PPObjectObserverModel new];
    model.ofObject = self ;
    model.observer = [PPPrivacyObserver new] ;
    model.keyPath = keyPath ;
    model.userInfo = userInfo ;
    model.didChangedValueBlock = didChangedValueBlock ;
    model.target = target ;
    model.removeWhenTargetDalloc = target != nil ;
    [observers addObject:model];
    
    // 监听
    [self addObserver:model.observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

-(void)addObserverForKeyPath:(NSString *)keyPath
                    userInfo:(nullable id)userInfo
                      target:(nonnull id)target
                      action:(nonnull SEL)action{
    
    if (!keyPath || !target || !action || ![target respondsToSelector:action]) {
        return;
    }
    [self removeLoseEfficacyModelsWithKeyPath:keyPath];
            
    NSMutableArray * observers = [self privacyKeyObserverArrayWithKeyPath:keyPath];
    for (PPObjectObserverModel *observerModel  in observers) {
        if (observerModel.target == target && [NSStringFromSelector(observerModel.action) isEqualToString:NSStringFromSelector(action)]) {
            return;
        }
    }
    
    PPObjectObserverModel * model = [PPObjectObserverModel new] ;
    model.ofObject = self ;
    model.observer = [PPPrivacyObserver new] ;
    model.keyPath = keyPath ;
    model.userInfo = userInfo ;
    model.target = target ;
    model.action = action ;
    [observers addObject:model];
    
    // 监听
    [self addObserver:model.observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

-(void)removeObserverForKeyPath:(NSString *)keyPath {
    if (!keyPath) {
        return;
    }
    NSMutableArray * observers = self.privacyKeyObserversDictionary[keyPath];
    for (PPObjectObserverModel * model in observers) {
        [self removeObserver:model.observer forKeyPath:model.keyPath];
    }
    [observers removeAllObjects];
}

-(void)removeObserverForKeyPath:(NSString *)keyPath target:(id)target {
    if (!keyPath || !target) {
        return;
    }
    [self removeLoseEfficacyModelsWithKeyPath:keyPath];
    
    NSMutableArray * needRemoveObservers = [NSMutableArray array];
    NSMutableArray * observers = [self privacyKeyObserverArrayWithKeyPath:keyPath];

    for (PPObjectObserverModel * model  in observers) {
        if (model.target == target) {
            [needRemoveObservers addObject:model];
            [self removeObserver:model.observer forKeyPath:model.keyPath];
        }
    }
    
    [observers removeObjectsInArray:needRemoveObservers];
}

-(void)removeObserverForKeyPath:(NSString *)keyPath target:(id)target action:(SEL)action {
    if (!keyPath || !action) {
        return;
    }
    
    [self removeLoseEfficacyModelsWithKeyPath:keyPath];
    
    NSMutableArray * observers = [self privacyKeyObserverArrayWithKeyPath:keyPath];
    PPObjectObserverModel * removeModel = nil ;
    
    for (PPObjectObserverModel * model  in observers) {
        if (model.target != target || ![NSStringFromSelector(model.action) isEqualToString:NSStringFromSelector(action)]) {
            continue;
        }
        
        removeModel = model ;
        break;
    }
    
    if (removeModel) {
        [self removeObserver:removeModel.observer forKeyPath:removeModel.keyPath];
        [observers removeObject:removeModel];
    }
}

-(void)removeLoseEfficacyModelsWithKeyPath:(NSString *)keyPath {
    if (!keyPath) {
        return;
    }
    
    NSMutableArray * needRemoveObservers = [NSMutableArray array];
    NSMutableArray * observers = [self privacyKeyObserverArrayWithKeyPath:keyPath];

    for (PPObjectObserverModel * model  in observers) {
        if (!model.didChangedValueBlock && (!model.target || !model.action || ![model.target respondsToSelector:model.action])){
            [needRemoveObservers addObject:model];
            [self removeObserver:model.observer forKeyPath:model.keyPath];

        }else if (model.removeWhenTargetDalloc && !model.target){
            [needRemoveObservers addObject:model];
            [self removeObserver:model.observer forKeyPath:model.keyPath];
        }
    }
    
    [observers removeObjectsInArray:needRemoveObservers];
}

#pragma getter & setter
-(void)setPrivacyKeyObserversDictionary:(NSMutableDictionary<NSString *,NSMutableArray<PPObjectObserverModel *> *> *)privacyKeyObserversDictionary {
    objc_setAssociatedObject(self, @selector(privacyKeyObserversDictionary), privacyKeyObserversDictionary, OBJC_ASSOCIATION_RETAIN);
}
-(NSMutableDictionary<NSString *,NSMutableArray<PPObjectObserverModel *> *> *)privacyKeyObserversDictionary {
    NSMutableDictionary * dic = objc_getAssociatedObject(self, @selector(privacyKeyObserversDictionary));
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
        self.privacyKeyObserversDictionary = dic ;
    }
    return dic;
}

-(NSMutableArray *)privacyKeyObserverArrayWithKeyPath:(NSString *)keyPath {
    if (!keyPath) {
        return [NSMutableArray array];
    }
    
    NSMutableDictionary * privacyKeyObserversDictionary = self.privacyKeyObserversDictionary;
    NSMutableArray * observers = privacyKeyObserversDictionary[keyPath];
    if (!observers) {
        observers = [NSMutableArray array];
        [privacyKeyObserversDictionary setObject:observers forKey:keyPath];
        self.privacyKeyObserversDictionary = privacyKeyObserversDictionary ;
    }
    
    return observers;
}

@end



@implementation PPPrivacyObserver
/// 监听系统回调
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [object pp_custom_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
@end


@implementation PPObjectObserverModel
-(id)object {
    return self.ofObject;
}
@end
