//
//  NoticeCenterViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2018/3/18.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "NoticeCenterViewController.h"
#import "NoticeCenterTableCell.h"
#import "NoticeListViewController.h"
#import "ActiveListViewController.h"
#import "YWWebViewController.h"
#import "LoginViewController.h"
#import "NoticeSettingViewController.h"

@interface NoticeCenterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *dataDic;

@end

@implementation NoticeCenterViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"NoticeCenterTableCell" bundle:nil] forCellReuseIdentifier:@"NoticeCenterTableCell"];
        
        [self.view addSubview:_tableView];
    }
}

- (void)getNoticeData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
    [HttpTools Get:kAppendUrl(YWGetMessageNumString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        _dataDic = [responseObject objectForKey:@"resultData"];
        [_tableView reloadData];
        
        BOOL hasNotice = NO;
        if ([[_dataDic objectForKey:@"ActivityNum"] integerValue] > 0) {
            hasNotice = YES;
        }
        if ([[_dataDic objectForKey:@"UserMessageNum"] integerValue] > 0) {
            hasNotice = YES;
        }
        if ([[_dataDic objectForKey:@"orderNum"] integerValue] > 0) {
            hasNotice = YES;
        }
        
        if (hasNotice) {
            [YWUserDefaults setValue:@"1" forKey:@"HasNotice"];
        } else {
            [YWUserDefaults setValue:@"0" forKey:@"HasNotice"];
        }
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getNoticeData];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([YWUserDefaults objectForKey:@"UserID"]) {
        [self getNoticeData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"消息中心";
    
    _dataArray = @[@"客户服务", @"订单消息", @"活动消息"];
    [self createTableView];
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"notice_setting_icon"] forState:UIControlStateNormal];
    
    //如果想要设置title的话也可以在这里设置,就是给btn设置title
    [btn sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    YWWeakSelf;
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NoticeSettingViewController *settingVC = [[NoticeSettingViewController alloc] init];
        [weakSelf.navigationController pushViewController:settingVC animated:YES];
    }];
    
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    
    if (![YWUserDefaults objectForKey:@"UserID"]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    // Do any additional setup after loading the view from its nib.
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoticeCenterTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoticeCenterTableCell" forIndexPath:indexPath];
    
    cell.titleLab.text = _dataArray[indexPath.row];
    cell.countLab.hidden = YES;
    [cell.countLab setRadius:10.f];
    
    NSInteger count = 0;
    NSString *timeStr = @"";
    
    NSString *imageStr = nil;
    if (indexPath.row == 0) {
        imageStr = @"notice_service_icon";
    } else if (indexPath.row == 1) {
        imageStr = @"notice_order_icon";
    } else if (indexPath.row == 2) {
        imageStr = @"notice_active_icon";
    }
    cell.noticeImageView.image = [UIImage imageNamed:imageStr];
    
    if (_dataDic) {
        switch (indexPath.row) {
            case 0:
            {
                count = [[_dataDic objectForKey:@"UserMessageNum"] integerValue];
                if ([[_dataDic objectForKey:@"UserMessageTime"] isKindOfClass:[NSNumber class]]) {
                    timeStr = [ASHString jsonDateToString:[_dataDic objectForKey:@"UserMessageTime"] withFormat:@"yyyy-MM-dd HH:mm"];
                } else {
                    timeStr = @"暂无客服消息";
                }
            }
                break;
            case 1:
            {
                count = [[_dataDic objectForKey:@"orderNum"] integerValue];
                if ([[_dataDic objectForKey:@"orderTime"] isKindOfClass:[NSNumber class]]) {
                    timeStr = [ASHString jsonDateToString:[_dataDic objectForKey:@"orderTime"] withFormat:@"yyyy-MM-dd HH:mm"];
                } else {
                    timeStr = @"暂无订单消息";
                }
            }
                break;
            case 2:
            {
                count = [[_dataDic objectForKey:@"ActivityNum"] integerValue];
                if ([[_dataDic objectForKey:@"ActivityTime"] isKindOfClass:[NSNumber class]]) {
                    timeStr = [ASHString jsonDateToString:[_dataDic objectForKey:@"ActivityTime"] withFormat:@"yyyy-MM-dd HH:mm"];
                } else {
                    timeStr = @"暂无活动消息";
                }
            }
                break;
            default:
                break;
        }
        
        if (count > 0) {
            cell.countLab.hidden = NO;
            cell.countLab.text = [NSString stringWithFormat:@"%ld", count];
        }
        if (timeStr) {
            cell.noticeLab.text = timeStr;
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        YWWebViewController *webVC = [[YWWebViewController alloc] init];
        NSDictionary *dict = [YWUserDefaults objectForKey:@"UserInfo"];
        webVC.titleStr = @"客服服务";
        webVC.webURL = [NSString stringWithFormat:@"%@%@&userName=%@&isVip=%@&clientId=%@", YWServiceHtmlString, [dict objectForKey:@"userPhone"],  [dict objectForKey:@"userName"], [dict objectForKey:@"isVIP"], [dict objectForKey:@"userId"]];
        [self.navigationController pushViewController:webVC animated:YES];
        
    } else {
        
        if (indexPath.row == 1) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
            [HttpTools Post:kAppendUrl(YWUpdateOrderStautsString) parameters:dict success:^(id responseObject) {
                
            } failure:^(NSError *error) {
                
            }];
            
            NoticeListViewController *listVC = [[NoticeListViewController alloc] init];
            [self.navigationController pushViewController:listVC animated:YES];
        } else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
            [HttpTools Post:kAppendUrl(YWUpdateActivityStautsString) parameters:dict success:^(id responseObject) {
                
            } failure:^(NSError *error) {
                
            }];
            ActiveListViewController *listVC = [[ActiveListViewController alloc] init];
            [self.navigationController pushViewController:listVC animated:YES];
        }
    }
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
