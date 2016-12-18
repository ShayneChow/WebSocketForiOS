
#import <Foundation/Foundation.h>

/**
 *  socket状态
 */
typedef NS_ENUM(NSInteger,ZXSocketStatus){
    ZXSocketStatusConnected,// 已连接
    ZXSocketStatusFailed,// 失败
    ZXSocketStatusClosedByServer,// 系统关闭
    ZXSocketStatusClosedByUser,// 用户关闭
    ZXSocketStatusReceived// 接收消息
};
/**
 *  消息类型
 */
typedef NS_ENUM(NSInteger,ZXSocketReceiveType){
    ZXSocketReceiveTypeForMessage,
    ZXSocketReceiveTypeForPong
};
/**
 *  连接成功回调
 */
typedef void(^ZXSocketDidConnectBlock)();
/**
 *  失败回调
 */
typedef void(^ZXSocketDidFailBlock)(NSError *error);
/**
 *  关闭回调
 */
typedef void(^ZXSocketDidCloseBlock)(NSInteger code,NSString *reason,BOOL wasClean);
/**
 *  消息接收回调
 */
typedef void(^ZXSocketDidReceiveBlock)(id message ,ZXSocketReceiveType type);

@interface ZXSocketManager : NSObject
/**
 *  连接回调
 */
@property (nonatomic,copy)ZXSocketDidConnectBlock connect;
/**
 *  接收消息回调
 */
@property (nonatomic,copy)ZXSocketDidReceiveBlock receive;
/**
 *  失败回调
 */
@property (nonatomic,copy)ZXSocketDidFailBlock failure;
/**
 *  关闭回调
 */
@property (nonatomic,copy)ZXSocketDidCloseBlock close;
/**
 *  当前的socket状态
 */
@property (nonatomic,assign,readonly)ZXSocketStatus zx_socketStatus;
/**
 *  超时重连时间，默认1秒
 */
@property (nonatomic,assign)NSTimeInterval overtime;
/**
 *  重连次数,默认5次
 */
@property (nonatomic, assign)NSUInteger reconnectCount;
/**
 *  单例调用
 */
+ (instancetype)shareManager;
/**
 *  开启socket
 *
 *  @param urlStr  服务器地址
 *  @param connect 连接成功回调
 *  @param receive 接收消息回调
 *  @param failure 失败回调
 */
- (void)zx_open:(NSString *)urlStr connect:(ZXSocketDidConnectBlock)connect receive:(ZXSocketDidReceiveBlock)receive failure:(ZXSocketDidFailBlock)failure;
/**
 *  关闭socket
 *
 *  @param close 关闭回调
 */
- (void)zx_close:(ZXSocketDidCloseBlock)close;
/**
 *  发送消息，NSString 或者 NSData
 *
 *  @param data Send a UTF8 String or Data.
 */
- (void)zx_send:(id)data;

/**
 *  @param receive 接收消息回调
 */
- (void)zx_receiveMsg:(ZXSocketDidReceiveBlock)receive;
/**
 *  重连socket
 */
- (void)zx_reconnect;

@end
