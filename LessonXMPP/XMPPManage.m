//
//  XMPPManage.m
//  LessonXMPP
//
//  Created by lanou on 15/11/19.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import "XMPPManage.h"

typedef NS_ENUM(NSInteger, ConnectToServerPurpose){
    ConnectToServerPurposeLogin,
    ConnectToServerPurposeRegist
};

@interface XMPPManage ()<XMPPStreamDelegate>

@property (nonatomic, strong) NSString *longinPW; // 存储登陆密码

@property (nonatomic, strong) NSString *registPW; // 存储注册密码

@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving; // 聊天信息的类



@end


@implementation XMPPManage
{
    ConnectToServerPurpose connectToServerPurpose;
}


// 单例
+ (XMPPManage *)shareXMPPManage
{
    static XMPPManage *xmpp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xmpp = [[XMPPManage alloc]init];
    });
    return xmpp;
}


// 初始化方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初始化通信管道类
        self.stream = [[XMPPStream alloc]init];
        self.stream.hostName = kHostName;
        self.stream.hostPort = kHostPort;
        // 添加一个代理
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // 初始化好友列表
        // 需要一个代理，我们拿roster得coredata去接收，coredata会帮我们去处理好友，保存好友,coredata是一个单例
        XMPPRosterCoreDataStorage *coredataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        self.roster = [[XMPPRoster alloc]initWithRosterStorage:coredataStorage dispatchQueue:dispatch_get_main_queue()];
        // 好友列表类要和通信管道链接
        [self.roster activate:self.stream];
        
        // 初始化聊天信息类
        XMPPMessageArchivingCoreDataStorage *messageCoreData = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.messageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:messageCoreData dispatchQueue:dispatch_get_main_queue()];
        // 链接通信管道
        [self.messageArchiving activate:self.stream];
        
        self.messageContext = messageCoreData.mainThreadManagedObjectContext;
    }
    return self;
}


// 登陆方法
- (void)loginWithUser:(NSString *)user pw:(NSString *)pw
{
    // 定义一个属性来接收密码
    self.longinPW = pw;
    
    // 给枚举值赋值
    connectToServerPurpose = ConnectToServerPurposeLogin;
    
    // 登陆的时候调用链接服务器的方法
    [self connectToServerWithUser:user];
}


// 注册的接口
- (void)registWithUser:(NSString *)user pw:(NSString *)pw
{
    // 接收注册密码
    self.registPW = pw;
    
    // 给枚举值赋值
    connectToServerPurpose = ConnectToServerPurposeRegist;
    
    // 注册的时候也需要链接服务器
    // 也需要JID，可以把JID封装到链接服务器的方法
    [self connectToServerWithUser:user];
    
    
}


// 链接服务器
- (void)connectToServerWithUser:(NSString *)user
{
    // 判断服务器是否正在链接
    if (self.stream.isConnected) {
        // 如果正在链接，先断开
        [self disConnectToServer];
    }
    
    // 通信管道要知道登陆的是谁
    // 通信管道获取一个人使用,是XMPPJID相当于是一个用户
    XMPPJID *jid = [XMPPJID jidWithUser:user domain:kDomin resource:kResource];
    self.stream.myJID = jid;
    
    // 链接服务器的时间
    [self.stream connectWithTimeout:30 error:nil];
    
}


// 断开服务器
- (void)disConnectToServer
{
    [self.stream disconnect];
}


// 链接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"链接成功");
    // 因为登陆和注册都要再这里完成，我们要把它们区分开
    // 写一个枚举值
    switch (connectToServerPurpose) {
        case ConnectToServerPurposeLogin:
            // 开始登陆
            [sender authenticateWithPassword:self.longinPW error:nil];
            break;
            
        case ConnectToServerPurposeRegist:
            // 开始注册
            [sender registerWithPassword:self.registPW error:nil];
            break;
            
        default:
            break;
    }
 
}


// 链接失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"链接失败:%@",error);
}







@end
