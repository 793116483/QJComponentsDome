//
//  PPLabelItemModel.m
//  PatPat
//
//  Created by 杰 on 2021/8/4.
//  Copyright © 2021 http://www.patpat.com. All rights reserved.
//

#import "PPLabelItemModel.h"

@implementation PPLabelItemModel
@synthesize itemSize = _itemSize ;

-(instancetype)init {
    if (self = [super init]) {
        self.cellClass = NSClassFromString(@"PPLabelItemCell");
        self.normalFont = [UIFont systemFontOfSize:12];
//        self.normalTitleColor = [UIColor colorWithHexString:@"#444444" alpha:1.0];
//        self.selectedTitleColor = [UIColor colorWithHexString:@"#F1435A" alpha:1.0];
    }
    return self;
}

-(void)setNormalFont:(UIFont *)normalFont {
    _normalFont = normalFont ;
    _itemSize = CGSizeZero ;
}
-(void)setTitle:(NSString *)title {
    _title = title ;
    _itemSize = CGSizeZero ;
}

-(CGSize)itemSize {
    if (!_itemSize.width || !_itemSize.height ) {
        
        CGFloat textWidth = 80;//[self.title sizeWithMaxWidth:200 font:self.normalFont lineBreakModel:NSLineBreakByTruncatingTail].width + 20;
        
        _itemSize = CGSizeMake(textWidth, 26);
    }
    
    return _itemSize;
}

-(CGFloat)cornerRadius {
    return self.itemSize.height / 2;
}

@end
