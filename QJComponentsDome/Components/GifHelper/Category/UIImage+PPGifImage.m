//
//  UIImage+PPGifImage.m
//  PatPat
//
//  Created by 杰 on 2022/11/16.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "UIImage+PPGifImage.h"
#import <objc/runtime.h>

@implementation UIImage (PPGifImage)

-(void)setGifFrameKey:(NSString *)gifFrameKey {
    objc_setAssociatedObject(self, @selector(gifFrameKey), gifFrameKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSString *)gifFrameKey {
    return objc_getAssociatedObject(self, @selector(gifFrameKey));
}

@end
