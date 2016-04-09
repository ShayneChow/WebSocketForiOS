//
//  ViewController.m
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/9.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ViewController.h"
#import <SocketRocket/SRWebSocket.h>

@interface ViewController ()<SRWebSocketDelegate, UITextFieldDelegate> {
    SRWebSocket *_webSocket;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITextView *showBox;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reconnect:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.showBox addGestureRecognizer:tgr];
    self.sendBtn.layer.cornerRadius = 5;
    
    [self.messageTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)reconnect:(id)sender {
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://10.10.9.203:8089"]]];
    _webSocket.delegate = self;
    
    self.title = @"Opening Connection...";
    [_webSocket open];
    
}

- (IBAction)stopConnect:(id)sender {
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
    self.title = @"Connection Closed!";
}

- (IBAction)sendMessage:(id)sender {
    [self hideKeyboard];
    [_webSocket sendPing:nil];
    [_webSocket send:_messageTextField.text];
    _showBox.text = [NSString stringWithFormat:@"%@\n发送消息：%@\n", _showBox.text, _messageTextField.text];
    _messageTextField.text = nil;
    [self.messageTextField becomeFirstResponder];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Websocket Connected");
    self.title = @"Connected!";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@":( Websocket Failed With Error %@", error);
    
    self.title = @"Connection Failed! (see logs)";
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Received \"%@\"", message);
    
    // 字符串转json，json转字典。
    NSData *resData = [[NSData alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *tempDict = [NSDictionary dictionary];
    tempDict = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];  //解析
    NSLog(@"%@", tempDict);
    if ([tempDict[@"route"] isEqualToString:@"SCAN"]) {
        NSLog(@"%@ 成功！", tempDict[@"route"]);
    }
    
    _showBox.text = [NSString stringWithFormat:@"%@\n服务器返回：\n%@\n", _showBox.text, tempDict];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"WebSocket closed");
    self.title = @"Connection Closed!";
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"Websocket received pong");
}

@end
