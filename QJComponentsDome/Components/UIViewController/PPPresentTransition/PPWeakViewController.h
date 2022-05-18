//
//  PPWeakViewController.h
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPWeakViewController : NSObject
@property (nonatomic , weak , nullable) UIViewController * vc ;
@end

NS_ASSUME_NONNULL_END
