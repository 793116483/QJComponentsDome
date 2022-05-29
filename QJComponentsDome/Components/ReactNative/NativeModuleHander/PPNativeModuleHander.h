////
////  PPNativeModuleHander.h
////  PatPatDemo
////
////  Created by 杰 on 2021/7/15.
////
//
//#import <Foundation/Foundation.h>
//#import <React/RCTEventEmitter.h>
//
//typedef NSString * PPNavtiveSendToRnNotificationName;
//typedef NSString * PPRnSendToNativeNotificationName;
//
//typedef void(^PPComplationHanderBlock)(NSDictionary * _Nullable result);
//typedef void(^PPObserverUsingBlock)(NSDictionary * _Nullable parameters , PPComplationHanderBlock _Nullable completionHander);
//
//
//NS_ASSUME_NONNULL_BEGIN
//@interface PPNativeModuleHander : RCTEventEmitter
//
///// 原生的单列对象
//+(instancetype)shareHander ;
//
//
//#pragma mark - RN 回调给 原生模块
//
///// 添加观察，处理 RN 调用 原生 方法：【**** 交互的参数都是 '字典' ****】
///// 'rnCall'                            :不接收传参数，无回调
///// 'rnCallWithParameters'              :  接收传参数，无回调
///// 'rnCallWithCompletion'              :不接收传参数，有回调
///// 'rnCallWithParametersAndCompletion' :  接收传参数，有回调
///// @param aObserver 观察者
///// @param aName 通知事件名
///// @param queue 决定 usingBlock 是在主线程还是子线程执行
///// @param usingBlock parameters为RN传过来的参数，completionHander 告知rn处理结果
//-(void)addRnCallMethodWithObserver:(nonnull id)aObserver
//                              name:(nonnull PPRnSendToNativeNotificationName)aName
//                             queue:(nullable dispatch_queue_t)queue
//                        usingBlock:(nonnull PPObserverUsingBlock)block ;
//
///// 移除观察
///// @param aObserver 观察者
///// @param aName 通知事件名
//-(void)removeRnCallMethodWithObserver:(nonnull id)aObserver
//                                 name:(nonnull PPRnSendToNativeNotificationName)aName;
//
//
//#pragma mark - 原生模块 发送通知给 RN
//
///// 原生模块 给 RN 发送通知
///// @param name 事件通知名
///// @param parameters 给 RN 传送的数据【注：数据类型只能包含 基本的数据类型 、NSString、NSArray 、NSDictionary】
//-(void)sendToRNWithNotificationName:(nonnull PPNavtiveSendToRnNotificationName)name
//                         parameters:(nullable NSDictionary *)parameters ;
//
///// 原生模块 给 RN 发送通知
///// @param name 事件通知名
///// @param parameters 给 RN 传送的数据【注：数据类型只能包含 基本的数据类型 、NSString、NSArray 、NSDictionary】
///// @param completionID 用于区分 completionHander，且用于 RN端 判断是否需要回调给原生
///// @param completionHander 事件通知名
//-(void)sendToRNWithNotificationName:(nonnull  PPNavtiveSendToRnNotificationName)name
//                         parameters:(nullable NSDictionary *)parameters
//                       completionID:(nonnull  NSObject *)ID
//                   completionHander:(nullable PPComplationHanderBlock)completionHander;
//
//
//#pragma mark - 原生监听RN 示例
//-(void)addRuntimObserver;
//
//@end
//
//
//#pragma mark - 原生发出的通知名
///**  RN端 监听原生发出通知的方式
// 
//    let PPNativeModuleHander = NativeModules.PPNativeModuleHander;
//    const nativeModuleObsever = new NativeEventEmitter(PPNativeModuleHander);
//    let eventToNativeNotification = 'event';    // 这个通知名 就是原生发出的通知名
//
//    nativeModuleObsever.addListener(eventToNativeNotification, result => {
//        // 处理收到的 result 信息....
// 
//        // 有completionID说明需要调原生方法 rnCompletionHander
//        if (result.completionID) {
//            PPNativeModuleHander.rnCompletionHander(
//               eventToNativeNotification,
//               result.completionID,
//               {message: 'RN监听的事件处理完，给原生的回调信息'},
//            );
//        }
//    });
// */
//extern PPNavtiveSendToRnNotificationName const PPEventToRnNotification;
///// 通知RN 切换了站点
//extern PPNavtiveSendToRnNotificationName const PPChangedSiteAbbEventToRnNotification;
///// 通知RN 切换了货币
//extern PPNavtiveSendToRnNotificationName const PPChangedCurrencyEventToRnNotification;
///// 通知RN 切换登录状态
//extern PPNavtiveSendToRnNotificationName const PPChangedLoginStatusEventToRnNotification;
///// 通知RN 收藏状态改变
//extern PPNavtiveSendToRnNotificationName const PPChangedFavoriteStatusEventToRnNotification;
///// 通知RN 滑动高度改变
//extern PPNavtiveSendToRnNotificationName const PPChangedScrollHeightEventToRnNotification;
///// 通知RN 滑动高度改变中
//extern PPNavtiveSendToRnNotificationName const PPChangingScrollHeightEventToRnNotification;
///// 通知RN 用户信息变更
//extern PPNavtiveSendToRnNotificationName const PPUserCenterRefreshEventToRnNotification;
///// 通知RN 用户分享信息变更
//extern PPNavtiveSendToRnNotificationName const PPUserCenterShareRefreshEventToRnNotification;
///// 个人中心所有接口请求
//extern PPNavtiveSendToRnNotificationName const PPUserCenterAllRefreshEventToRnNotification;
//
//#pragma mark - RN发出的通知名
///**  RN端 调用原生的方式
// 
//    let PPNativeModuleHander = NativeModules.PPNativeModuleHander;
//    let eventToRnNotification = 'event';    // 这个通知名 就是原生监听观察的通知名
// 
//    PPNativeModuleHander.rnCallWithParametersAndCompletion(
//       eventToRnNotification,           // 通知名
//       {message: 'RN调用原生方法传的参数'}, // 传给原生的参数
//       resultInfo => {                  // 原生回调RN，resultInfo为字典类型
//         // 处理 resultInfo 信息....
//       },
//    );
// */
///**  【注意 => 新增通知名】: 原生端需要修改的代码
//    
//      新增通知名 必须添加到 PPNativeModuleHander.m 文件中的 -[PPNativeModuleHander supportedSendToRnNotificationNames]方法里做为参数反回
// */
//extern PPRnSendToNativeNotificationName const PPEventToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPRequestHeadersInfoToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPJumpProductDetailToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPGoBackToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPExposureProductsToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPExposureButtonToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPClickButtonToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPPageToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPRequestRequestNotificationAuthInfoToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPURLRouteToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPRequestToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPShareToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPHighWebViewPopupToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPSubscriptionProductStockToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPAddCartSuccessToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPCheckInSuccessToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPOpenAlbumToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPSaveAlbumToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPAddCartToNativeNotification;
//
//extern PPRnSendToNativeNotificationName const PPCheckInToNativeNotification;
//
//NS_ASSUME_NONNULL_END
//
