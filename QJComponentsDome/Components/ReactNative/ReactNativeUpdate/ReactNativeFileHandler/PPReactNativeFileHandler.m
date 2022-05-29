//
//  PPReactNativeFileHandler.m
//  ReactNativeDome
//
//  Created by 杰 on 2021/7/17.
//

#import "PPReactNativeFileHandler.h"
#import "SSZipArchive.h"

@implementation PPReactNativeFileHandler

+(instancetype)shareHandler {
    static dispatch_once_t onceToken;
    static PPReactNativeFileHandler * handler = nil ;
    dispatch_once(&onceToken, ^{
        handler = [[self alloc] init];
    });
    
    return handler;
}

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

-(NSString *)rootPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

-(NSString *)reactNativeRootPath {
    NSString * reactNativeRootFileName = @"ReactNativeRootFile" ;
    [self createFileIfNeedWithPath:reactNativeRootFileName isDirectory:YES];
    return reactNativeRootFileName;
}

-(NSString *)useForMoveTempRootPath {
    NSString * tempRootPath = [[self reactNativeRootPath] stringByAppendingPathComponent:@"useForMoveTempRootPath"];
    [self createFileIfNeedWithPath:tempRootPath isDirectory:YES];
    return tempRootPath;
}

-(NSString *)downloadRootPath {
    NSString * downloadFile = [[self reactNativeRootPath] stringByAppendingPathComponent:@"downloadRootFile"];
    [self createFileIfNeedWithPath:downloadFile isDirectory:YES];
    return downloadFile;
}

/// 下载完的资源对应 info.plist 都存放在这里
-(NSString *)downloadInfoPlistRootPath {
    NSString * downloadInfoPlist = [[self downloadRootPath] stringByAppendingPathComponent:@"downloadInfoPlistRootFile"];
    [self createFileIfNeedWithPath:downloadInfoPlist isDirectory:YES];
    return downloadInfoPlist;
}

-(NSDictionary *)downloadInfoPlistFileExistsWithName:(NSString *)fileName{
    NSString * infoPath = [[self downloadInfoPlistRootPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    NSDictionary * downloadInfo = nil ;
    if ([self fileExistsAtPath:infoPath]) {
        downloadInfo = [NSDictionary dictionaryWithContentsOfFile:[self absolutePath:infoPath]];
    }
    return downloadInfo;
}

NSString * kDownloadInfoPlistPathKey = @"kDownloadInfoPlistPathKey";
-(BOOL)saveDownloadInfoPlist:(NSDictionary *)info fileName:(nonnull NSString *)fileName{
    if (!isValidDictionary(info) || !info.allKeys.count || !isValidString(fileName)) {return NO;}
    
    NSString * infoPath = [[self downloadInfoPlistRootPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    if ([self createFileIfNeedWithPath:infoPath isDirectory:NO]) {
        // 路径保存 plist 中
        NSMutableDictionary * plist = [NSMutableDictionary dictionaryWithDictionary:info];
        [plist setObject:infoPath forKey:kDownloadInfoPlistPathKey];
        
        return [plist writeToFile:[self absolutePath:infoPath] atomically:YES];
    }
    return NO;
}
-(void)removeDownloadInfoPlist:(NSDictionary *)info {
    if (!isValidDictionary(info) || !info.allKeys.count || !isValidString(info[kDownloadInfoPlistPathKey])) {return;}
    
    [self removeFileWithPath:info[kDownloadInfoPlistPathKey]];
}

-(NSArray<NSDictionary *> *)downloadInfoPlistArray {
    NSMutableArray * infoPlistArray = [NSMutableArray array];
    NSArray<NSString *> * directoryArr = [self contentsOfDirectoryAtPath:[self downloadInfoPlistRootPath]];
    for (NSString * infoPlistPath in directoryArr) {
        if ([infoPlistPath hasSuffix:@".plist"]) { // 有该后缀
            NSDictionary * infoPlist = [NSDictionary dictionaryWithContentsOfFile:[self absolutePath:infoPlistPath]];
            if (isValidDictionary(infoPlist)) {
                [infoPlistArray addObject:infoPlist];
            }
        }
    }
    
    return infoPlistArray.copy;
}

-(NSString *)findPathWithSuffix:(NSString *)suffix isDirectory:(BOOL)isAnDirectory matchCase:(BOOL)matchCase folderPath:(nonnull NSString *)folderPath {
    
    if (!isValidString(suffix)) {
        return nil;
    }
    
    NSArray<NSString *> * directoryArr = [self contentsOfDirectoryAtPath:folderPath];
    NSMutableArray<NSString *> *folderPaths = [NSMutableArray array];
    BOOL isDirectory;
    for (NSString * filePath in directoryArr) {
        if ([self fileExistsAtPath:filePath isDirectory:&isDirectory]) {
            
            NSString * path = matchCase ? filePath : [filePath lowercaseString] ;
            if ([path hasSuffix:suffix] && isDirectory == isAnDirectory) { // 有该后缀
                return filePath;
            }
            
            if (isDirectory) {
                [folderPaths addObject:filePath];
            }
        }
    }
    
    for (NSString * filePath in folderPaths) {
        NSString * path = [self findPathWithSuffix:suffix isDirectory:isAnDirectory matchCase:matchCase folderPath:filePath];
        if (isValidString(path)) {
            return path;
        }
    }
    
    return nil;
}

#pragma mark 文件操作

-(NSString *)absolutePath:(NSString *)path {
    if (!isValidString(path)) {
        return nil;
    }
    return [path hasPrefix:@"/"] ? [[self rootPath] stringByAppendingString:path] : [[self rootPath] stringByAppendingPathComponent:path];
}

-(BOOL)createFileIfNeedWithPath:(NSString *)path isDirectory:(BOOL)isDirectory{
    if (!isValidString(path)) {
        return NO;
    }
    
    BOOL isDirectoryForPath ;
    if ([self fileExistsAtPath:path isDirectory:&isDirectoryForPath] && isDirectoryForPath == isDirectory) {
        return YES;
    }
    
    BOOL isSuccess;
    
    if (isDirectory) {
        isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:[self absolutePath:path] withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        isSuccess = [[NSFileManager defaultManager] createFileAtPath:[self absolutePath:path] contents:nil attributes:nil];
    }
    return isSuccess;
}

-(BOOL)removeFileWithPath:(NSString *)path {
    if (!isValidString(path) || ![self fileExistsAtPath:path]) {
        return YES ;
    }
    return [[NSFileManager defaultManager] removeItemAtPath:[self absolutePath:path] error:nil];
}

-(BOOL)removeFileContentWithPath:(NSString *)path {
    
    [[self contentsOfDirectoryAtPath:path] enumerateObjectsUsingBlock:^(NSString * _Nonnull filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeFileWithPath:filePath];
    }];
    return YES;
}

-(BOOL)fileExistsAtPath:(NSString *)path {
    if (!isValidString(path)) {
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:[self absolutePath:path]];
}

-(BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
    if (!isValidString(path)) {
        *isDirectory = NO ;
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:[self absolutePath:path] isDirectory:isDirectory];
}

-(NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path {
    
    BOOL isDirectory = NO ;
    if (!isValidString(path) || ![self fileExistsAtPath:path isDirectory:&isDirectory]) {
        return @[];
    }
    
    // 如果不是文件夹
    if (!isDirectory) {
        return @[path];
    }
    
    NSMutableArray * fileArray = [NSMutableArray array];
    NSArray<NSString *> * directoryArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self absolutePath:path] error:nil];
    for (NSString * file in directoryArr) {
        [fileArray addObject:[path stringByAppendingPathComponent:file]];
    }
    return fileArray.copy;
}

-(NSArray<NSString *> *)moveItemAtPath:(NSString *)fromPath
                          toFolderPath:(NSString *)toFolderPath
                         isMoveContent:(BOOL)isMoveContent
                             overwrite:(BOOL)overwrite
{
    if (!isValidString(fromPath) || ![self fileExistsAtPath:fromPath]) {
        return nil;
    }
    if (!isValidString(toFolderPath)) {
        return @[fromPath];
    }
    
    NSArray<NSString *> * paths = isMoveContent ? [self contentsOfDirectoryAtPath:fromPath] : @[fromPath] ;
    
    // 如果目标文件夹不存在，则创建文件夹
    [self createFileIfNeedWithPath:toFolderPath isDirectory:YES] ;
    // 清理临时存放目录
    [self removeFileContentWithPath:[self useForMoveTempRootPath]];
    
    // 开始移动数据
    NSMutableArray<NSString *> * moveFailPaths = [NSMutableArray array];
    for (NSString * filePath in paths) {
        
        NSString * lastPathComponent = [filePath lastPathComponent] ;
        NSString * toFilePath = [toFolderPath stringByAppendingPathComponent:lastPathComponent] ;
        
        // 根据参数，决定是否移除目标文件夹下同名
        NSString * oldFilePath = nil ;
        if (overwrite && [self fileExistsAtPath:toFilePath]) {
            
            NSString * oldFileNewPath = [[self useForMoveTempRootPath] stringByAppendingPathComponent:lastPathComponent] ;
            
            if ([[NSFileManager defaultManager] moveItemAtPath:[self absolutePath:toFilePath] toPath:[self absolutePath:oldFileNewPath] error:nil]) {
                // 移动成功后，变更旧文件路径
                oldFilePath = oldFileNewPath;
            }
        }
        
        // 移动文件
        NSError * err ;
        if (![[NSFileManager defaultManager] moveItemAtPath:[self absolutePath:filePath] toPath:[self absolutePath:toFilePath] error:&err]) {
            // 新文件移动失败
            [moveFailPaths addObject:filePath];
            
            // 恢复旧数据
            if (oldFilePath) {
                [[NSFileManager defaultManager] moveItemAtPath:[self absolutePath:oldFilePath] toPath:[self absolutePath:toFilePath] error:nil] ;
            }
        }
    }
    
    // 清理临时存放目录
    [self removeFileWithPath:[self useForMoveTempRootPath]];
    
    return moveFailPaths.count > 0 ? moveFailPaths : nil;
}

@end
