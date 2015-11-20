//
//  RegistController.m
//  LessonXMPP
//
//  Created by lanou on 15/11/19.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import "RegistController.h"
#import "XMPPManage.h"

@interface RegistController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation RegistController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)regist:(id)sender {
    // 接收代理
    XMPPManage *xmpp = [XMPPManage shareXMPPManage];
    [xmpp.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 调用注册接口
    [xmpp registWithUser:self.userName.text pw:self.password.text];
}


// 接收代理方法

// 注册成功的方法
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"注册成功");
    // 注册成功，回到登陆页面
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 注册失败的方法
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败:%@",error);
}



@end
