

#import "ZXSocketManager.h"
#import "SRWebSocket.h"
@interface ZXSocketManager ()<SRWebSocketDelegate>
@property (nonatomic,strong)SRWebSocket *webSocket;

@property (nonatomic,assign)ZXSocketStatus zx_socketStatus;

@property (nonatomic,weak)NSTimer *timer;

@property (nonatomic,copy)NSString *urlString;

@end

@implementation ZXSocketManager{
    NSInteger _reconnectCounter;
}


+ (instancetype)shareManager{
    static ZXSocketManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.overtime = 1;
        instance.reconnectCount = 5;
    });
    return instance;
}

- (void)zx_open:(NSString *)urlStr connect:(ZXSocketDidConnectBlock)connect receive:(ZXSocketDidReceiveBlock)receive failure:(ZXSocketDidFailBlock)failure{
    [ZXSocketManager shareManager].connect = connect;
    [ZXSocketManager shareManager].receive = receive;
    [ZXSocketManager shareManager].failure = failure;
    [self zx_open:urlStr];
}

- (void)zx_receiveMsg:(ZXSocketDidReceiveBlock)receive {
    [ZXSocketManager shareManager].receive = receive;
}

- (void)zx_close:(ZXSocketDidCloseBlock)close{
    [ZXSocketManager shareManager].close = close;
    [self zx_close];
}

// Send a UTF8 String or Data.
- (void)zx_send:(id)data{
    switch ([ZXSocketManager shareManager].zx_socketStatus) {
        case ZXSocketStatusConnected:
        case ZXSocketStatusReceived:{
            NSLog(@"发送中。。。");
            [self.webSocket send:data];
            break;
        }
        case ZXSocketStatusFailed:
            NSLog(@"发送失败");
            break;
        case ZXSocketStatusClosedByServer:
            NSLog(@"已经关闭");
            break;
        case ZXSocketStatusClosedByUser:
            NSLog(@"已经关闭");
            break;
    }
    
}

#pragma mark -- private method
- (void)zx_open:(id)params{
//    NSLog(@"params = %@",params);
    NSString *urlStr = nil;
    if ([params isKindOfClass:[NSString class]]) {
        urlStr = (NSString *)params;
    }
    else if([params isKindOfClass:[NSTimer class]]){
        NSTimer *timer = (NSTimer *)params;
        urlStr = [timer userInfo];
    }
    [ZXSocketManager shareManager].urlString = urlStr;
    [self.webSocket close];
    self.webSocket.delegate = nil;
    
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    self.webSocket.delegate = self;
    
    [self.webSocket open];
}

- (void)zx_close{
    
    [self.webSocket close];
    self.webSocket = nil;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)zx_reconnect{
    // 计数+1
    if (_reconnectCounter < self.reconnectCount - 1) {
        _reconnectCounter ++;
        // 开启定时器
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.overtime target:self selector:@selector(zx_open:) userInfo:self.urlString repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.timer = timer;
    }
    else{
        NSLog(@"Websocket Reconnected Outnumber ReconnectCount");
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        return;
    }
    
}

#pragma mark -- SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    //NSLog(@"Websocket Connected");
    
    [ZXSocketManager shareManager].connect ? [ZXSocketManager shareManager].connect() : nil;
    [ZXSocketManager shareManager].zx_socketStatus = ZXSocketStatusConnected;
    // 开启成功后重置重连计数器
    _reconnectCounter = 0;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    //NSLog(@":( Websocket Failed With Error %@", error);
    [ZXSocketManager shareManager].zx_socketStatus = ZXSocketStatusFailed;
    [ZXSocketManager shareManager].failure ? [ZXSocketManager shareManager].failure(error) : nil;
    // 重连
    [self zx_reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    //NSLog(@":( Websocket Receive With message %@", message);
    [ZXSocketManager shareManager].zx_socketStatus = ZXSocketStatusReceived;
    [ZXSocketManager shareManager].receive ? [ZXSocketManager shareManager].receive(message,ZXSocketReceiveTypeForMessage) : nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    //NSLog(@"Closed Reason:%@  code = %zd",reason,code);
    if (reason) {
        [ZXSocketManager shareManager].zx_socketStatus = ZXSocketStatusClosedByServer;
        // 重连
        //[self zx_reconnect];
    }
    else{
        [ZXSocketManager shareManager].zx_socketStatus = ZXSocketStatusClosedByUser;
    }
    [ZXSocketManager shareManager].close ? [ZXSocketManager shareManager].close(code,reason,wasClean) : nil;
    self.webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    [ZXSocketManager shareManager].receive ? [ZXSocketManager shareManager].receive(pongPayload,ZXSocketReceiveTypeForPong) : nil;
}

- (void)dealloc{
    // Close WebSocket
    [self zx_close];
}

@end
