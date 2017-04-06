//
//  ViewController.m
//  播放器
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "ViewController.h"
#import "XMGRemotePlayer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *loadProgress;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation ViewController

- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self timer];
}

- (IBAction)play:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"];
    [[XMGRemotePlayer sharedInstance] playWithURL:url isCache:YES];
}
- (IBAction)pause:(id)sender {
    [[XMGRemotePlayer sharedInstance] pause];
}

- (IBAction)resume:(id)sender {
    [[XMGRemotePlayer sharedInstance] resume];
}

- (IBAction)kuaijin:(id)sender {
    [[XMGRemotePlayer sharedInstance] seekWithTimeDiffer:15];
}

- (IBAction)progress:(UISlider *)sender {
    [[XMGRemotePlayer sharedInstance] seekWithProgress:sender.value];
}

- (IBAction)rete:(id)sender {
    [[XMGRemotePlayer sharedInstance] setRate:2];
}

- (IBAction)muted:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [[XMGRemotePlayer sharedInstance] setMuted:sender.selected];
}

- (IBAction)volume:(UISlider *)sender {
    [[XMGRemotePlayer sharedInstance] setVolume:sender.value];
}

- (void)update {
//    NSLog(@"%zd", [XMGRemotePlayer sharedInstance].state);
    
    self.playTimeLabel.text = [[XMGRemotePlayer sharedInstance] currentTimeFormat];
    self.totalTimeLabel.text = [[XMGRemotePlayer sharedInstance] totalTimeFormat];
    self.playSlider.value = [[XMGRemotePlayer sharedInstance] progress];
    self.volumeSlider.value = [[XMGRemotePlayer sharedInstance] volume];
    self.loadProgress.progress = [[XMGRemotePlayer sharedInstance] loadDataProgress];
    self.muteBtn.selected = [[XMGRemotePlayer sharedInstance] muted];
}

@end
