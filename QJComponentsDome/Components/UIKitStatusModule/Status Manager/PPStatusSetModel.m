//
//  PPStatusSetModel.m
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "PPStatusSetModel.h"
#import "NSObject+PPStatusCategory.h"

@interface PPStatusSetModel ()

@property (nonatomic , strong) NSMutableDictionary<NSString *,PPStatusSetModelObserver *> * observerDic;

@end

@implementation PPStatusSetModel
//@synthesize language = _language;

-(void)setSkinStatusStyle:(PPSkinStatusStyle)skinStatusStyle {
    if(_skinStatusStyle != skinStatusStyle){
        _skinStatusStyle = skinStatusStyle;
        
        [self notifactionObserversWithForPropertyType:PPStatusSetModelPropertyTypeSkin];
    }
}

//-(void)setLanguage:(NSString *)language {
//    if(![_language isEqualToString:FormatString(language, @"")]) {
//        _language = FormatString(language, @"");
//
//        [self notifactionObserversWithForPropertyType:PPStatusSetModelPropertyTypeLanguage];
//    }
//}

-(void)notifactionObserversWithForPropertyType:(PPStatusSetModelPropertyType)propertyType {
    for (PPStatusSetModelObserver * observerModel in self.observerDic.allValues) {
        if(observerModel.observer && (observerModel.propertyType & propertyType)) {
            [observerModel.observer observeStatusChangeForPropertyType:propertyType ofStatusSetModel:self];
        }
    }
}

-(void)addObserver:(NSObject *)observer forPropertyType:(PPStatusSetModelPropertyType)propertyType{
    PPStatusSetModelObserver * observerModel = [PPStatusSetModelObserver observerWithObjcte:observer propertyType:propertyType];
    if(!observerModel){
        return;
    }
    
    self.observerDic[observerModel.key] = observerModel;
}

-(void)removeObserver:(NSObject *)observer forPropertyType:(PPStatusSetModelPropertyType)propertyType {
    NSString * key = [PPStatusSetModelObserver keyWithObjcte:observer propertyType:propertyType];
    if(key.isEmpty){
        return;
    }
    
    PPStatusSetModelObserver * observerModel = self.observerDic[key];
    if(!observerModel){
        return;
    }
    observerModel.propertyType ^= propertyType;
    if(observerModel.propertyType == 0) {
        [self.observerDic removeObjectForKey:key];
    }
}

-(instancetype)copyNewStatusSetModel {
    PPStatusSetModel * model = [PPStatusSetModel new];
    model.isLunaStyle = self.isLunaStyle;
    model.skinStatusStyle = self.skinStatusStyle;
    model.statusBarStyle = self.statusBarStyle;
    model.navigationBarStyle = self.navigationBarStyle;
//    model.language = self.language.copy;
//    model.currencyModel = [self.currencyModel copyNewStatusCurrencyModel];
    model.isOnlyCurrentPageEffective = self.isOnlyCurrentPageEffective;
    
    return model;
}

-(NSMutableDictionary<NSString *,PPStatusSetModelObserver *> *)observerDic {
    if(!_observerDic) {
        _observerDic = [NSMutableDictionary dictionary];
    }
    return _observerDic;
}

@end



@implementation PPStatusCurrencyModel

- (instancetype)init {
    if(self = [super init]){
        self.currencyISO = @"USD";
        self.currencySign = @"$";
        self.exchangeRate = @"1";
        self.currencyPlace = @"0";
        self.countryLangue = @"en";
        self.countryCode = @"US";
        self.countryCurrency = @"United States Dollar";
        self.currencyAccuracy = @"2";
        self.isSysDefault = YES;
    }
    return self;
}

-(instancetype)copyNewStatusCurrencyModel {
    PPStatusCurrencyModel * model = [PPStatusCurrencyModel new];
    
    model.currencyISO = self.currencyISO;
    model.currencySign = self.currencySign;
    model.exchangeRate = self.exchangeRate;
    model.currencyPlace = self.currencyPlace;
    model.countryLangue = self.countryLangue;
    model.countryCode = self.countryCode;
    model.countryCurrency = self.countryCurrency;
    model.currencyAccuracy = self.currencyAccuracy;
    model.isSysDefault = self.isSysDefault;
    
    return model;
}

@end



@implementation PPStatusSetModelObserver

+(instancetype)observerWithObjcte:(NSObject *)observer propertyType:(PPStatusSetModelPropertyType)propertyType {
    if(propertyType == 0 || !observer) {
        return nil;
    }
    
    PPStatusSetModelObserver * model = [[self alloc] init];
    model.observer = observer;
    model.propertyType = propertyType;
    model.key = [self keyWithObjcte:observer propertyType:propertyType];
    
    return model;
}

+(NSString *)keyWithObjcte:(NSObject *)observer propertyType:(PPStatusSetModelPropertyType)propertyType {
    if(!observer) return @"";
    
    return [NSString stringWithFormat:@"%p",observer];
}

@end
