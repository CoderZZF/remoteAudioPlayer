//
//  XMGAudioDownloader.m
//  播放器
//
//  Created by zhangzhifu on 2017/4/6.
//  Copyright © 2017年 seemygo. All rights reserved.
//  下载某一个区间的数据

#import "XMGAudioDownloader.h"
#import "XMGRemoteAudioFile.h"

@interface XMGAudioDownloader () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSURL *url;
@end

@implementation XMGAudioDownloader

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}


- (void)downloadWithURL:(NSURL *)url offset:(long long)offset {
    self.url = url;
    self.offset = offset;
    
    [self cancelAndClean];
    
    // 请求的是某一个区间的数据,range
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
}


- (void)cancelAndClean {
    // 取消
    [self.session invalidateAndCancel];
    self.session = nil;
    
    // 清空本地临时缓存
    [XMGRemoteAudioFile clearTempFile:self.url];
    
    // 重置数据
    self.loadedSize = 0;
}


#pragma mark - <NSURLSessionDataDelegate>
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    self.totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        self.totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    self.mineType = response.MIMEType;
    
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[XMGRemoteAudioFile tempFilePath:self.url] append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    self.loadedSize += data.length;
    [self.outputStream write:data.bytes maxLength:data.length];
    
    if ([self.delegate respondsToSelector:@selector(downloading)]) {
        [self.delegate downloading];
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error == nil) {
        NSURL *url = self.url;
        if ([XMGRemoteAudioFile tempFileSize:url] == self.totalSize) {
            // 移动文件: 临时文件夹 -> cache文件夹
            [XMGRemoteAudioFile moveTempPathToCachePath:url];
        }
    } else {
        NSLog(@"有错误");
    }
}



@end
