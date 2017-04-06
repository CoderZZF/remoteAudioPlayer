//
//  XMGRemotePlayer.h
//  播放器
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 播放器的状态
 * 因为UI界面需要加载状态显示, 所以需要提供加载状态
 - XMGRemotePlayerStateUnknown: 未知(比如都没有开始播放音乐)
 - XMGRemotePlayerStateLoading: 正在加载()
 - XMGRemotePlayerStatePlaying: 正在播放
 - XMGRemotePlayerStateStopped: 停止
 - XMGRemotePlayerStatePause:   暂停
 - XMGRemotePlayerStateFailed:  失败(比如没有网络缓存失败, 地址找不到)
 */
typedef NS_ENUM(NSInteger, XMGRemotePlayerState) {
    XMGRemotePlayerStateUnknown = 0,
    XMGRemotePlayerStateLoading   = 1,
    XMGRemotePlayerStatePlaying   = 2,
    XMGRemotePlayerStateStopped   = 3,
    XMGRemotePlayerStatePause     = 4,
    XMGRemotePlayerStateFailed    = 5
};

@interface XMGRemotePlayer : NSObject

+ (instancetype)sharedInstance;

- (void)playWithURL:(NSURL *)url isCache:(BOOL)isCache;

- (void)pause;
- (void)resume;
- (void)stop;
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;
- (void)seekWithProgress:(float)progress;

//- (void)setRate:(float)rate;
//- (void)setMuted:(BOOL)muted;
//- (void)setVolume:(float)volume;

#pragma mark - 数据提供
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float rate;

@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
@property (nonatomic, copy, readonly) NSString *totalTimeFormat;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, copy, readonly) NSString *currentTimeFormat;
@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign, readonly) float loadDataProgress;
@property (nonatomic, assign, readonly) XMGRemotePlayerState state;
@end
