//
//  TestViewController.m
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/26.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "TestViewController.h"
#import "ViewController.h"
#import "ZXSocketManager.h"

@interface TestViewController ()
@end

@implementation TestViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
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
    
    [[ZXSocketManager shareManager] zx_send:@"Test Message"];
    
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

@end
