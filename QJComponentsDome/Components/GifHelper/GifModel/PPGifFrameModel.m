//
//  PPGifFrameModel.m
//  PatPat
//
//  Created by 杰 on 2022/9/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPGifFrameModel.h"

@implementation PPGifFrameModel

+(instancetype)gifFrameModelWithDuration:(NSTimeInterval)duration index:(NSUInteger)index{
    return [[self alloc] initWithDuration:duration index:index];
}

-(instancetype)initWithDuration:(NSTimeInterval)duration index:(NSUInteger)index{
    if (self = [super init]) {
        _duration = duration;
        _index = index;
    }
    return self;
}

@end
