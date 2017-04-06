//
//  XMGRemotePlayer.m
//  播放器
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "XMGRemotePlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface XMGRemotePlayer ()
{
    BOOL _isUserPause;
}
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation XMGRemotePlayer

static XMGRemotePlayer *_sharedInstance;
+ (instancetype)sharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[XMGRemotePlayer alloc] init];
    }
    return _sharedInstance;
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedInstance = [super allocWithZone:zone];
        });
    }
    return _sharedInstance;
}

- (void)playWithURL:(NSURL *)url {
    NSURL *currentURL = [(AVURLAsset *)self.player.currentItem.asset URL];
    if ([url isEqual: currentURL]) {
        NSLog(@"当前播放任务已经存在了");
        [self resume];
        return;
    }
    
    _url = url;
    
    // 创建一个播放器对象
    // 这个方法已经帮我们封装了三个步骤
    // 1. 资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    
    // 移除监听者
    if (self.player.currentItem) {
        [self removeObserver];
    }
    
    // 2. 资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    // 当资源的组织者告诉我们资源加载完毕后,我们再播放
    // AVPlayerItemStatus status
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playIntrupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    
    // 3. 资源的播放
    self.player = [AVPlayer playerWithPlayerItem:item];
}


- (void)pause {
    [self.player pause];
    _isUserPause = YES;
    if (self.player) {
        self.state = XMGRemotePlayerStatePause;
    }
}

- (void)resume {
    [self.player play];
    _isUserPause = NO;
    // 当前播放器存在,并且数据组织者里面的数据准备已经足够播放了.
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        self.state = XMGRemotePlayerStatePlaying;
    }
}

- (void)stop {
    [self.player pause];
    self.player = nil;
    if (self.player) {
        self.state = XMGRemotePlayerStateStopped;
    }
}

- (void)seekWithProgress:(float)progress {
    if (progress < 0 || progress > 1) {
        return;
    }
    
    // 可以指定节点去播放
    // 时间是CMTime类型:影片时间
    // 1. 获取当前音频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTime);
    
    // 2. 获取当前音频资源已经播放的时长
    NSTimeInterval playTimeSec = totalTimeSec * progress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间节点的数据");
        } else {
            NSLog(@"取消加载这个时间节点的数据");
        }
    }];
}


- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer {
    // 1. 获取当前音频资源的总时长
    NSTimeInterval totalTimeSec = [self totalTime];
    
    // 2. 获取当前音频资源已经播放的时长
    NSTimeInterval playTimeSec = [self currentTime];
    playTimeSec += timeDiffer;
    
    [self seekWithProgress:playTimeSec / totalTimeSec];
}

- (void)setRate:(float)rate {
    [self.player setRate:rate];
}

- (float)rate {
    return self.player.rate;
}

- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (BOOL)muted {
    return self.player.muted;
}

- (void)setVolume:(float)volume {
    if (volume < 0 || volume > 1) {
        return;
    }
    if (volume > 0) {
        [self setMuted:NO];
    }
    
    self.player.volume = volume;
}

- (float)volume {
    return self.player.volume;
}


- (void)setState:(XMGRemotePlayerState)state {
    _state = state;
    
    // 如果需要告知外界相关事件,block,代理,通知
}

#pragma mark - 数据/事件
- (NSTimeInterval)totalTime {
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTime);
    if (isnan(totalTimeSec)) {
        return 0;
    }
    return totalTimeSec;
}


- (NSString *)totalTimeFormat {
    return [NSString stringWithFormat:@"%02zd:%02zd", (int)self.totalTime / 60, (int)self.totalTime % 60];
}

- (NSTimeInterval)currentTime {
    CMTime playTime = self.player.currentItem.currentTime;
    NSTimeInterval playTimeSec = CMTimeGetSeconds(playTime);
    if (isnan(playTimeSec)) {
        return 0;
    }
    return playTimeSec;
}


- (NSString *)currentTimeFormat {
    return [NSString stringWithFormat:@"%02zd:%02zd", (int)self.currentTime / 60, (int)self.currentTime % 60];
}

- (float)progress {
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime / self.totalTime;
}


- (float)loadDataProgress {
    if (self.totalTime == 0) {
        return 0;
    }
    
    CMTimeRange timeRange = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTime);
    
    return loadTimeSec / self.totalTime;
}


- (void)playEnd {
    NSLog(@"播放完成");
    self.state = XMGRemotePlayerStateStopped;
}


- (void)playIntrupt {
    NSLog(@"播放被打断");
    self.state = XMGRemotePlayerStatePause;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了,这时候可以播放");
            [self resume];
        } else {
            NSLog(@"状态未知");
            self.state = XMGRemotePlayerStateFailed;
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL playBackKeepUp = [change[NSKeyValueChangeNewKey] boolValue];
        if (playBackKeepUp) {
            NSLog(@"当前的资源准备得已经足够播放了");
            // 用户手动暂停的优先级是最高的.
            if (!_isUserPause) {
                [self resume];
            } else {
                
            }
            
        } else {
            NSLog(@"资源还不够,正在加载中...");
            self.state = XMGRemotePlayerStateLoading;
        }
    }
}


- (void)removeObserver {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}
@end
