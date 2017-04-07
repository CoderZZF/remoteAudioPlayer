//
//  NSURL+ZZF.m
//  播放器
//
//  Created by zhangzhifu on 2017/4/6.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "NSURL+ZZF.h"

@implementation NSURL (ZZF)

// 将http协议转成streaming协议
- (NSURL *)streamingURL {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"streaming";
    return components.URL;
}

- (NSURL *)httpURL {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"http";
    return components.URL;
}
@end
