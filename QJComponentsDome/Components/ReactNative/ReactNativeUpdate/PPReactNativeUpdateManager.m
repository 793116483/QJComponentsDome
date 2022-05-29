//
//  PPReactNativeUpdateManager.m
//  ReactNativeDome
//
//  Created by 杰 on 2021/7/17.
//

#import "PPReactNativeUpdateManager.h"
#import "PPReactNativeDownloadManager.h"

@implementation PPReactNativeUpdateManager

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    static PPReactNativeUpdateManager * manager = nil ;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(void)checkNeedUpdate:(void (^)(BOOL))completion {
    // 请求网络，查检是否有新版本更新
//    [[MFNetWorkingManager sharedInstance] sendPostRequest:@"/rn/check_update" parameters:nil handler:^(id result, MFRequest *request, NSError *error) {
//        if (!error) {
//            if (isValidArray(request.content)) {
//
//                // 需要更新,则开始下载资源包
//                [[PPReactNativeDownloadManager shareManager] downloadZips:request.content];
//
//                if (completion) {
//                    completion(YES);
//                }
//            }
//        }else {
//            if (completion) {
//                completion(NO);
//            }
//        }
//    }];
}

@end
