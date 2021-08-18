//
//  QJSwitchModel.h
//  QJSocketDome(环信SDK)
//
//  Created by 瞿杰 on 2019/12/8.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import "QJBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class QJSwitchModel ;
@protocol QJSwitchModelDelegate <NSObject>
@optional
-(void)switchModel:(QJSwitchModel *)model switchClicked:(UISwitch *)switchView ;
@end

@interface QJSwitchModel : QJBaseModel

@property (nonatomic , assign, getter=isOn) BOOL on ;
@property (nonatomic , weak) id<QJSwitchModelDelegate> delegate ;

@end

NS_ASSUME_NONNULL_END
