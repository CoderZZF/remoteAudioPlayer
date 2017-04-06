//
//  XMGRemoteResourceLoaderDelegate.m
//  播放器
//
//  Created by zhangzhifu on 2017/4/6.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "XMGRemoteResourceLoaderDelegate.h"

@implementation XMGRemoteResourceLoaderDelegate

// 当外界需要播放一段音频资源时,会抛一个请求给这个对象,这个对象到时候只需要根据请求信息,抛数据给外界.
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"%@", loadingRequest);
    
    // 如何根据请求信息,返回给外界数据
    
    // 1. 填充响应的信息头信息
    loadingRequest.contentInformationRequest.contentLength = 4093201;
    loadingRequest.contentInformationRequest.contentType = @"public.mp3";
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 2. 响应数据给外界
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/zhangzhifu/Desktop/235319.mp3" options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // 3. 完成本次请求(一旦所有的数据都给完了,才能调用完成请求方法)
    [loadingRequest finishLoading];
    
    return YES;
}


// 取消请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    NSLog(@"取消某个请求");
}
@end
