//
//  PPTransition.m
//  PatPat
//
//  Created by 杰 on 2022/4/21.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPTransition.h"

@interface PPTransition ()

@end

@implementation PPTransition

/// present 转场动画
+(instancetype)presentTransition {
    PPTransition * transition = [PPTransition animation];
    transition.duration = 0.25f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    transition.removedOnCompletion = YES ;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return transition ;
}

/// dismiss 转场动画
+(instancetype)dismissTransition {
    PPTransition * transition = [PPTransition animation];
    transition.duration = 0.25f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    transition.removedOnCompletion = YES ;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return transition ;
}

/// push 转场动画
+(instancetype)pushTransition {
    PPTransition *transition = [PPTransition animation];
    transition.duration = 0.25f;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return transition;
}

@end
