////
////  PPReactNativeDownloadManager.m
////  ReactNativeDome
////
////  Created by 杰 on 2021/7/17.
////
//
//#import "PPReactNativeDownloadManager.h"
//#import "PPReactNativeFileHandler.h"
//#import "PPReactNativeInfoManager.h"
//#import "PPReactNativeUpdateManager.h"
//
//static const NSString * kDownloadFilePathKey = @"downloadFilePath";
//// 网络参数
//static const NSString * kResponseFileKey = @"file";
//static const NSString * kResponseFileMd5Key = @"file_md5";
//static const NSString * kResponsePreJsbundlVersionKey = @"pre_jsbundle_version";
//static const NSString * kResponseCurrentJsbundlVersionKey = @"jsbundle_version";
//static const NSString * kResponseIsFullPackageKey = @"is_full_package";
//
//@implementation PPReactNativeDownloadManager
//
//+(instancetype)shareManager {
//    static dispatch_once_t onceToken;
//    static PPReactNativeDownloadManager * manager = nil ;
//    dispatch_once(&onceToken, ^{
//        manager = [[self alloc] init];
//    });
//    return manager;
//}
//
//-(void)downloadZips:(NSArray<NSDictionary *> *)zipArray {
//    if (!isValidArray(zipArray)) {
//        return;
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        for (NSDictionary * zipInfo in zipArray) {
//            [self downloadZip:zipInfo];
//        }
//    });
//}
//
//-(void)downloadZip:(NSDictionary *)zipInfo {
//    if (!isValidDictionary(zipInfo) || !isValidString(zipInfo[kResponseFileKey])) {return;}
//
//    // 拿取网络配制信息
//    NSString * requestUrl = zipInfo[kResponseFileKey];
//    NSString * needUpdateVersion = FormatString(zipInfo[kResponseCurrentJsbundlVersionKey], @"") ;
//
//    // 如果大版本不一样直接返回
//    if (![PPReactNativeInfoManager.shareManager allowUpdateWithVersion:needUpdateVersion]) {return;}
//
//    NSString * fileNameVersion = [needUpdateVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
//    NSString * fileName = [NSString stringWithFormat:@"%@(%@)",[requestUrl toMD5],fileNameVersion];
//    NSString * destinationPath = [[[PPReactNativeFileHandler shareHandler] downloadRootPath] stringByAppendingPathComponent:fileName];
//    NSString * downloadFilePath = [NSString stringWithFormat:@"%@.zip",destinationPath];
//
//    {
//        NSDictionary * zipInfoLocation = [[PPReactNativeFileHandler shareHandler] downloadInfoPlistFileExistsWithName:fileName];
//        NSString * destPath = zipInfoLocation[kDownloadFilePathKey] ;
//
//        // 判断是否已经存在
//        if (zipInfoLocation && [[PPReactNativeFileHandler shareHandler] fileExistsAtPath:destPath] && [self isEqualWithZipInfo:zipInfo zipInfoLocation:zipInfoLocation]) {
//            // 更新
//            [self needHotUpdate];
//            return;
//        }else if(zipInfoLocation){ // 配制文件存在，但下载好的资源文件不在了
//            // 移除本地下载的配制文件
//            [[PPReactNativeFileHandler shareHandler] removeDownloadInfoPlist:zipInfoLocation];
//            [[PPReactNativeFileHandler shareHandler] removeFileWithPath:destPath];
//        }
//    }
//
//    // 创建目标文件
//    [[PPReactNativeFileHandler shareHandler] createFileIfNeedWithPath:destinationPath isDirectory:YES];
//
//    // 开始下载资源
//    [[MFNetWorkingManager sharedInstance] sendDownloadRNHotUpdateRequest:requestUrl
//                                                                 fileMd5:FormatString(zipInfo[kResponseFileMd5Key], @"")
//                                                        downloadFilePath:downloadFilePath
//                                                         destinationPath:destinationPath
//                                                                progress:nil
//                                                                 success:^(id responseObject) {
//        if ([responseObject boolValue]) {// 下载并解压成功
//
//            NSMutableDictionary * zipInfoLocation = [NSMutableDictionary dictionaryWithDictionary:zipInfo];
//            // 指向下载解压好的文件夹
//            [zipInfoLocation setObject:destinationPath forKey:kDownloadFilePathKey];
//            // 保存
//            [[PPReactNativeFileHandler shareHandler] saveDownloadInfoPlist:zipInfoLocation fileName:fileName];
//
//            // 更新
//            [self needHotUpdate];
//        }
//    } failure:nil];
//}
//
//-(BOOL)isEqualWithZipInfo:(NSDictionary *)zipInfo zipInfoLocation:(NSDictionary *)zipInfoLocation {
//    if (!isValidDictionary(zipInfo) || !isValidDictionary(zipInfo)) {
//        return NO;
//    }
//    for (NSString * key in zipInfo.allKeys) {
//        NSString * zipInfoValue = [NSString stringWithFormat:@"%@",zipInfo[key]];
//        NSString * zipInfoLocationValue = [NSString stringWithFormat:@"%@",zipInfoLocation[key]];
//        if (![zipInfoValue isEqualToString:zipInfoLocationValue]) {
//            return NO;
//        }
//    }
//    return YES;
//}
//
///// 开始热更新
//-(void)needHotUpdate {
//
//    NSArray<NSDictionary *> * downloadInfoPlistArray = [[PPReactNativeFileHandler shareHandler] downloadInfoPlistArray];
//
//    for (NSDictionary * downloadInfoPlist in downloadInfoPlistArray) {
//
//        NSString * preVersion = FormatString(downloadInfoPlist[kResponsePreJsbundlVersionKey], @"");
//        NSString * needUpdateVersion = FormatString(downloadInfoPlist[kResponseCurrentJsbundlVersionKey], @"");
//        NSString * destinationPath = downloadInfoPlist[kDownloadFilePathKey]?:@"" ;
//        BOOL isFullPackage = [downloadInfoPlist[kResponseIsFullPackageKey] boolValue] ;
//
//        // 本地的rn版本号
//        NSString * locationJsVersion = [PPReactNativeInfoManager.shareManager getReactNativeVersion] ;
//
//        BOOL isDirectory = NO ;
//        if (![PPReactNativeFileHandler.shareHandler fileExistsAtPath:destinationPath isDirectory:&isDirectory] || !isDirectory || ![PPReactNativeInfoManager.shareManager allowUpdateWithVersion:needUpdateVersion]) {
//            // 对应下载的文件不存在了，移除本地下载的配制文件
//            [[PPReactNativeFileHandler shareHandler] removeDownloadInfoPlist:downloadInfoPlist];
//            [[PPReactNativeFileHandler shareHandler] removeFileWithPath:destinationPath];
//            continue;
//        }
//
//        if (isValidString(preVersion) && [locationJsVersion isEqualToString:preVersion]) {
//
//            NSString * updateJsbundleNeedPath = isFullPackage ? [self jsbundleInPath:destinationPath] : [self patchsInPath:destinationPath];
//            NSString * imageAssetsInPath = [self imageAssetsWithJsbundlePath:updateJsbundleNeedPath] ;
//
//            PPReactNativeUpdateInfo * updateInfo = [PPReactNativeUpdateInfo updateInfoWithFullPackage:isFullPackage
//                                                                                        updateVersion:needUpdateVersion
//                                                                               updateJsbundleNeedPath:updateJsbundleNeedPath
//                                                                                updateImageAssetsPath:imageAssetsInPath
//                                                                                     updateCompletion:^(BOOL updateSuccess){
//                if (updateSuccess) {
//                    [self hotUpdateSuccessWithDownloadInfoPlist:downloadInfoPlist];
//                }
//            }];
//            if (!updateInfo) {
//                // 对应下载的文件不存在了，移除本地下载的配制文件
//                [[PPReactNativeFileHandler shareHandler] removeDownloadInfoPlist:downloadInfoPlist];
//                [[PPReactNativeFileHandler shareHandler] removeFileWithPath:destinationPath];
//            }
//            [[PPReactNativeInfoManager shareManager] updateJsBundleWithUpateInfoMode:updateInfo];
//        }
//    }
//}
//
//-(void)hotUpdateSuccessWithDownloadInfoPlist:(NSDictionary *)downloadInfoPlist {
//
//    NSString * destinationPath = downloadInfoPlist[kDownloadFilePathKey] ;
//    // 更新成功后，移除不必要的文件
//    [[PPReactNativeFileHandler shareHandler] removeDownloadInfoPlist:downloadInfoPlist];
//    [[PPReactNativeFileHandler shareHandler] removeFileWithPath:destinationPath];
//
//    // 继续查看是否有下载好的需要更新
//    [self needHotUpdate];
//}
//
//-(NSString *)jsbundleInPath:(NSString *)destinationPath {
//    return [[PPReactNativeFileHandler shareHandler] findPathWithSuffix:@".jsbundle" isDirectory:NO matchCase:NO folderPath:destinationPath];
//}
//-(NSString *)patchsInPath:(NSString *)destinationPath {
//    return [[PPReactNativeFileHandler shareHandler] findPathWithSuffix:@".pat" isDirectory:NO matchCase:NO folderPath:destinationPath];
//}
//-(NSString *)imageAssetsWithJsbundlePath:(NSString *)jsbundlePath {
//    if (!isValidString(jsbundlePath) || !isValidString(jsbundlePath.lastPathComponent)) {
//        return nil;
//    }
//
//    NSString * lastPath = jsbundlePath.lastPathComponent ;
//    NSString * assetsPath = [jsbundlePath stringByReplacingOccurrencesOfString:lastPath withString:@"assets"];
//
//    BOOL isDirectory ;
//    if (![[PPReactNativeFileHandler shareHandler] fileExistsAtPath:assetsPath isDirectory:&isDirectory] || !isDirectory) {
//        return nil;
//    }
//
//    return assetsPath ;
//}
//
//
//
//@end
