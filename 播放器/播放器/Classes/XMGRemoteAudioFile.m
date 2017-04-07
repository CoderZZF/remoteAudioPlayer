//
//  XMGRemoteAudioFile.m
//  播放器
//
//  Created by zhangzhifu on 2017/4/6.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "XMGRemoteAudioFile.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTempPath NSTemporaryDirectory()

@implementation XMGRemoteAudioFile

// 下载完成,cache + 文件名称
+ (NSString *)cacheFilePath:(NSURL *)url {
    return [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (NSString *)tempFilePath:(NSURL *)url {
    return [kTempPath stringByAppendingPathComponent:url.lastPathComponent];
}



+ (long long)cacheFileSize:(NSURL *)url {
    if (![self cacheFileExists:url]) {
        return 0;
    }
    
    // 1.1 获取文件路径
    NSString *path = [self cacheFilePath:url];
    
    // 1.2 计算文件路径对应的文件大小
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [fileInfoDic[NSFileSize] longLongValue];
}

+ (long long)tempFileSize:(NSURL *)url {
    if (![self tempFileExists:url]) {
        return 0;
    }
    
    // 1.1 获取文件路径
    NSString *path = [self tempFilePath:url];
    
    // 1.2 计算文件路径对应的文件大小
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [fileInfoDic[NSFileSize] longLongValue];
}



// 下载中,temp + 文件名称

+ (BOOL)cacheFileExists:(NSURL *)url {
    NSString *path = [self cacheFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)tempFileExists:(NSURL *)url {
    NSString *path = [self tempFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}



+ (NSString *)contentType:(NSURL *)url {
    NSString *path = [self cacheFilePath:url];
    NSString *fileExtesnsion = path.pathExtension;
    
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtesnsion), NULL);
    
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    
    return contentType;
}


+ (void)moveTempPathToCachePath:(NSURL *)url {
    NSString *tempPath = [self tempFilePath:url];
    NSString *cachePath = [self cacheFilePath:url];
    [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:cachePath error:nil];
}

+ (void)clearTempFile:(NSURL *)url {
    NSString *tempPath = [self tempFilePath:url];
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
}
@end
