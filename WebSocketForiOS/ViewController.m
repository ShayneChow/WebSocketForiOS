//
//  ViewController.m
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/9.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ViewController.h"
#import <SocketRocket/SRWebSocket.h>
#import <AFNetworking.h>
#import "ZXSocketManager.h"
#import "AppDelegate.h"

@interface ViewController ()<SRWebSocketDelegate, UITextFieldDelegate> {
    SRWebSocket *_socket;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITextView *showBox;

@property (copy, nonatomic) NSString *client;
@property (copy, nonatomic) NSString *clientId;
@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *sign;
@property (copy, nonatomic) NSString *time;

@property (copy, nonatomic) NSString *urlStr;

@end
// ws://ali.weplus.cn:6625?client=xxx&token=1&sign=2&time=3
@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _client = @"ios";
    _clientId = @"129844438158540802";
    _token = @"o6l2i8tpoDK_XO5wM8RB8jTnS1uk2MZ18MlQ0Bo2gOa93unP2QZeUs5siqB6Wo1Z";
    _sign = @"cYQ4h1bnFVIBcoKXOfcCXpZRvHWicpg9cyeWKuvKUBQ=";
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    //NSLog(@"timeSp:%@",timeSp); //时间戳的值
    _time = timeSp;
    
    _urlStr = [NSString stringWithFormat:@"ws://ali.weplus.cn:6625?client=%@&token=%@&sign=%@&time=%@&clientId=%@", _client, _token, _sign, _time, _clientId];
    //NSLog(@"%@", _urlStr);
   
    //[self reconnect:nil];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.showBox addGestureRecognizer:tgr];
    self.sendBtn.layer.cornerRadius = 5;
//    [ZXSocketManager sharedSocket].socket.delegate = self;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _socket = appDelegate.appSocket;
    _socket.delegate = self;
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)reconnect:(id)sender {
    _socket.delegate = nil;
    [_socket close];
//    NSString *url = @"ws://ali.weplus.cn:6625?client=iphone&token=dPNlf61dOQS_guBNj1ECDFprwp1bMd9SD2z55nry9JDSmbneiyiDhNUXCJMDodfE&sign=cYQ4h1bnFVIBcoKXOfcCXpZRvHWicpg9cyeWKuvKUBQ=&time=2016-04-15-15:53:23";
    //NSArray *arr = @[_client, _token, _sign, _time];
    
//    _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
    _socket.delegate = self;
    
    self.title = @"Opening Connection...";
    [_socket open];
    
}

- (IBAction)stopConnect:(id)sender {
    _socket.delegate = nil;
    [_socket close];
    _socket = nil;
    self.title = @"Connection Closed!";
}

- (IBAction)sendMessage:(id)sender {

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
    _showBox.text = [NSString stringWithFormat:@"%@\n发送消息：%@\n", _showBox.text, str];
    _messageTextField.text = nil;
    [self.messageTextField becomeFirstResponder];
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
    NSLog(@":( Websocket Failed With Error %@", error);
    
    self.title = @"Connection Failed! (see logs)";
    [_socket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Received \"%@\"", message);
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
        NSLog(@"%@ 成功！", tempDict[@"route"]);
    }
    
    _showBox.text = [NSString stringWithFormat:@"%@\n服务器返回：\n%@\n", _showBox.text, tempDict];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"WebSocket closed");
    self.title = @"Connection Closed!";
    [_socket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"Websocket received pong");
}

#pragma mark - keyboard events -

// 键盘显示事件
- (void)keyboardWillShow:(NSNotification *)notification {
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat INTERVAL_KEYBOARD = 0;
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    CGFloat offset = (_contentView.frame.origin.y + _contentView.frame.size.height+INTERVAL_KEYBOARD) - (self.view.frame.size.height - kbHeight);
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSLog(@"kbHeight: %f, offset: %f, duration:%f", kbHeight, offset, duration);
    //将视图上移计算好的偏移
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

// 键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notify {
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}


@end
