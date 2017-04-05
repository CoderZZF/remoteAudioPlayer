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
    _url = url;
    
    // 创建一个播放器对象
    // 这个方法已经帮我们封装了三个步骤
    // 1. 资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    
    // 2. 资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    // 当资源的组织者告诉我们资源加载完毕后,我们再播放
    // AVPlayerItemStatus status
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 3. 资源的播放
    // 如果资源的加载比较慢,就可能出现调用play方法,但是当前并没有音频播放
    self.player = [AVPlayer playerWithPlayerItem:item];
}


- (void)pause {
    [self.player pause];
}

- (void)resume {
    [self.player play];
}

- (void)stop {
    [self.player pause];
    self.player = nil;
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


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了,这时候可以播放");
            [self.player play];
        } else {
            NSLog(@"状态未知");
        }
    }
}


- (void)dealloc {
     [self.player removeObserver:self forKeyPath:@"status"];
}
@end
