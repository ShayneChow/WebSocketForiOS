//
//  AppDelegate.m
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/9.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "AppDelegate.h"
#import "ZXSocketManager.h"

@interface AppDelegate ()<SRWebSocketDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    NSURL *url=[NSURL URLWithString:@"http://www.baidu.com"];
//    [[ZXSocketManager sharedSocket] initWithURL:url].delegate = self;
    static NSString * url;
    NSString *client = @"ios";
    NSString *clientId = @"129844438158540802";
    NSString *token = @"o6l2i8tpoDK_XO5wM8RB8jTnS1uk2MZ18MlQ0Bo2gOa93unP2QZeUs5siqB6Wo1Z";
    NSString *sign = @"cYQ4h1bnFVIBcoKXOfcCXpZRvHWicpg9cyeWKuvKUBQ=";
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSLog(@"timeSp:%@",timeSp); //时间戳的值
    NSString *time = timeSp;
    
    url = [NSString stringWithFormat:@"ws://ali.weplus.cn:6625?client=%@&token=%@&sign=%@&time=%@&clientId=%@", client, token, sign, time, clientId];
//    [ZXSocketManager sharedSocket] = [[SRWebSocket alloc] initWithURLRequest:[NSURL URLWithString:url]];
    _appSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    _appSocket.delegate = self;
    [_appSocket open];
    
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(heartBeat)
                                   userInfo:nil repeats:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //[[ZXSocketManager sharedSocket] open];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //[[ZXSocketManager sharedSocket] close];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //[[ZXSocketManager sharedSocket] open];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
    [_appSocket sendPing:nil];
//    [NSTimer scheduledTimerWithTimeInterval:10
//                                     target:self
//                                   selector:@selector(heartBeat)
//                                   userInfo:nil repeats:YES];
}

- (void)heartBeat {
    NSLog(@"=========== Heart Beat ============");
    NSDictionary *tempDict = @{
                               @"route": @"HEART_BEAT",
                               @"payload": @{}
                               };
    
    NSString *str = [self dictionaryToJson:tempDict];
    [_appSocket send:str];
}

- (NSString *)dictionaryToJson:(NSDictionary *)dic {
    
    NSError *err = nil;
    // options:  NSJSONWritingPrettyPrinted  是有换位符的, 是nil的话 返回的数据是没有换位符的.
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];
    
    if(err) {
        NSLog(@"字典转json字符串失败：%@",err);
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"===AppDelegate Websocket Failed With Error %@", error);
    
    [_appSocket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"====AppDelegate Received \"%@\"", message);
    NSError *err;
    // 字符串转json，json转字典。
    NSData *resData = [[NSData alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *tempDict = [NSDictionary dictionary];
    tempDict = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:&err];  //解析
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
    }
    
    //NSLog(@"%@", tempDict);
    if ([tempDict[@"route"] isEqualToString:@"SCAN"]) {
        NSLog(@"==== AppDelegate %@ 成功！", tempDict[@"route"]);
    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"==== WebSocket closed");
    [_appSocket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"AppDelegate  ===  Websocket received pong");
}

@end
