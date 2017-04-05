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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)play:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"];
    [[XMGRemotePlayer sharedInstance] playWithURL:url];
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



@end
