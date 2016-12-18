//
//  ViewController.m
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/9.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "ZXSocketManager.h"

@interface ViewController ()<UITextFieldDelegate>

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
    
    [self registerForKeyboardNotifications];
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.showBox addGestureRecognizer:tgr];
    self.sendBtn.layer.cornerRadius = 5;
    
    [[ZXSocketManager shareManager] zx_receiveMsg:^(id message, ZXSocketReceiveType type) {
        NSLog(@"message: %@", message);
        _showBox.text = [NSString stringWithFormat:@"%@\n接收消息：%@\n", _showBox.text, message];
    }];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications {
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
    [[ZXSocketManager shareManager] zx_reconnect];
    
}

- (IBAction)stopConnect:(id)sender {
    [[ZXSocketManager shareManager] zx_close:^(NSInteger code, NSString *reason, BOOL wasClean) {
        NSLog(@"code: %li", (long)code);
        NSLog(@"reason: %@", reason);
        NSLog(@"wasClean: %i", wasClean);
    }];
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
    
    [[ZXSocketManager shareManager] zx_send:str];
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
