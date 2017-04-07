//
//  XMGRemoteAudioFile.h
//  播放器
//
//  Created by zhangzhifu on 2017/4/6.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGRemoteAudioFile : NSObject

// 根据url获取缓存路径
+ (NSString *)cacheFilePath:(NSURL *)url;
+ (NSString *)tempFilePath:(NSURL *)url;


// 获取缓存文件大小
+ (long long)cacheFileSize:(NSURL *)url;
+ (long long)tempFileSize:(NSURL *)url;


// 判断缓存文件是否存在.
+ (BOOL)cacheFileExists:(NSURL *)url;
+ (BOOL)tempFileExists:(NSURL *)url;


+ (NSString *)contentType:(NSURL *)url;
+ (void)moveTempPathToCachePath:(NSURL *)url;
+ (void)clearTempFile:(NSURL *)url;
@end
