//
//  XMGAudioDownloader.h
//  播放器
//
//  Created by zhangzhifu on 2017/4/6.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMGAudioDownloaderDelegate <NSObject>

- (void)downloading;

@end

@interface XMGAudioDownloader : NSObject
@property (nonatomic, weak) id<XMGAudioDownloaderDelegate> delegate;

@property (nonatomic, assign) long long totalSize;
@property (nonatomic, assign) long long loadedSize;
@property (nonatomic, assign) long long offset;
@property (nonatomic, strong) NSString *mineType;

- (void)downloadWithURL:(NSURL *)url offset:(long long)offset;

@end
