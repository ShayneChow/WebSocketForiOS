//
//  TestViewController.m
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/26.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "TestViewController.h"
#import "ZXSocketManager.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface TestViewController ()<SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *socket;
@end

@implementation TestViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _socket = appDelegate.appSocket;
    _socket.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    _socket = appDelegate.appSocket;
//    _socket.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
//    _socket.delegate = nil;
//    _socket = nil;
}

- (IBAction)push:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"viewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sendMessage:(id)sender {
    NSLog(@"test vc send message.");
    NSDictionary *tempDict = @{
                               @"route": @"SCAN",
                               @"payload": @{
                                       @"adjust_amount": @"adjust_amount",
                                       @"auth_code": @"auth_code",
                                       @"discount_amount": @"discount_amount",
                                       @"payment_channel": @"payment_channel",
                                       @"total_amount": @"total_amount",
                                       @"orders": @[@{@"id": @"0",
                                                      @"num": @"1",
                                                      @"price": @"21"}]
                                       }
                               };
    
    NSString *str = [self dictionaryToJson:tempDict];
    
    [_socket send:str];
    
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

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    self.title = @"Connection Success!";
    [_socket sendPing:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@">>>测试页面的socket Failed With Error %@", error);
    
    self.title = @"Connection Failed! (see logs)";
    [_socket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"测试页面的socket Received \"%@\"", message);
    NSError *err;
    // 字符串转json，json转字典。
    NSData *resData = [[NSData alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *tempDict = [NSDictionary dictionary];
    tempDict = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:&err];  //解析
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
    }
    
    NSLog(@"%@", tempDict);
    if ([tempDict[@"route"] isEqualToString:@"SCAN"]) {
        NSLog(@">>>测试页面的socket %@ 成功！", tempDict[@"route"]);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"WebSocket closed");
    self.title = @"Connection Closed!";
    [_socket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"测试页面的socket");
}

@end
