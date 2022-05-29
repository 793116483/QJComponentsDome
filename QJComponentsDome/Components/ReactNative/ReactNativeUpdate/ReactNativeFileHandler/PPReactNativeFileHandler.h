//
//  PPReactNativeFileHandler.h
//  ReactNativeDome
//
//  Created by 杰 on 2021/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPReactNativeFileHandler : NSObject

+(instancetype)shareHandler ;

-(NSString *)reactNativeRootPath ;

-(NSString *)downloadRootPath ;

/// 根据名字获取下载完资源的配制信息
-(NSDictionary *)downloadInfoPlistFileExistsWithName:(NSString *)fileName ;
/// 根据名字保存下载完资源的配制信息
-(BOOL)saveDownloadInfoPlist:(NSDictionary *)info fileName:(NSString *)fileName;
/// 移除下载完资源的配制信息
-(void)removeDownloadInfoPlist:(NSDictionary *)info ;
/// 获取所有的下载完资源的配制信息
-(NSArray<NSDictionary *> *)downloadInfoPlistArray ;


/// 查找文件夹下，带有suffix后缀的文件或文件夹
/// @param suffix 后缀名
/// @param isDirectory 需要查找的是不是文件夹，NO则是具体的文件
/// @param matchCase 后缀是否区分大小写
/// @param folderPath 文件夹相对路径
-(nullable NSString *)findPathWithSuffix:(NSString *)suffix isDirectory:(BOOL)isDirectory matchCase:(BOOL)matchCase folderPath:(NSString *)folderPath ;



#pragma mark 文件操作 , 所有的 path 都是相对路径
-(NSString *)absolutePath:(NSString *)path ;
-(BOOL)createFileIfNeedWithPath:(NSString *)path isDirectory:(BOOL)isDirectory;
-(BOOL)removeFileWithPath:(NSString *)path ;
-(BOOL)removeFileContentWithPath:(NSString *)path ;
-(BOOL)fileExistsAtPath:(NSString *)path ;
-(BOOL)fileExistsAtPath:(NSString *)path isDirectory:(nullable BOOL *)isDirectory;
-(NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path ;

/// 将文件或文件夹A 移动到 指定的 B文件夹下，返回的参数是移动失败的文件
/// @param fromPath 需要移动的文件或文件夹的相对路径
/// @param toFolderPath 目标文件夹的相对路径
/// @param isMoveContent 是否是移动fromPath文件夹的二级文件，还是移动fromPath本身；如果不是文件夹则不受该属性影响
/// @param overwrite 目标文件夹中如果存在同名的文件或文件夹是否替换
-(nullable NSArray<NSString *> *)moveItemAtPath:(NSString *)fromPath
                                   toFolderPath:(NSString *)toFolderPath
                                  isMoveContent:(BOOL)isMoveContent
                                      overwrite:(BOOL)overwrite;


@end


//判断字符串是否合法
static inline BOOL isValidString(NSString *s)
{
    return (s && [s isKindOfClass:[NSString class]] && [s length]>0)?YES:NO;
}

//判断Number是否合法
static inline BOOL isValidNumber(id n)
{
    return (n && [n isKindOfClass:[NSNumber class]])?YES:NO;
}

//判断字典是否合法
static inline BOOL isValidDictionary(NSDictionary *d)
{
    return (d && [d isKindOfClass:[NSDictionary class]])?YES:NO;
}

//判断数组是否合法
static inline BOOL isValidArray(NSArray *a)
{
    return (a && [a isKindOfClass:[NSArray class]])?YES:NO;
}

//格式化Number
static inline NSNumber * FormatNumber(NSObject *obj,id replaceNumber)
{
    NSNumber *result = replaceNumber;
    if (obj && (isValidString((NSString *)obj) || isValidNumber(obj))){
        result =  @([(NSString *)obj integerValue]);
    }
    return result;
}
NS_ASSUME_NONNULL_END
