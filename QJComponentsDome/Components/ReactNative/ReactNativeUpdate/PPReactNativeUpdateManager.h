//
//  PPReactNativeUpdateManager.h
//  ReactNativeDome
//
//  Created by 杰 on 2021/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PPReactNativeUpdateInfo ;

@interface PPReactNativeUpdateManager : NSObject

+(instancetype)shareManager ;

-(void)checkNeedUpdate:(void(^ _Nullable)(BOOL success))completion ;

@end

NS_ASSUME_NONNULL_END
