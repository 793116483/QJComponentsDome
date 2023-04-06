//
//  PPStatusStackManager.h
//  PatPat
//
//  Created by 杰 on 2023/3/15.
//  Copyright © 2023 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PPStatusSetModel;

@interface PPStatusStackManager : NSObject

@property (nonatomic, readonly, nullable) PPStatusSetModel * currentStatusSetModel;

+(instancetype)shareManager;

-(void)resetCurrentStatusSetModel;

//-(void)push:(PPStatusSetModel *)model;
//-(nullable PPStatusSetModel *)pop;
//-(nullable PPStatusSetModel *)getTopStatusSetModel;

@end

NS_ASSUME_NONNULL_END
