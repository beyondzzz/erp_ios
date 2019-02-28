//
//  GetYouHuiQuanViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/2.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "GetYouHuiQuanViewController.h"
#import "YouHuiQuanListTableCell.h"

@interface GetYouHuiQuanViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation GetYouHuiQuanViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"YouHuiQuanListTableCell" bundle:nil] forCellReuseIdentifier:@"YouHuiQuanListTableCell"];
        
        
        [self.view addSubview:_tableView];
    }
}

- (void)showNoDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight)];
        _noDataView.backgroundColor = kBackGrayColor;
        
        UIImageView *noDataImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noData_youhuiquan"]];
        [_noDataView addSubview:noDataImageView];
        [noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX);
            make.top.equalTo(_noDataView.mas_top).offset(150);
            make.width.equalTo(@100);
            make.height.equalTo(@101);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = kGrayTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"很遗憾";
        [_noDataView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX);
            make.top.equalTo(noDataImageView.mas_bottom).offset(15);
            make.width.equalTo(@180);
            make.height.equalTo(@20);
        }];
        
        UILabel *tiplabel = [[UILabel alloc] init];
        tiplabel.textColor = kGrayTextColor;
        tiplabel.font = [UIFont systemFontOfSize:15];
        tiplabel.textAlignment = NSTextAlignmentCenter;
        tiplabel.text = @"您暂无可领取的优惠券";
        [_noDataView addSubview:tiplabel];
        [tiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX);
            make.top.equalTo(label.mas_bottom).offset(6);
            make.width.equalTo(@180);
            make.height.equalTo(@20);
        }];
    }
    
    if (![self.view.subviews containsObject:_noDataView]) {
        [self.view addSubview:_noDataView];
    }
}

- (void)getAllListData {
    
    [HttpTools Get:kAppendUrl(YWCanGetCouponsString) parameters:nil success:^(id responseObject) {
        [self.view stopLoading];
        NSArray *dataArray = [responseObject objectForKey:@"resultData"];
        [self.dataArray addObjectsFromArray:dataArray];
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getAllListData];
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"领券中心";
    _dataArray = [NSMutableArray array];
    
    [self createTableView];
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    
    [self getAllListData];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YouHuiQuanListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YouHuiQuanListTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setCanGetYouHuiQuanDataWithDic:_dataArray[indexPath.row]];
    
    YWWeakSelf;
    [[[cell.getBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:userID forKey:@"userId"];
        [dict setValue:[weakSelf.dataArray[indexPath.row] objectForKey:@"id"] forKey:@"couponId"];
        
        [HttpTools Post:kAppendUrl(YWGetCouponString) parameters:dict success:^(id responseObject) {
            [SVProgressHUD showInfoWithStatus:[responseObject objectForKey:@"resultData"]];
        } failure:^(NSError *error) {
//            [SVProgressHUD showErrorWithStatus:@"领取失败"];
        }];
        
    }];
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    NSDictionary *dic = _dataArray[indexPath.row];
//
//}

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
