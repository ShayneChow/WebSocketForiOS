//
//  ZXSocketManager.h
//  WebSocketForiOS
//
//  Created by Xiang on 16/4/26.
//  Copyright © 2016年 周想. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

@interface ZXSocketManager : NSObject

+ (ZXSocketManager *)sharedSocket;

@property (nonatomic, strong) SRWebSocket * socket;

@end
