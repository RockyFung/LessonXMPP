//
//  FriendController.m
//  LessonXMPP
//
//  Created by lanou on 15/11/19.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import "FriendController.h"
#import "MessageController.h"
#import "XMPPManage.h"

@interface FriendController ()<XMPPRosterDelegate>
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation FriendController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化数组
    self.array = [NSMutableArray array];
    
    // 好友列表类
    XMPPManage *xmpp = [XMPPManage shareXMPPManage];
    // 添加代理
    [xmpp.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 接入协议
    
    
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myFriend" forIndexPath:indexPath];
    XMPPJID *jid = self.array[indexPath.row];
    cell.textLabel.text = jid.user;
    return cell;
}


#pragma mark - 跳转到消失控制器
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建storyBoard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // 2.根据标识找到messageVC
    MessageController *messageVc = [storyboard instantiateViewControllerWithIdentifier:@"myMessage"];
    
    // 把jid传递过去，这样就知道和谁在聊天
    messageVc.jid = self.array[indexPath.row];
    
    // 3.跳转
    [self.navigationController pushViewController:messageVc animated:YES];
    
    
}


// 准备获取好友列表
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    // 准备的时候清空数组
    [self.array removeAllObjects];
}

// 获取好友列表
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item
{
    // 每个好友都是以JID类型存储的，我们要对item做一个转换
    NSString *jidStr = [[item attributeForName:@"jid"]stringValue];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    [self.array addObject:jid];
}

// 获取好友列表完毕
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    // 获取完毕的时候，刷新tableview
    [self.tableView reloadData];
}



@end
