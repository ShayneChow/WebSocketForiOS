//
//  AppDelegate.h
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/9.
//  Copyright © 2016年 周想. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SocketRocket/SRWebSocket.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) SRWebSocket *appSocket;

@end

