//
//  PPTapMenumBaseModel.m
//  PatPat
//
//  Created by 杰 on 2021/8/4.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "PPTapMenumBaseModel.h"

@implementation PPTapMenumBaseModel

-(instancetype)init {
    if (self = [super init]) {
        self.cellClass = NSClassFromString(@"PPTapMenumBaseCell");
        self.borderWidth = 0.5 ;
//        self.normalBorderColor = [UIColor colorWithHexString:@"#F8F8F7" alpha:1.0];
//        self.selectedBorderColor = [UIColor colorWithHexString:@"#FFD7D7" alpha:1.0];
//        self.normalBackgroundColor = [UIColor colorWithHexString:@"#F8F8F7" alpha:1.0];
//        self.selectedBackgroundColor = [UIColor colorWithHexString:@"#FFF6F6" alpha:1.0];
    }
    return self;
}

-(NSString *)reuseIdentifier {
    return _reuseIdentifier.length > 0 ? _reuseIdentifier : NSStringFromClass(self.cellClass);
}


@end
