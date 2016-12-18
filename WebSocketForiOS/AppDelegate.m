//
//  AppDelegate.m
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/9.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "AppDelegate.h"
#import "ZXSocketManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[ZXSocketManager shareManager] zx_close:^(NSInteger code, NSString *reason, BOOL wasClean) {
        NSLog(@"code: %li", (long)code);
        NSLog(@"reason: %@", reason);
        NSLog(@"wasClean: %i", wasClean);
    }];
    
    NSString *url = @"ws://echo.websocket.org";
    [[ZXSocketManager shareManager] zx_open:url connect:^{
        NSLog(@"AppDelegate 成功连接");
    } receive:^(id message, ZXSocketReceiveType type) {
        if (type == ZXSocketReceiveTypeForMessage) {
            NSLog(@"接收 类型1--%@",message);
        }
        else if (type == ZXSocketReceiveTypeForPong){
            NSLog(@"接收 类型2--%@",message);
        }
    } failure:^(NSError *error) {
        NSLog(@"AppDelegate连接失败");
    }];
    
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

- (void)heartBeat {
    NSLog(@"=========== Heart Beat ============");
    NSDictionary *tempDict = @{
                               @"route": @"HEART_BEAT",
                               @"payload": @{}
                               };
    
    NSString *str = [self dictionaryToJson:tempDict];
    [[ZXSocketManager shareManager] zx_send:str];
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
