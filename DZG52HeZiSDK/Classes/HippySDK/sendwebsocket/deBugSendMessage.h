//
//  webSocketModule.h
//  HippyDemo
//
//  Created by mt010 on 2020/8/10.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "HippySRWebSocket.h"
#import "HippyUtils.h"
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

NS_ASSUME_NONNULL_BEGIN

@interface deBugSendMessage : NSObject
+ (deBugSendMessage *)instance;
-(void)SRWebSocketOpenWithURLString:(NSString *)urlString;
- (void)webSocketSendData:(NSString *)jsonString;
@end

NS_ASSUME_NONNULL_END
