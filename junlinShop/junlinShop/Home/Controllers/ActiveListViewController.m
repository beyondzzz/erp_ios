//
//  ActiveListViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2018/3/25.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ActiveListViewController.h"
#import "ActiveListTableViewCell.h"
#import "ActiveDetailViewController.h"

@interface ActiveListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ActiveListViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"ActiveListTableViewCell" bundle:nil] forCellReuseIdentifier:@"ActiveListTableViewCell"];
        
        [self.view addSubview:_tableView];
    }
}

- (void)requestNoticeList {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dic setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWActivityMessageListString) parameters:dic success:^(id responseObject) {
        [self.view stopLoading];
        
        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
        for (NSDictionary *dict in [dataDic objectForKey:@"activityMessageList"]) {
            [self.dataArray addObject:dict];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf requestNoticeList];
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"活动消息列表";
    _dataArray = [NSMutableArray array];
    [self createTableView];
    
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    [self requestNoticeList];
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
    return 280;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActiveListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActiveListTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setDataWithDic:_dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ActiveDetailViewController *detailVC = [[ActiveDetailViewController alloc] init];
    NSDictionary *dict = _dataArray[indexPath.row];
    detailVC.activeID = [dict objectForKey:@"activityInformatId"];
    [self.navigationController pushViewController:detailVC animated:YES];
    
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
