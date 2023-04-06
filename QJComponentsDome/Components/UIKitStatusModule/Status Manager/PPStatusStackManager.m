//
//  PPStatusStackManager.m
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import "PPStatusStackManager.h"
#import "UIViewController+PPStatusCategory.h"

@implementation PPStatusStackManager

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    static PPStatusStackManager * manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(void)resetCurrentStatusSetModel {
    _currentStatusSetModel = self.pp_currentTopNavigationController.currentStatusSetModel;
}

@end
