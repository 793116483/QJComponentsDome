////
////  PPNativeModuleHander.m
////  PatPatDemo
////
////  Created by 杰 on 2021/7/15.
////
//
//#import "PPNativeModuleHander.h"
//
//const NSString * kCompletionHanderIDKey = @"completionID";
//const NSString * kCompletionHanderKey = @"completionKey";
//
//const NSString * kObserverKey = @"observerKey";
//const NSString * kObserverQueueKey = @"observerQueueKey";
//const NSString * kObserverBlockKey = @"observerBlockKey";
//
//@interface PPNativeModuleHander ()
//
///// RN的单列对象
//@property (nonatomic , weak) PPNativeModuleHander * rnShareHander ;
//
//@property (nonatomic , strong) NSMutableDictionary<PPNavtiveSendToRnNotificationName,NSMutableArray<PPComplationHanderBlock>*> * completionHanderDic ;
//
//@property (nonatomic , strong) NSMutableDictionary<PPRnSendToNativeNotificationName,NSMutableArray<NSMutableDictionary*> * > * observerInfos ;
//
//@end
//
//@implementation PPNativeModuleHander
//
//-(NSArray<PPNavtiveSendToRnNotificationName> *)supportedSendToRnNotificationNames {
//    return @[
//        PPEventToRnNotification,
//        PPChangedSiteAbbEventToRnNotification,
//        PPChangedCurrencyEventToRnNotification,
//        PPChangedLoginStatusEventToRnNotification,
//        PPChangedFavoriteStatusEventToRnNotification,
//        PPChangedScrollHeightEventToRnNotification,
//        PPChangingScrollHeightEventToRnNotification,
//        PPUserCenterRefreshEventToRnNotification,
//        PPUserCenterShareRefreshEventToRnNotification,
//        PPUserCenterAllRefreshEventToRnNotification,
//    ];
//}
//
//
//
///// RN 调用 原生方法 'rnCallBack'
///// @param methodName 事件名
///// @param parameters rn传过来的参数
///// @param completionHander 回调block，告知rn处理结果
//-(void)handleReceiveRnSendMethod:(PPRnSendToNativeNotificationName)methodName
//                      parameters:(nullable NSDictionary *)parameters
//                completionHander:(nullable PPComplationHanderBlock)completionHander {
//
//    if (![methodName isKindOfClass:NSString.class] || !methodName.length) {
//        return;
//    }
//
//    NSArray * infos = [[self shareHander].observerInfos objectForKey:methodName].copy;
//
//    if (infos.count) {
//        for (NSDictionary * info in infos) {
//            dispatch_queue_t queue = info[kObserverQueueKey]?: dispatch_get_main_queue() ;
//            PPObserverUsingBlock usingBlock = info[kObserverBlockKey];
//            if (usingBlock) {
//                // 执行
//                dispatch_async(queue, ^{
//                    usingBlock(parameters , completionHander);
//                });
//
//            }
//        }
//
//    }else {
//        // 无监听处理时
//        NSLog(@"xxxxxxxxxxx");
//
//    }
//}
//
//#pragma mark - system rn 方法
//// 导出桥接模块,默认模块名为当前class类名
//RCT_EXPORT_MODULE()
//
//-(dispatch_queue_t)methodQueue {
//    return dispatch_get_main_queue();
//}
///// 给RN发送的事件名称列表
//-(NSArray<NSString *> *)supportedEvents {
//    return [self supportedSendToRnNotificationNames];
//}
//
///// RN 监听事件名就
//-(void)addListener:(NSString *)eventName {
//    [super addListener:eventName];
//
//    // 拿到 RN 单例监听通知的 对象
//    ((PPNativeModuleHander *)[self shareHander]).rnShareHander = self ;
//}
//
//#pragma mark - 原生模块 发送通知给 RN
//
//-(void)sendToRNWithNotificationName:(PPNavtiveSendToRnNotificationName)name parameters:(NSDictionary *)parameters {
//    [self sendToRNWithNotificationName:name parameters:parameters completionID:@"" completionHander:nil];
//}
//
///// 原生模块 给 RN 发送通知
///// @param name 事件通知名
///// @param body 给 RN 传送的数据【注：数据类型只能包含 基本的数据类型 、NSString、NSArray 、NSDictionary 和 RCTResponseSenderBlock 】
//-(void)sendToRNWithNotificationName:(PPNavtiveSendToRnNotificationName)name
//                         parameters:(nullable NSDictionary *)parameters
//                       completionID:(nonnull NSObject *)ID
//                   completionHander:(nullable PPComplationHanderBlock)completionHander{
//
//    if (![name isKindOfClass:NSString.class] || !name.length) {
//        return;
//    }
//
//    // 判断是否支持发送的通知名
//    if (![[self supportedEvents] containsObject:name]) {
//#if DEBUG
//        NSLog(@"\n\n 【注意：】新增通知名 必须添加到 PPNativeModuleHander.m 文件中的 -[PPNativeModuleHander supportedSendToRnNotificationNames]方法里做为参数反回，否则无法发送消息给RN！！！！\n");
//#endif
//        return;
//    }
//
//    // 处理参数
//    NSMutableDictionary * param = [NSMutableDictionary dictionary];
//    if (parameters && [parameters isKindOfClass:NSDictionary.class]) {
//        [param setValuesForKeysWithDictionary:parameters];
//    }
//
//    if (completionHander && ID) {
//        NSString * Id = [NSString stringWithFormat:@"%p",ID];
//        [param setObject:Id forKey:kCompletionHanderIDKey];
//
//        // 保证多线程安全
//        @synchronized ([self shareHander]) {
//            // 保存回调
//            NSMutableArray * blocks = [[self shareHander].completionHanderDic objectForKey:name];
//            if (![blocks isKindOfClass:[NSMutableArray class]] || !blocks) {
//                blocks = [NSMutableArray array];
//            }
//            // 查看是否存在
//            BOOL isExist = NO ;
//            for (NSMutableDictionary * completionInfo in blocks) {
//                if ([[completionInfo objectForKey:kCompletionHanderIDKey] isEqualToString:Id]) {
//                    [completionInfo setObject:completionHander forKey:kCompletionHanderKey];
//                    isExist = YES ;
//                    break;
//                }
//            }
//            if (isExist == NO) {
//                NSMutableDictionary * completionInfo = [NSMutableDictionary dictionary];
//                [completionInfo setObject:Id forKey:kCompletionHanderIDKey];
//                [completionInfo setObject:completionHander forKey:kCompletionHanderKey];
//
//                [blocks addObject:completionInfo];
//            }
//
//            [[self shareHander].completionHanderDic setObject:blocks forKey:name];
//        }
//    }
//
//    // 发送通知事件
//
//    [((PPNativeModuleHander *)[self shareHander]).rnShareHander sendEventWithName:name body:param.copy];
//}
//
//RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(callObjectMethod:(NSDictionary*)methodInfo)
//{
//    if (isValidDictionary(methodInfo)) {
//
//        Class cls = NSClassFromString(methodInfo[@"class"]);
//        NSString * method = methodInfo[@"method_name"];
//        NSArray * param = methodInfo[@"param"];
//
//        SEL sel = NSSelectorFromString(method) ;
//        id target = nil ;
//        if (cls && [cls respondsToSelector:sel]) {
//            target = cls ;
//        }else if(cls && [[cls new] respondsToSelector:sel]){
//            target = [cls new];
//        }
//        // 判断是否
//        if (!target || !sel) {
//            return nil;
//        }
//        NSMethodSignature* signature = [target methodSignatureForSelector:sel];
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//        invocation.target = target;
//        invocation.selector = sel;
//        // 方法传参
//        for (int i = 0; i < param.count; i++) {
//            id object = param[i];
//            if (object && !ISNULL(object)) {
//                [invocation setArgument:&object atIndex:i+2];
//            }
//        }
//        [invocation retainArguments];
//
//        // 执行方法
//        [invocation invoke];
//
//        NSString * methodReturnType = [NSString stringWithUTF8String:signature.methodReturnType];
//
//        if (!signature.methodReturnLength || !isValidString(methodReturnType)) {
//            return nil;
//        }
//
//        // 有符号整型
//        NSArray * intTypes = @[@"c",@"i",@"s",@"l",@"q",@"B"];
//        // 无符号整型
//        NSArray * unIntTypes = @[@"C",@"I",@"S",@"L",@"Q"];
//
//        if ([intTypes containsObject:methodReturnType]) {
//            long long resultLong = 0 ;
//            [invocation getReturnValue:&resultLong];
//            return @(resultLong);
//
//        }else if ([unIntTypes containsObject:methodReturnType]) {
//            unsigned long long resultLong = 0 ;
//            [invocation getReturnValue:&resultLong];
//            return @(resultLong);
//
//        }else if ([methodReturnType isEqualToString:@"d"]) {
//            double resultDouble = 0 ;
//            [invocation getReturnValue:&resultDouble];
//            return @(resultDouble);
//
//        }else if ([methodReturnType isEqualToString:@"f"]) {
//            float resultFloat = 0 ;
//            [invocation getReturnValue:&resultFloat];
//            return @(resultFloat);
//
//        }else if([methodReturnType isEqualToString:@"*"]){
//            char * resultCharStr = "";
//            [invocation getReturnValue:&resultCharStr];
//            return [NSString stringWithFormat:@"%s",resultCharStr];
//        }else {
//            __unsafe_unretained id result = nil;
//            [invocation getReturnValue:&result];
//
//            return  result;
//        }
//    }
//    return nil;
//}
//
//// rn 回调
//RCT_EXPORT_METHOD(rnCompletionHander:(NSString *)name ID:(NSString *)ID parameters:(NSDictionary *)parameters) {
//
//    if (![name isKindOfClass:NSString.class] || !name.length || ![ID isKindOfClass:NSString.class] || !ID.length) {
//        return;
//    }
//
//    NSMutableDictionary * needRemoveBlock = nil;
//    NSMutableArray * blocks = [[self shareHander].completionHanderDic objectForKey:name];
//
//    for (NSMutableDictionary * completionInfo in blocks) {
//        if ([[completionInfo objectForKey:kCompletionHanderIDKey] isEqualToString:ID]) {
//            PPComplationHanderBlock completionHander = [completionInfo objectForKey:kCompletionHanderKey];
//            if (completionHander) {
//                completionHander(parameters?:@{});
//            }
//
//            needRemoveBlock = completionInfo ;
//            break;
//        }
//    }
//
//    if (needRemoveBlock) {
//        [blocks removeObject:needRemoveBlock];
//    }
//    if (!blocks.count) {
//        [[self shareHander].completionHanderDic removeObjectForKey:name];
//    }
//}
//
//#pragma mark - RN 回调给 原生模块
//
//RCT_EXPORT_METHOD(rnCallWithParametersAndCompletion:(NSString *)methodName parameters:(NSDictionary *)parameters callBack:(RCTResponseSenderBlock)callBack) {
//
//    [[self shareHander] handleReceiveRnSendMethod:methodName parameters:parameters completionHander:^(NSDictionary * _Nullable result) {
//        if (callBack) {
//            callBack(result? @[result]:@[]);
//        }
//    }];
//}
//
//RCT_EXPORT_METHOD(rnCallWithCompletion:(NSString *)methodName callBack:(RCTResponseSenderBlock)callBack) {
//
//    [[self shareHander] handleReceiveRnSendMethod:methodName parameters:nil completionHander:^(NSDictionary * _Nullable result) {
//        if (callBack) {
//            callBack(result? @[result]:@[]);
//        }
//    }];
//}
//
//RCT_EXPORT_METHOD(rnCallWithParameters:(NSString *)methodName parameters:(NSDictionary *)parameters) {
//
//    [[self shareHander] handleReceiveRnSendMethod:methodName parameters:parameters completionHander:nil];
//}
//
//RCT_EXPORT_METHOD(rnCall:(NSString *)methodName) {
//
//    [[self shareHander] handleReceiveRnSendMethod:methodName parameters:nil completionHander:nil];
//}
//
//#pragma mark - 私有方法
//+(instancetype)shareHander {
//    static dispatch_once_t onceToken;
//    static PPNativeModuleHander * hander = nil ;
//    dispatch_once(&onceToken, ^{
//        hander = [[self alloc] init];
//    });
//    return hander;
//}
//-(instancetype)shareHander {
//    return [[self class] shareHander];
//}
//
//-(void)addRnCallMethodWithObserver:(id)aObserver
//                              name:(PPRnSendToNativeNotificationName)aName
//                             queue:(dispatch_queue_t)queue
//                        usingBlock:(PPObserverUsingBlock)block {
//
//    if (!aObserver || ![aName isKindOfClass:[NSString class]] || !aName.length || !block) {return;}
//
//    @synchronized ([self shareHander]) {
//
//        NSString * observerKeyValue = [NSString stringWithFormat:@"%p",aObserver];
//
//        // 保存回调
//        NSMutableArray * infos = [[self shareHander].observerInfos objectForKey:aName];
//        if (![infos isKindOfClass:[NSMutableArray class]] || !infos) {
//            infos = [NSMutableArray array];
//        }
//
//        // 查看是否存在
//        BOOL isExist = NO ;
//        for (NSMutableDictionary * info in infos) {
//            if ([[info objectForKey:kObserverKey] isEqualToString:observerKeyValue]) {
//                // 存在更新对应的 queue 和 block
//                [info setObject:block forKey:kObserverBlockKey];
//                if (queue) {
//                    [info setObject:queue forKey:kObserverQueueKey];
//                }
//                isExist = YES ;
//                break;
//            }
//        }
//        if (isExist == NO) {
//            // 初始数据
//            NSMutableDictionary * info = [NSMutableDictionary dictionary];
//            [info setObject:observerKeyValue forKey:kObserverKey];
//            [info setObject:block forKey:kObserverBlockKey];
//            if (queue) {
//                [info setObject:queue forKey:kObserverQueueKey];
//            }
//
//            // 添加新的观察组
//            [infos addObject:info];
//        }
//
//        // 保存数据
//        [[self shareHander].observerInfos setObject:infos forKey:aName];
//    }
//
//}
//
//-(void)removeRnCallMethodWithObserver:(id)aObserver name:(PPRnSendToNativeNotificationName)aName {
//    if (!aObserver || ![aName isKindOfClass:[NSString class]] || !aName.length) {return;}
//
//    @synchronized ([self shareHander]) {
//
//        NSString * observerKeyValue = [NSString stringWithFormat:@"%p",aObserver];
//        NSMutableArray * infos = [[self shareHander].observerInfos objectForKey:aName];
//        NSDictionary * needRemoveInfo = nil ;
//        // 查找需要移除的数据
//        for (NSMutableDictionary * info in infos) {
//            if ([[info objectForKey:kObserverKey] isEqualToString:observerKeyValue]) {
//                needRemoveInfo = info ;
//                break;
//            }
//        }
//        // 移除数据
//        if (needRemoveInfo) {
//            [infos removeObject:needRemoveInfo];
//        }
//        // 移除空观察组
//        if (!infos.count) {
//            [[self shareHander].observerInfos removeObjectForKey:aName];
//        }
//    }
//}
//
//-(NSMutableDictionary<PPNavtiveSendToRnNotificationName,NSMutableArray<PPComplationHanderBlock> *> *)completionHanderDic {
//    if (!_completionHanderDic) {
//        _completionHanderDic = [NSMutableDictionary dictionary];
//    }
//    return _completionHanderDic;
//}
//
//-(NSMutableDictionary<PPRnSendToNativeNotificationName,NSMutableArray<NSMutableDictionary *> *> *)observerInfos {
//    if (!_observerInfos) {
//        _observerInfos = [NSMutableDictionary dictionary];
//    }
//    return _observerInfos;
//}
//
//
//#pragma mark - 示例
//-(void)addRuntimObserver {
//    [[PPNativeModuleHander shareHander] addRnCallMethodWithObserver:self name:kRuntimeToNativeNotification queue:dispatch_get_main_queue() usingBlock:^(NSDictionary * _Nullable parameters, PPComplationHanderBlock  _Nullable completionHander) {
//        if (isValidDictionary(parameters)) {
//
//            Class cls = NSClassFromString(parameters[@"class"]);
//            NSString * method = parameters[@"method_name"];
//            NSArray * param = parameters[@"param"];
//
//            SEL sel = NSSelectorFromString(method) ;
//            id target = nil ;
//            if (cls && [cls respondsToSelector:sel]) {
//                target = cls ;
//            }else if(cls && [[cls new] respondsToSelector:sel]){
//                target = [cls new];
//            }
//            // 判断是否
//            if (!target || !sel) {
//                if (completionHander) {
//                    completionHander(nil);
//                }
//                return;
//            }
//            NSMethodSignature* signature = [target methodSignatureForSelector:sel];
//            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//            invocation.target = target;
//            invocation.selector = sel;
//            // 方法传参
//            for (int i = 0; i < param.count; i++) {
//                id object = param[i];
//                [invocation setArgument:&object atIndex:i+2];
//            }
//            // 执行方法
//            [invocation invoke];
//
//            __unsafe_unretained id result = nil;
//
//            // 获取返回参数
//            if (signature.methodReturnLength) {
//                [invocation getReturnValue:&result];
//            }
//
//            // 回调
//            if (completionHander) {
//                completionHander(result);
//            }
//        }
//    }];
//}
//
//@end
//
//
//#pragma mark - RN监听的通知名
//PPNavtiveSendToRnNotificationName const PPEventToRnNotification = @"event";
///// 通知RN 切换了站点
//PPNavtiveSendToRnNotificationName const PPChangedSiteAbbEventToRnNotification = @"changed_site_abb_event";
///// 通知RN 切换了货币
//PPNavtiveSendToRnNotificationName const PPChangedCurrencyEventToRnNotification = @"changed_currency_event";
///// 通知RN 切换登录状态
//PPNavtiveSendToRnNotificationName const PPChangedLoginStatusEventToRnNotification = @"changed_login_status_event";
///// 通知RN 收藏状态改变
//PPNavtiveSendToRnNotificationName const PPChangedFavoriteStatusEventToRnNotification = @"changed_favorite_status_event";
///// 通知RN 滑动高度改变
//PPNavtiveSendToRnNotificationName const PPChangedScrollHeightEventToRnNotification = @"new_channel_header_scrolled";
///// 通知RN 滑动高度改变中
//PPNavtiveSendToRnNotificationName const PPChangingScrollHeightEventToRnNotification = @"new_channel_header_scrolling";
//
//#pragma mark -- 个人中心交互
///// 用户信息变更通知
//PPNavtiveSendToRnNotificationName const PPUserCenterRefreshEventToRnNotification = @"user_center_refresh";
///// 用户分享信息变更通知
//PPNavtiveSendToRnNotificationName const PPUserCenterShareRefreshEventToRnNotification = @"user_center_share_refresh";
///// 个人中心所有接口请求
//PPNavtiveSendToRnNotificationName const PPUserCenterAllRefreshEventToRnNotification = @"user_center_refresh_all";
//
//#pragma mark - RN发出的通知名
//PPRnSendToNativeNotificationName const PPEventToNativeNotification = @"event";
//
//#pragma mark -RN获取原生请求头参数
//PPRnSendToNativeNotificationName const PPRequestHeadersInfoToNativeNotification = @"request_headers_info";
//
//#pragma mark -RN获取post请求body参数
//PPRnSendToNativeNotificationName const PPRequestRequestNotificationAuthInfoToNativeNotification = @"notification_auth";
//
//#pragma mark -RN调用原生跳转商品详情页面
//PPRnSendToNativeNotificationName const PPJumpProductDetailToNativeNotification = @"jump_product_detail";
//
//#pragma mark -RN调用原生返回上一个页面
//PPRnSendToNativeNotificationName const PPGoBackToNativeNotification = @"goBack";
//
//#pragma mark -RN调用原生曝光商品数据
//PPRnSendToNativeNotificationName const PPExposureProductsToNativeNotification = @"exposure_products";
//
//#pragma mark -RN调用原生曝光按钮
//PPRnSendToNativeNotificationName const PPExposureButtonToNativeNotification = @"exposure_button";
//
//#pragma mark -RN调用原生点击按钮
//PPRnSendToNativeNotificationName const PPClickButtonToNativeNotification = @"click_button";
//
//#pragma mark -RN调用原生page页面上报
//PPRnSendToNativeNotificationName const PPPageToNativeNotification = @"page";
//
//#pragma mark -RN调用原生路由跳转
//PPRnSendToNativeNotificationName const PPURLRouteToNativeNotification = @"url_route";
//
//#pragma mark -RN调用原生所有接口入口
//PPRnSendToNativeNotificationName const PPRequestToNativeNotification = @"request_data";
//
//#pragma mark -RN调用原生分享
//PPRnSendToNativeNotificationName const PPShareToNativeNotification = @"share";
//
//#pragma mark -RN调用原生高webview弹窗
//PPRnSendToNativeNotificationName const PPHighWebViewPopupToNativeNotification = @"high_webview_popup";
//
//#pragma mark -RN调用原生库存订阅开启通知
//PPRnSendToNativeNotificationName const PPSubscriptionProductStockToNativeNotification = @"subscription_productstock";
//
//#pragma mark -RN加购成功告诉原生上报事件通知
//PPRnSendToNativeNotificationName const PPAddCartSuccessToNativeNotification = @"add_cart_success";
//
//#pragma mark -RN签到成功事件通知
//PPRnSendToNativeNotificationName const PPCheckInSuccessToNativeNotification = @"check_in_success";
//
//#pragma mark -RN打开相册选图
//PPRnSendToNativeNotificationName const PPOpenAlbumToNativeNotification = @"open_album";
//
//#pragma mark -RN打开相册选图
//PPRnSendToNativeNotificationName const PPSaveAlbumToNativeNotification = @"save_album";
//
//#pragma mark - RN调用加购
//PPRnSendToNativeNotificationName const PPAddCartToNativeNotification = @"add_to_cart";
//
//#pragma mark - RN签到完成
//PPRnSendToNativeNotificationName const PPCheckInToNativeNotification = @"on_check_in";
