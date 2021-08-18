//
//  QJBaseModel.m
//  QJSocketDome(环信SDK)
//
//  Created by 瞿杰 on 2019/12/8.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import "QJBaseModel.h"

@implementation QJBaseModel

+(instancetype)modelWithImage:(UIImage *)image title:(NSString *)title subTitle:(NSString *)subTitle{
    QJBaseModel * model = [[self alloc] init];
    
    model.image = image ;
    model.title = title ;
    model.subTitle = subTitle ;

    return model ;
}
+(instancetype)modelWithImageName:(NSString *)imageName title:(NSString *)title subTitle:(NSString *)subTitle{
    UIImage * image = imageName.length > 0 ? [UIImage imageNamed:imageName] : nil ;
    return [self modelWithImage:image title:title subTitle:subTitle];
}

-(instancetype)init {
    if (self = [super init]) {
        self.style = UITableViewCellStyleSubtitle ;
        self.showSelectBacground = YES ;
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    }
    return self ;
}

@end
