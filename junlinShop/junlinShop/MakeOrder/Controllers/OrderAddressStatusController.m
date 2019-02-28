//
//  OrderAddressStatusController.m
//  junlinShop
//
//  Created by 叶旺 on 2018/2/13.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "OrderAddressStatusController.h"
#import "OrderAddressStatusTableCell.h"

@interface OrderAddressStatusController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation OrderAddressStatusController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        adjustsScrollViewInsets(_tableView);
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"OrderAddressStatusTableCell" bundle:nil] forCellReuseIdentifier:@"OrderAddressStatusTableCell"];
        
        [self createHeaderView];
        
        [self.view addSubview:_tableView];
    }
}

- (void)createHeaderView {
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 65)];
    _headerView.backgroundColor = kBackViewColor;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.tag = 1000;
    [_headerView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headerView.mas_left).offset(20);
        make.top.equalTo(_headerView.mas_top).offset(15);
        make.width.equalTo(@(20));
        make.height.equalTo(@(20));
    }];
    imageView.image = [UIImage imageNamed:@"order_complete_icon"];
    
    UILabel *statusLab = [[UILabel alloc] init];
    statusLab.text = @"";
    statusLab.tag = 1001;
    [_headerView addSubview:statusLab];
    [statusLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(15);
        make.right.equalTo(_headerView.mas_right).offset(-20);
        make.centerY.equalTo(imageView.mas_centerY);
        make.height.equalTo(@(20));
    }];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_headerView.frame) - 13, kIphoneWidth, 13)];
    view.backgroundColor = kBackGrayColor;
    [_headerView addSubview:view];
    
    self.tableView.tableHeaderView = _headerView;
}

- (void)requestExpressStatus {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_orderID forKey:@"orderId"];
    NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dict setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWOrderStateDetailString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        self.dataArray = [responseObject objectForKey:@"resultData"];
        [self.tableView reloadData];
        
        if (_dataArray.count > 0) {
            UILabel *label = [_headerView viewWithTag:1001];
            label.text = [[_dataArray firstObject] objectForKey:@"orderStateDetail"];
        }
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf requestExpressStatus];
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"商品追踪";
    
    [self createTableView];
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    
    [self requestExpressStatus];
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
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderAddressStatusTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderAddressStatusTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setDataWithDic:self.dataArray[indexPath.row]];
    if (indexPath.row == 0) {
        cell.statusImageView.hidden = NO;
        cell.statusView.hidden = YES;
        
        cell.titleLab.textColor = kBackGreenColor;
        cell.topLineView.hidden = YES;
    } else {
        cell.statusImageView.hidden = YES;
        cell.statusView.hidden = NO;
        
        cell.titleLab.textColor = kBlackTextColor;
        cell.topLineView.hidden = NO;
    }
    
    if (indexPath.row == _dataArray.count - 1) {
        cell.bottomLineView.hidden = YES;
    } else {
        cell.bottomLineView.hidden = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
