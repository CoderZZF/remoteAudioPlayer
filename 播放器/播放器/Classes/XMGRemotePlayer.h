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
@end
