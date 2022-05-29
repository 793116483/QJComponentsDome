////
////  PPReactNativeInfoManager.m
////  ReactNativeDome
////
////  Created by 杰 on 2021/7/19.
////
//
//#import "PPReactNativeInfoManager.h"
//#import "PPReactNativeFileHandler.h"
//#import <React/RCTRootView.h>
//#import "SSZipArchive.h"
//#import "DiffMatchPatch.h"
//#import <React/RCTBundleURLProvider.h>
//#import <UMReactNativeAdapter/UMModuleRegistryAdapter.h>
//#import <React/RCTReloadCommand.h>
//#import <React/RCTI18nUtil.h>
//
//NS_ASSUME_NONNULL_BEGIN
//static NSString * kLocationConfigInfoPlistName = @"reactConfigInfo.plist" ; // bundle.zip 内的 rn 配制文件名
//static NSString * kLocationBundleZipName = @"bundle.zip" ;      // 工程引用的 RN 信息压缩包名
//static NSString * kLocationJsbundleSuffixName = @".jsbundle" ;  // 全量包的后缀名
//static NSString * kLocationAssetsName = @"assets" ;             // 全量包的图片资源图片文件夹名
//
//static NSString * kReactNativeInfoPlistName = @"reactNativeInfo.plist" ; // rn 配制文件名
//
//static const NSString * kReactNativeMinVersionKey = @"ReactNativeMinVersionKey" ; // rn 在工程info.plist的最小版本号
//static const NSString * kReactNativeVersionKey = @"ReactNativeVersionKey" ; // rn 的版本号
//
//@interface PPReactNativeInfoManager ()
//// 提前加载好
//@property (nonatomic, strong) UMModuleRegistryAdapter *moduleRegistryAdapter;
//
//@end
//
//@implementation PPReactNativeInfoManager
//
//+(instancetype)shareManager {
//    static dispatch_once_t onceToken;
//    static PPReactNativeInfoManager * manager = nil ;
//    dispatch_once(&onceToken, ^{
//        manager = [[self alloc] init];
//    });
//    return manager;
//}
//
//-(instancetype)init {
//    if (self = [super init]) {
//        [self updateJsbundleIfNeed];
//    }
//    return self;
//}
//
//-(RCTBridge *)rnBridge {
//    // 判断jsbundle是否存在
//    if (![PPReactNativeFileHandler.shareHandler fileExistsAtPath:[self findJsbundlePath]]) {
//        _rnBridge = nil;
//    }else if (_rnBridge == nil) {
//        [self initRnBridge:nil];
//    }
//    return _rnBridge;
//}
//
//- (void)initRnBridge:(nullable NSDictionary *)launchOptions
//{
//    // 判断jsbundle是否存在
//    if (![PPReactNativeFileHandler.shareHandler fileExistsAtPath:[self findJsbundlePath]]) {
//        _rnBridge = nil ;
//        return;
//    }
//    self.moduleRegistryAdapter = [[UMModuleRegistryAdapter alloc] initWithModuleRegistryProvider:[[UMModuleRegistryProvider alloc] init]];
//    self.rnBridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
//}
//
//#pragma mark - RCTBridgeDelegate
//- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge
//{
//    NSArray<id<RCTBridgeModule>> *extraModules = [self.moduleRegistryAdapter extraModulesForBridge:bridge];
//        // If you'd like to export some custom RCTBridgeModules that are not Expo modules, add them here!
//    return extraModules;
//}
//
//
//- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
//{
////// v7.6 longchi need delete
////#if defined(DEBUG) || defined(ADHOC)
//////    return [NSURL URLWithString:@"http://172.16.13.12:8081/index.bundle?platform=ios&dev=true"];
////    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
////#endif
//    return [self jsbundlePathURL];
//}
//
//#pragma mark - getter 信息
//
//-(NSString *)jsbundleFileRootPath {
//    NSString * jsbundleFile = [[PPReactNativeFileHandler.shareHandler reactNativeRootPath] stringByAppendingPathComponent:@"jsbundleRootFile"];
//    [PPReactNativeFileHandler.shareHandler createFileIfNeedWithPath:jsbundleFile isDirectory:YES];
//    return jsbundleFile;
//}
//
//-(NSString *)jsbundleFileTempPath {
//    NSString * jsbundleFileTempPath = [[PPReactNativeFileHandler.shareHandler reactNativeRootPath] stringByAppendingPathComponent:@"jsbundleFileTempPath"];
//    [PPReactNativeFileHandler.shareHandler createFileIfNeedWithPath:jsbundleFileTempPath isDirectory:YES];
//    return jsbundleFileTempPath;
//}
//
//-(NSURL *)jsbundlePathURL {
//    NSString * jsbundleAbsolutePath = [PPReactNativeFileHandler.shareHandler absolutePath:[self findJsbundlePath]];
//    return isValidString(jsbundleAbsolutePath) ? [NSURL fileURLWithPath:jsbundleAbsolutePath] : nil ;
//}
//
//-(NSString *)reactNativeInfoPlistPath {
//    NSString * reactNativeInfoPath = [[self jsbundleFileRootPath] stringByAppendingPathComponent:kReactNativeInfoPlistName];
//
//    if (![PPReactNativeFileHandler.shareHandler fileExistsAtPath:reactNativeInfoPath]) {
//        // 创建.plist文件
//        [PPReactNativeFileHandler.shareHandler createFileIfNeedWithPath:reactNativeInfoPath isDirectory:NO];
//    }
//
//    return reactNativeInfoPath;
//}
//
//-(NSDictionary *)reactConfigInfoDictionry {
//    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kLocationConfigInfoPlistName ofType:nil]];
//}
//
//// 沙盒中的 rn 配制文件
//-(NSDictionary *)reactNativeInfoDic{
//    return [NSDictionary dictionaryWithContentsOfFile:[PPReactNativeFileHandler.shareHandler absolutePath:[self reactNativeInfoPlistPath]]];
//}
//
//-(NSString *)getReactNativeVersion {
//    // 读取APP配制的最小版本号
//    NSDictionary * locationInfo = [self reactConfigInfoDictionry] ;
//    NSString * minVersion = [NSString stringWithFormat:@"%@",[locationInfo objectForKey:kReactNativeMinVersionKey]];
//
//    NSDictionary * info = [self reactNativeInfoDic];
//    NSString * version = info[kReactNativeVersionKey] ;
//    return FormatString(version, minVersion);
//}
//
//-(NSString *)findJsbundlePath {
//    return [PPReactNativeFileHandler.shareHandler findPathWithSuffix:kLocationJsbundleSuffixName isDirectory:NO matchCase:NO folderPath:[self jsbundleFileRootPath]];
//}
//
//-(nullable NSString *)findSaveJsbundleFileFolderPath:(NSString *)path {
//    // 查找解压后 .jsbundle 文件
//    NSString * jsbundleFilePath = [PPReactNativeFileHandler.shareHandler findPathWithSuffix:kLocationJsbundleSuffixName isDirectory:NO matchCase:NO folderPath:path];
//    BOOL isDirectory = NO ;
//    if (![PPReactNativeFileHandler.shareHandler fileExistsAtPath:jsbundleFilePath isDirectory:&isDirectory] || isDirectory) {
//        // 找不到或是文件夹
//        return nil;
//    }
//
//    // 存放.jsbundle 文件 的文件夹
//    NSString * folderPath = [jsbundleFilePath stringByReplacingOccurrencesOfString:[@"/" stringByAppendingString:jsbundleFilePath.lastPathComponent] withString:@""];
//
//    return folderPath;
//}
//
//- (void)reloadBridge
//{
//    if (_rnBridge) {
//        if ([PPSystemConfigUtils isCanRightToLeftShow]) {
//            [[RCTI18nUtil sharedInstance] forceRTL:YES];
//        }else {
//            [[RCTI18nUtil sharedInstance] forceRTL:NO];
//        }
//    }
//}
//
//#pragma mark - 操作 信息
//-(void)updateJsbundleIfNeed {
//
//    // 读取APP配制的最小版本号
//    NSDictionary * info = [self reactConfigInfoDictionry] ;
//    NSString * minVersion = [NSString stringWithFormat:@"%@",[info objectForKey:kReactNativeMinVersionKey]];
//
//    // 读取沙盒中当前的版本号
//    NSDictionary * currInfo = [self reactNativeInfoDic];
//    NSString * version = [currInfo objectForKey:kReactNativeVersionKey];
//
//    // 根据工程文件，替换沙盒资源 和 设置 rn 版本号
//    if (!isValidString(version) || [minVersion floatValue] > [version floatValue] ||
//        ![self findJsbundlePath]) {
//
//        PPReactNativeFileHandler * fileHandler = [PPReactNativeFileHandler shareHandler];
//
//        // 清除 jsbundleFileTempPath 文件夹旧数据
//        [fileHandler removeFileContentWithPath:[self jsbundleFileTempPath]];
//
//        // 工程引用的资源 bundle.zip 绝对路径
//        NSString * fromPath = [[NSBundle mainBundle] pathForResource:kLocationBundleZipName ofType:nil];
//
//        // 重新创建 jsbundleFileTempPath 文件夹
//        NSString * jsbundleFileTempPath = [self jsbundleFileTempPath] ;
//
//        // 解压 bundle.zip 到 downloadRootPath 文件夹下
//        BOOL success = [SSZipArchive unzipFileAtPath:fromPath toDestination:[fileHandler absolutePath:jsbundleFileTempPath]];
//
//        // 解压成功,更新文件
//        if (success) {
//            [self updateJSBundleWithFromPath:jsbundleFileTempPath newVersion:minVersion];
//        }
//
//        // 移除 jsbundleFileTempPath 文件夹
//        [fileHandler removeFileWithPath:jsbundleFileTempPath];
//    }
//        [self initRnBridge:self.rnBridge.launchOptions];
//}
//
//-(BOOL)updateJSBundleWithFromPath:(NSString *)path newVersion:(NSString *)newVersion{
//
//    // 存放.jsbundle 文件 的文件夹
//    NSString * folderPath = [self findSaveJsbundleFileFolderPath:path];
//    if (!isValidString(folderPath)) {
//        return NO;
//    }
//
//    // 删除存放旧 jsbundle 的 文件夹
//    [PPReactNativeFileHandler.shareHandler removeFileContentWithPath:[self jsbundleFileRootPath]];
//
//    // 将解压后的所有资源 移动到 jsbundleFileRootPath 文件夹
//    [[PPReactNativeFileHandler shareHandler] moveItemAtPath:folderPath toFolderPath:[self jsbundleFileRootPath] isMoveContent:YES overwrite:YES];
//
//    // 重制 rnBridge
//    [self initRnBridge:self.rnBridge.launchOptions];
//
//    // 更新对应的配制 info.plist
//    return [self updateReactNativeVersion:newVersion];
//
//}
//
//-(BOOL)updateReactNativeVersion:(NSString *)version {
//    if (![version isKindOfClass:[NSString class]] || version.length <= 0) {return NO;}
//
//    return [@{kReactNativeVersionKey:version} writeToFile:[PPReactNativeFileHandler.shareHandler absolutePath:[self reactNativeInfoPlistPath]] atomically:YES];
//}
//
//-(BOOL)allowUpdateWithVersion:(NSString *)version{
//    if (!isValidString(version) && !isValidNumber(version)) {
//        // 无效版本不允许更新
//        return NO;
//    }
//
//    version = [NSString stringWithFormat:@"%@",version];
//    NSString * rnVersion = [self getReactNativeVersion];
//
//    // 如果 本地版本 >= version 则不允许更新
//    if ([rnVersion floatValue] >= [version floatValue]) {
//        return NO;
//    }
//
//    // 比较大版本是否一样，不一样也是不允许更新
//    NSArray * versions = [version componentsSeparatedByString:@"."];
//    NSArray * rnVersions = [rnVersion componentsSeparatedByString:@"."];
//
//    return [versions.firstObject isEqualToString:rnVersions.firstObject];
//}
//
//-(void)forceReplaceByAppLocationFullPackage {
//    // 读取APP配制的最小版本号
//    NSDictionary * info = [self reactConfigInfoDictionry] ;
//    NSString * minVersion = [NSString stringWithFormat:@"%@",[info objectForKey:kReactNativeMinVersionKey]];
//
//    // 读取沙盒中当前的版本号
//    NSDictionary * currInfo = [self reactNativeInfoDic];
//    NSString * version = [currInfo objectForKey:kReactNativeVersionKey];
//
//    // 对比沙盒资源内版本 与 配制的rn版本号 是否相同，相同表示已经是APP的本地全量包就不需处理，否则处理
//    if (isValidString(version) && [minVersion isEqualToString:version] && [self findJsbundlePath]) {
//        return;
//    }
//
//    // 删除存放旧 jsbundle 的 文件夹
//    [PPReactNativeFileHandler.shareHandler removeFileContentWithPath:[self jsbundleFileRootPath]];
//
//    // 更新
//    [self updateJsbundleIfNeed];
//}
//
//-(void)updateJsBundleWithUpateInfoMode:(PPReactNativeUpdateInfo *)updateInfoMode{
//    if (!updateInfoMode) {
//        return;
//    }
//
//    if (updateInfoMode.isFullPackage) {
//        [self fullPackageUpdate:updateInfoMode];
//    }else{
//        [self differencePackageUpdate:updateInfoMode];
//    }
//}
//#pragma mark - 全量包更新
//-(void)fullPackageUpdate:(PPReactNativeUpdateInfo *)updateInfoMode{
//
//    // 是否可以更新该版本
//    if (![self allowUpdateWithVersion:updateInfoMode.updateVersion]) {
//        if (updateInfoMode.updateCompletion) {
//            updateInfoMode.updateCompletion(NO);
//        }
//        return;
//    }
//
//    // 更新 Assets 图片资源
//    // 将解压后的所有资源 移动到 jsbundleFileRootPath 文件夹
//    BOOL updateAssets = [[PPReactNativeFileHandler shareHandler] moveItemAtPath:updateInfoMode.updateImageAssetsPath toFolderPath:[self jsbundleFileRootPath] isMoveContent:NO overwrite:YES].count == 0;
//    if (!updateAssets) {
//        if (updateInfoMode.updateCompletion) {
//            updateInfoMode.updateCompletion(NO);
//        }
//        return;
//    }
//
//    // 更新 .jsbundle
//    BOOL updateJsbundle = [[PPReactNativeFileHandler shareHandler] moveItemAtPath:updateInfoMode.updateJsbundleNeedPath toFolderPath:[self jsbundleFileRootPath] isMoveContent:NO overwrite:YES].count == 0;
//    if (!updateJsbundle) {
//        if (updateInfoMode.updateCompletion) {
//            updateInfoMode.updateCompletion(NO);
//        }
//        return;
//    }
//
//    // 更新 version 版本配制
//    BOOL updateVersion = [self updateReactNativeVersion:updateInfoMode.updateVersion] ;
//    if (updateInfoMode.updateCompletion) {
//        updateInfoMode.updateCompletion(updateVersion);
//    }
//    [self initRnBridge:self.rnBridge.launchOptions];
//}
//
//#pragma mark - 差量包更新
//-(void)differencePackageUpdate:(PPReactNativeUpdateInfo *)updateInfoMode {
//    // 是否可以更新该版本
//    if (![self allowUpdateWithVersion:updateInfoMode.updateVersion]) {
//        if (updateInfoMode.updateCompletion) {
//            updateInfoMode.updateCompletion(NO);
//        }
//        return;
//    }
//
//    // 更新 Assets 图片资源
//    NSString * assetsPath = [[self findSaveJsbundleFileFolderPath:[self jsbundleFileRootPath]] stringByAppendingPathComponent:kLocationAssetsName];
//    if (![self moveAssetsWithPath:updateInfoMode.updateImageAssetsPath toPath:assetsPath]) {
//        if (updateInfoMode.updateCompletion) {
//            updateInfoMode.updateCompletion(NO);
//        }
//        return;
//    }
//
//    // 差量更新 .jsbundle
//    BOOL updateJsbundle = [self differencePackageUpdateWithPatPath:updateInfoMode.updateJsbundleNeedPath];
//    if (!updateJsbundle) {
//        if (updateInfoMode.updateCompletion) {
//            updateInfoMode.updateCompletion(NO);
//        }
//        return;
//    }
//
//    // 更新 version 版本配制
//    BOOL updateVersion = [self updateReactNativeVersion:updateInfoMode.updateVersion] ;
//    if (updateInfoMode.updateCompletion) {
//        updateInfoMode.updateCompletion(updateVersion);
//    }
//
//    [self initRnBridge:self.rnBridge.launchOptions];
//}
//
//-(BOOL)moveAssetsWithPath:(NSString *)path toPath:(NSString *)toPath{
//    PPReactNativeFileHandler * fileHandler = [PPReactNativeFileHandler shareHandler] ;
//    NSArray * contentPaths = [fileHandler contentsOfDirectoryAtPath:path];
//    BOOL isDirectory = NO;
//
//    // 如果 toPath 文件夹不存在，则创建
//    [fileHandler createFileIfNeedWithPath:toPath isDirectory:YES];
//
//    for (NSString * file in contentPaths) {
//        [fileHandler fileExistsAtPath:file isDirectory:&isDirectory];
//        if (isDirectory) {
//            NSString * lastPathName = file.lastPathComponent ;
//            NSString * toFilePath = [toPath stringByAppendingPathComponent:lastPathName];
//            // 递归移动文件夹的内容
//            if (![self moveAssetsWithPath:file toPath:toFilePath]) {
//                return NO;
//            }
//        }else{
//            // 如果是文件，则直接移动
//            if ([fileHandler moveItemAtPath:file toFolderPath:toPath isMoveContent:NO overwrite:YES].count > 0) {
//                return NO;
//            }
//        }
//    }
//
//    return YES;
//}
//
//-(BOOL)differencePackageUpdateWithPatPath:(NSString *)patPath {
//    PPReactNativeFileHandler * fileHandler = [PPReactNativeFileHandler shareHandler] ;
//    // 获取本地正式的
//    NSString * jsbundlePath = [self findJsbundlePath];
//    if (![fileHandler fileExistsAtPath:patPath] || ![fileHandler fileExistsAtPath:jsbundlePath]) {
//        return NO;
//    }
//
//    NSURL * patchsURL = [NSURL fileURLWithPath:[fileHandler absolutePath:patPath]] ;
//    NSURL * oldJsBundleURL = [NSURL fileURLWithPath:[fileHandler absolutePath:jsbundlePath]] ;
//
//    NSString * patchsContent = [NSString stringWithContentsOfURL:patchsURL encoding:NSUTF8StringEncoding error:nil];
//    NSString * oldJsBundleContent = [NSString stringWithContentsOfURL:oldJsBundleURL encoding:NSUTF8StringEncoding error:nil];
//
//    DiffMatchPatch * patchMatch = [[DiffMatchPatch alloc] init];
//    NSArray * newArr = [patchMatch patch_apply:[patchMatch patch_fromText:patchsContent error:nil] toString:oldJsBundleContent];
//
//    //写入到新文件
//    BOOL isSuccess = NO ;
//    if (newArr.count > 0) {
//        isSuccess = [newArr[0] writeToURL:oldJsBundleURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    }
//
//    return isSuccess;
//}
//
//@end
//
//
//
//@implementation PPReactNativeUpdateInfo
//@synthesize isFullPackage = _isFullPackage ;
//@synthesize updateVersion = _updateVersion ;
//@synthesize updateJsbundleNeedPath = _updateJsbundleNeedPath ;
//@synthesize updateImageAssetsPath = _updateImageAssetsPath ;
//@synthesize updateCompletion = _updateCompletion ;
//
//+(nullable instancetype)updateInfoWithFullPackage:(BOOL)isFullPackage
//                           updateVersion:(NSString *)updateVersion
//                           updateJsbundleNeedPath:(nullable NSString *)updateJsbundleNeedPath
//                            updateImageAssetsPath:(nullable NSString *)updateImageAssetsPath
//                                 updateCompletion:(nonnull void (^)(BOOL))updateCompletion {
//    // 版本号无效时
//    if (!isValidString(updateVersion) && !isValidNumber(updateVersion)) {
//        return nil;
//    }
//    // 更新jsbundle需要的资源不存在时
//    BOOL isDirectory ;
//    if (![PPReactNativeFileHandler.shareHandler fileExistsAtPath:updateJsbundleNeedPath isDirectory:&isDirectory] || isDirectory) {
//        return nil;
//    }
//
//    return [[self alloc] initWithFullPackage:isFullPackage
//                               updateVersion:updateVersion
//                      updateJsbundleNeedPath:updateJsbundleNeedPath
//                       updateImageAssetsPath:updateImageAssetsPath
//                            updateCompletion:updateCompletion];
//}
//
//-(nullable instancetype)initWithFullPackage:(BOOL)isFullPackage
//                           updateVersion:(NSString *)updateVersion
//                  updateJsbundleNeedPath:(NSString *)updateJsbundleNeedPath
//                   updateImageAssetsPath:(NSString *)updateImageAssetsPath
//                        updateCompletion:(void (^)(BOOL))updateCompletion {
//
//    if (self = [super init]) {
//        _isFullPackage = isFullPackage ;
//        _updateVersion = FormatString(updateVersion, @"").copy ;
//        _updateJsbundleNeedPath = updateJsbundleNeedPath.copy ;
//        _updateImageAssetsPath = updateImageAssetsPath.copy ;
//        _updateCompletion = [updateCompletion copy];
//    }
//    return self;
//}
//
//@end
//
//
//NS_ASSUME_NONNULL_END
