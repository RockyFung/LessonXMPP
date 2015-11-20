//
//  XMPPManage.h
//  LessonXMPP
//
//  Created by lanou on 15/11/19.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@interface XMPPManage : NSObject

@property (nonatomic, strong) XMPPStream *stream; // 通信管道类

@property (nonatomic, strong) XMPPRoster *roster; // 好友列表类

@property (nonatomic, strong) NSManagedObjectContext *messageContext; // 所有的消息都再coredata里面保存，我们使用coredata来获取

// 单例
+ (XMPPManage *)shareXMPPManage;

// 登陆方法
- (void)loginWithUser:(NSString *)user pw:(NSString *)pw;

// 注册的接口
- (void)registWithUser:(NSString *)user pw:(NSString *)pw;

@end
