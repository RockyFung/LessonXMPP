//
//  MessageController.m
//  LessonXMPP
//
//  Created by lanou on 15/11/19.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import "MessageController.h"

@interface MessageController ()<XMPPStreamDelegate>

@property (nonatomic, strong) NSMutableArray *array; // 存储聊天消息

@property (nonatomic, strong) XMPPManage *xmpp;

@end

@implementation MessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.xmpp = [XMPPManage shareXMPPManage];
    [self.xmpp.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 数组初始化
    self.array = [NSMutableArray array];
    // title显示和谁聊天
    self.navigationItem.title = self.jid.user;
    // 添加一个navigationbarButtonItem，用来发送一条消息
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(sendMessage)];
    // 最开始调用这个方法
    [self reloadMessage];
}

// 发送一条消息
- (void)sendMessage
{
    // 创建一个消息，指定发送给谁
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.jid];
    // 添加发送的消息
    [message addBody:@"hello"];
    // 发送消息
    [self.xmpp.stream sendElement:message];
}

// 一个刷新消息的方法
- (void)reloadMessage
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    // 检索我发的信息，和好友发给我的信息
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@ AND streamBareJidStr = %@",self.jid.bare, self.xmpp.stream.myJID.bare];
    request.predicate = predicate;
    // 我们发消息还有一个先后顺序，还要进行排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    NSArray *array = [self.xmpp.messageContext executeFetchRequest:request error:nil];
    // 把检索出来的消息，添加到数组中
    [self.array removeAllObjects];
    [self.array addObjectsFromArray:array];
    // 刷新列表
    [self.tableView reloadData];
    // 然后做一个消息从下方跳进来的动画
    NSInteger row = self.array.count - 1;
    // 如果我们没有消息，数组个数为0，row就等于-1，indexPath没有负数，就会奔溃
    if (row < 0) {
        row = 0;
    }
    // 如果没有一个item，就会刷新奔溃
    if (self.array.count != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myMessage" forIndexPath:indexPath];
    
    XMPPMessageArchiving_Message_CoreDataObject *message = self.array[indexPath.row];
    if (message.isOutgoing) {
        cell.detailTextLabel.text = message.body;
        // 防止重用问题，做一个滞空
        cell.textLabel.text = @"";
    }else{
        cell.textLabel.text = message.body;
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

// 发送成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"发送成功:%@",message);
    // 刷新当前消息列表
    [self reloadMessage];
}

// 发送失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    NSLog(@"发送失败:%@",error);
}

// 接收到一条消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"收到的消息:%@",message);
    // 刷新当前消息列表
    [self reloadMessage];
}









@end
