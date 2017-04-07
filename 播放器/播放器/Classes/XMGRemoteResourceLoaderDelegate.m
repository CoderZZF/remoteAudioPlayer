//
//  XMGRemoteResourceLoaderDelegate.m
//  播放器
//
//  Created by zhangzhifu on 2017/4/6.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "XMGRemoteResourceLoaderDelegate.h"
#import "XMGRemoteAudioFile.h"
#import "XMGAudioDownloader.h"
#import "NSURL+ZZF.h"

@interface XMGRemoteResourceLoaderDelegate ()<XMGAudioDownloaderDelegate>
@property (nonatomic, strong) XMGAudioDownloader *downloader;
@property (nonatomic, strong) NSMutableArray *loadingRequests;
@end

@implementation XMGRemoteResourceLoaderDelegate

- (XMGAudioDownloader *)downloader {
    if (!_downloader) {
        _downloader = [[XMGAudioDownloader alloc] init];
        _downloader.delegate = self;
    }
    return _downloader;
}


- (NSMutableArray *)loadingRequests {
    if (!_downloader) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}


// 当外界需要播放一段音频资源时,会抛一个请求给这个对象,这个对象到时候只需要根据请求信息,抛数据给外界.
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
//    NSLog(@"%@", loadingRequest);
    
    // 1. 判断本地有没有该音频资源的缓存文件,如果有,直接根据本地缓存向外界响应数据(三个步骤) return
    NSURL *url = [loadingRequest.request.URL httpURL];
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
    
    if ([XMGRemoteAudioFile cacheFileExists:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    [self.loadingRequests addObject:loadingRequest];
    
    // 2. 判断有没有正在下载
    if (self.downloader.loadedSize == 0) {
        [self.downloader downloadWithURL:url offset:requestOffset];
        // 开始下载数据(根据请求的信息 url, requestOffset, requestLength)
        return YES;
    }
    
    // 3. 判断当前需要重新下载
    // 3.1 当资源请求的起始点 < 下载的开始点
    // 3.2 当资源的请求起始点 > 下载的开始点 + 下载的长度 + 666
    
    if (requestOffset < self.downloader.offset || requestOffset > (self.downloader.offset + self.downloader.loadedSize + 666)) {
        [self.downloader downloadWithURL:url offset:requestOffset];
        return YES;
    }
    
    // 开始处理资源请求(在现在过程当中也要不断的判断)
    [self handleAllLoadingRequest];
    
    return YES;
}


// 取消请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    [self.loadingRequests removeObject:loadingRequest];
    NSLog(@"取消某个请求");
}


- (void)downloading {
    [self handleAllLoadingRequest];
}

- (void)handleAllLoadingRequest {
    NSLog(@"在这里不断地处理请求数据");
    
    NSMutableArray *deleteRequest = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        // 1. 填充内容信息头
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.downloader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        
        NSString *contentType = self.downloader.mineType;
        loadingRequest.contentInformationRequest.contentType = contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // 2. 填充数据
        NSData *data = [NSData dataWithContentsOfFile:[XMGRemoteAudioFile tempFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        
        long long responseOffset = requestOffset - self.downloader.offset;
        long long responseLength = MIN(self.downloader.offset + self.downloader.loadedSize - requestOffset, requestLength);
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        [loadingRequest.dataRequest respondWithData:subData];
        
        // 3. 完成请求.(必须把所有关于这个请求区间的数据都返回完,之后才能完成这个请求)
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [deleteRequest addObject:loadingRequest];
        }
    }
    
    [self.loadingRequests removeObjectsInArray:deleteRequest];
}

#pragma mark - 私有方法
// 处理本地已经下载好的资源文件.
- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    // 1. 填充响应的信息头信息
    // 计算总大小
    
    NSURL *url = loadingRequest.request.URL;
    long long totalSize = [XMGRemoteAudioFile cacheFileSize:url];
    loadingRequest.contentInformationRequest.contentLength = totalSize;
    
    NSString *contentType = [XMGRemoteAudioFile contentType:url];
    loadingRequest.contentInformationRequest.contentType = contentType;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 2. 响应数据给外界
    NSData *data = [NSData dataWithContentsOfFile:[XMGRemoteAudioFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // 3. 完成本次请求(一旦所有的数据都给完了,才能调用完成请求方法)
    [loadingRequest finishLoading];
}
@end
