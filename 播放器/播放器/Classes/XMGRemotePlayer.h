//
//  XMGRemotePlayer.h
//  播放器
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGRemotePlayer : NSObject

+ (instancetype)sharedInstance;

- (void)playWithURL:(NSURL *)url;

- (void)pause;
- (void)resume;
- (void)stop;
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;
- (void)seekWithProgress:(float)progress;

- (void)setRate:(float)rate;
- (void)setMuted:(BOOL)muted;
- (void)setVolume:(float)volume;
@end
