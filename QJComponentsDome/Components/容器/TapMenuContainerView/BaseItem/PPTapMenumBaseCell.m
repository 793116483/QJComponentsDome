//
//  PPTapMenumBaseCell.m
//  PatPat
//
//  Created by 杰 on 2021/8/4.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "PPTapMenumBaseCell.h"
#import "PPTapMenumBaseModel.h"

@implementation PPTapMenumBaseCell

-(void)setModel:(PPTapMenumBaseModel *)model {
    _model = model ;
    
    self.clipsToBounds = YES ;
    self.layer.cornerRadius = model.cornerRadius ;
    self.layer.borderWidth = model.borderWidth ;
    
    if (model.selected) {
        self.layer.borderColor = model.selectedBorderColor.CGColor ;
        self.backgroundColor = model.selectedBackgroundColor ;
    }else{
        self.layer.borderColor = model.normalBorderColor.CGColor ;
        self.backgroundColor = model.normalBackgroundColor ;
    }
}

@end
