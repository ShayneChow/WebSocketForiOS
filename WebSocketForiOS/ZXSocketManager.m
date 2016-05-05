//
//  ZXSocketManager.m
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/26.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ZXSocketManager.h"

@implementation ZXSocketManager

+ (ZXSocketManager *)sharedSocket {
    
    static NSString * url;
    NSString *client = @"ios";
    NSString *clientId = @"129844438158540802";
    NSString *token = @"o6l2i8tpoDK_XO5wM8RB8jTnS1uk2MZ18MlQ0Bo2gOa93unP2QZeUs5siqB6Wo1Z";
    NSString *sign = @"cYQ4h1bnFVIBcoKXOfcCXpZRvHWicpg9cyeWKuvKUBQ=";
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    //NSLog(@"timeSp:%@",timeSp); //时间戳的值
    NSString *time = timeSp;
    
    url = [NSString stringWithFormat:@"ws://ali.weplus.cn:6625?client=%@&token=%@&sign=%@&time=%@&clientId=%@", client, token, sign, time, clientId];
    
    static ZXSocketManager * sharedSocket = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedSocket = [[ZXSocketManager alloc] init];
//        sharedSocket.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        sharedSocket.socket = [[SRWebSocket alloc] init];
    });
    return sharedSocket;
}

//- (void)connectWithURL:(NSString *)url {
//     [self initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] protocols:nil allowsUntrustedSSLCertificates:YES];
//    //self.delegate = self;
//}


@end
