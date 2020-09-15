//
//  webSocketModule.m
//  HippyDemo
//
//  Created by mt010 on 2020/8/10.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "deBugSendMessage.h"
NSString * const kNeedPayOrderNoteDebug = @"kNeedPayOrderNoteDebug";//发送的通知名称
NSString * const kWebSocketDidOpenNoteDebug = @"kWebSocketDidOpenNoteDebug";//发送的通知名称
NSString * urlSteriDebug = @"";//发送的通知名称
NSInteger reconnectNumDebug = 5;
BOOL isReconncetDebug = false;

@interface deBugSendMessage()<HippySRWebSocketDelegate>
{
    int _index;
    NSTimer * heartBeat;
    NSTimer * reconnectBead;
    NSTimeInterval reConnectTime;
}

@property (nonatomic,strong) HippySRWebSocket *socket;
@end

@implementation deBugSendMessage
+ (deBugSendMessage *)instance {
    static deBugSendMessage *Instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        Instance = [[deBugSendMessage alloc] init];
    });
    return Instance;
}
- (void)SRWebSocketOpen{
    [self.socket open];     //开始连接
}
//关闭连接
- (void)SRWebSocketClose {
    if (self.socket){
        [self.socket close];
        self.socket = nil;
        //断开连接时销毁心跳
        [self destoryHeartBeat];
    }
}

//开启连接
-(void)SRWebSocketOpenWithURLString:(NSString *)urlString {
    if (self.socket) {
        return;
    }
    
    if (!urlString) {
        return;
    }
    //SRWebSocketUrlString 就是websocket的地址 写入自己后台的地址
    self.socket = [[HippySRWebSocket alloc] initWithURLRequest:
                   [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    self.socket.delegate = self;   //SRWebSocketDelegate 协议
    urlSteriDebug = urlString;
    [self.socket open];     //开始连接
}
#pragma mark - socket delegate
- (void)webSocketDidOpen:(HippySRWebSocket *)webSocket {
    NSLog(@"连接成功，可以与服务器交流了,同时需要开启心跳");
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    
    //开启心跳 心跳是发送pong的消息 我这里根据后台的要求发送data给后台
    [reconnectBead invalidate];
    reconnectBead = nil;
    isReconncetDebug = NO;
    reconnectNumDebug = 5;
    //[self initHeartBeat];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidOpenNoteDebug object:nil];
}
- (void)webSocket:(HippySRWebSocket *)webSocket didFailWithError:(NSError *)error {
//    NSLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
//    NSLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
//    NSLog(@"2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量");
//    NSLog(@"3.连接次数限制，如果连接失败了，重试10次左右就可以了，不然就死循环了。");
//
    [self.socket close];
    self.socket = nil;
    //断开连接时销毁心跳
    [self destoryHeartBeat];
    //连接失败就重连
    //[self reConnect];
}
- (void)webSocket:(HippySRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    //断开连接 同时销毁心跳
    [self SRWebSocketClose];
    
    
    if (isReconncetDebug){
        return;
    }
    NSLog(@"开始重新连接");
    reconnectBead = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(ReconnectDZG) userInfo:nil repeats:YES];
    isReconncetDebug = YES;
}
- (void)ReconnectDZG{
    if (reconnectNumDebug == 0){
        [reconnectBead invalidate];
        reconnectBead = nil;
        isReconncetDebug = NO;
        NSLog(@"重新连接失败");
    }
    reconnectNumDebug -= 1;
    self.socket = [[HippySRWebSocket alloc] initWithURLRequest:
                   [NSURLRequest requestWithURL:[NSURL URLWithString:urlSteriDebug]]];
                   self.socket.delegate = self;   //SRWebSocketDelegate 协议

    [self.socket open];     //开始连接
}
/*
 该函数是接收服务器发送的pong消息，其中最后一个是接受pong消息的，
 在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，
 用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，
 我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
 */
-(void)webSocket:(HippySRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"reply===%@",reply);
}

- (void)webSocket:(HippySRWebSocket *)webSocket didReceiveMessage:(id)message  {
    //收到服务器发过来的数据 这里的数据可以和后台约定一个格式 我约定的就是一个字符串 收到以后发送通知到外层 根据类型 实现不同的操作
    NSLog(@"message:%@",message);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedPayOrderNoteDebug object:message];
}

#pragma mark - methods
//重连机制
- (void)reConnect
{
    [self SRWebSocketClose];
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (reConnectTime > 64) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.socket = nil;
        [self SRWebSocketOpen];
        NSLog(@"重连");
    });
    
    //重连时间2的指数级增长
    if (reConnectTime == 0) {
        reConnectTime = 2;
    }else{
        reConnectTime *= 2;
    }
}

//初始化心跳
- (void)initHeartBeat
{
    
    if (@available(iOS 10.0, *)) {
        dispatch_main_async_safe(^{
            [self destoryHeartBeat];
            __weak typeof(self) weakSelf = self;
            //心跳设置为3分钟，NAT超时一般为5分钟
            self->heartBeat = [NSTimer scheduledTimerWithTimeInterval:3*60 repeats:YES block:^(NSTimer * _Nonnull timer) {
                NSLog(@"--------heart");
                //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
                [weakSelf sendData:@"--------heart"];
            }];
            [[NSRunLoop currentRunLoop]addTimer:self->heartBeat forMode:NSRunLoopCommonModes];
        })
    } else {
        heartBeat = [NSTimer scheduledTimerWithTimeInterval:3*60 target:self selector:@selector(sendDataTimerSelect) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self->heartBeat forMode:NSRunLoopCommonModes];
        // Fallback on earlier versions
    }
}
- (void)sendDataTimerSelect{
    NSLog(@"heart------------");
    [self sendData:@"heart"];
}
//取消心跳
- (void)destoryHeartBeat
{
    dispatch_main_async_safe(^{
        if (self->heartBeat) {
            [self->heartBeat invalidate];
            self->heartBeat = nil;
        }
    })
    
}
//pingPong机制
- (void)ping{
    if ([self.socket readyState] != HippySR_CONNECTING){
        NSLog(@"socket未连接");
        return;
    }
    [self.socket sendPing:nil];
}

#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self
- (void)sendData:(id)data {
    WeakSelf(ws);
    if(!weakSelf.socket){

        weakSelf.socket = [[HippySRWebSocket alloc] initWithURLRequest:
                       [NSURLRequest requestWithURL:[NSURL URLWithString:urlSteriDebug]]];
                       weakSelf.socket.delegate = self;   //SRWebSocketDelegate 协议

        [weakSelf.socket open];     //开始连接
    }
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            if (weakSelf.socket.readyState == HippySR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
                
            } else if (weakSelf.socket.readyState == HippySR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                
            } else if (weakSelf.socket.readyState == HippySR_CLOSING || weakSelf.socket.readyState == HippySR_CLOSED) {
            }
        } else {
            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
        }
    });
}
- (void)webSocketSendData:(NSString *)jsonString{
    [self sendData:jsonString];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
