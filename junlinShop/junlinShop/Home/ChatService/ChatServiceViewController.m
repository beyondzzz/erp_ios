//
//  ChatServiceViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/27.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ChatServiceViewController.h"
#import "WJIMTextMsgCell.h"
#import "WJIMPicMsgCell.h"
#import "WJIMMsgCellUtil.h"

@interface ChatServiceViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;

@end

@implementation ChatServiceViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.bounds), kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 100) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self.view addSubview:self.tableView];
    self.navigationItem.title = @"客服";
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    WJIMEmotionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    IMMsg *msg = [[IMMsg alloc]init];
    if (indexPath.row == 0) {
        msg.msgType = IMMsgTypeText;
    }else if (indexPath.row == 1) {
        msg.msgType = IMMsgTypeText;
    }else if (indexPath.row == 2) {
        msg.msgType = IMMsgTypePic;
    }else if (indexPath.row == 3) {
        msg.msgType = IMMsgTypePic;
    }else {
        msg.msgType = IMMsgTypeText;
    }
    
    if (indexPath.row % 2 == 0) {
        msg.fromType = IMMsgFromOther;
        msg.msgBody = @"dajkjhkajdhk";
    }else {
        msg.fromType = IMMsgFromLocalSelf;
        msg.msgBody = @"将卡上看见啊都是进口的口号就是啦啦啦啦啦啦啦啦啦啦";
    }
    //    WJIMMsgBaseCell *cell = [WJIMMsgCellUtil tableView:tableView cellForMsg:msg];
    
    //    [cell setIMMsg:msg];
    return [WJIMMsgCellUtil tableView:tableView cellForMsg:msg];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMMsg *msg = [[IMMsg alloc]init];
    if (indexPath.row == 0) {
        msg.msgType = IMMsgTypeText;
    }else if (indexPath.row == 1) {
        msg.msgType = IMMsgTypeText;
    }else if (indexPath.row == 2) {
        msg.msgType = IMMsgTypePic;
    }else if (indexPath.row == 3) {
        msg.msgType = IMMsgTypePic;
    }
    return [WJIMMsgCellUtil cellHeightForMsg:msg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
