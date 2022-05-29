////
////  PPReactNativeInfoManager.h
////  ReactNativeDome
////
////  Created by 杰 on 2021/7/19.
////
//
//#import <Foundation/Foundation.h>
//#import <React/RCTBridgeDelegate.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@class PPReactNativeUpdateInfo , RCTBridge;
//
//@interface PPReactNativeInfoManager : NSObject<RCTBridgeDelegate>
//
//@property (nonatomic , strong ) RCTBridge * rnBridge;
//
//+(instancetype)shareManager;
//
//- (void)initRnBridge:(nullable NSDictionary *)launchOptions;
//
//-(NSString *)jsbundleFileRootPath;
//
//// 获取 RN 配制文件的 相对路径
//-(NSString *)reactNativeInfoPlistPath;
//
//// 获取版本号
//-(NSString *)getReactNativeVersion;
//
///// 是否允许更新指定的版本
///// @param version 需要更新的版本号
//-(BOOL)allowUpdateWithVersion:(NSString *)version;
//
///// 开始更新版本内容【jsbundle、图片资源 和 配制文件reactNativeInfo.plist 】
///// @param updateInfoMode 更新的内容
//-(void)updateJsBundleWithUpateInfoMode:(PPReactNativeUpdateInfo *)updateInfoMode;
//
///// 强制替换成跟随APP发包的本地 bundle.zip 内 rn的 全量包
//-(void)forceReplaceByAppLocationFullPackage;
//
//- (void)reloadBridge;
//
//@end
//
//
//
//
//@interface PPReactNativeUpdateInfo : NSObject
//
///// 是否为全量包
//@property (nonatomic , readonly , assign)             BOOL  isFullPackage ;
///// 更新的版本号
//@property (nonatomic , readonly , nonnull , copy)     NSString * updateVersion ;
///// 更新本地的 .jsbundle 文件需要的文件 相对路径
//@property (nonatomic , readonly , nullable, copy)    NSString * updateJsbundleNeedPath ;
///// 更新资源文件 相对路径
//@property (nonatomic , readonly , nullable, copy)     NSString * updateImageAssetsPath ;
///// 更新完回调
//@property (nonatomic , readonly , nullable )          void (^updateCompletion)(BOOL updateSuccess) ;
//
//
///// 创建 UpdateInfo 模型数据，返回值可为nil, updateJsbundleNeedPath 和 updateImageAssetsPath 至少存在一个不为空，否则返回 nil
//+(nullable instancetype)updateInfoWithFullPackage:(BOOL)isFullPackage
//                                    updateVersion:(nonnull NSString *)updateVersion
//                           updateJsbundleNeedPath:(nullable NSString *)updateJsbundleNeedPath
//                            updateImageAssetsPath:(nullable NSString *)updateImageAssetsPath
//                                 updateCompletion:(void (^)(BOOL updateSuccess))updateCompletion ;
//
//@end
//
//
//NS_ASSUME_NONNULL_END
