//
//  LoginController.m
//  LessonXMPP
//
//  Created by lanou on 15/11/19.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import "LoginController.h"
#import "XMPPManage.h"


@interface LoginController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UITextField *password;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)login:(id)sender {
    // 获取单例
    XMPPManage *xmpp = [XMPPManage shareXMPPManage];
    
    // 调用登陆接口
    [xmpp loginWithUser:self.userName.text pw:self.password.text];
    
    // 等待链接成功
    
    // 添加代理
    [xmpp.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


// 登陆成功代理方法
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"登陆成功");
    // 一个状态的类,创建一个登陆状态的类
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    // 然后让XMPPStream的对象发送
    [sender sendElement:presence];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 登陆失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"登陆失败:%@",error);
}


















@end
