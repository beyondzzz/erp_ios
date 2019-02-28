//
//  ToCommentViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2018/3/18.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ToCommentViewController.h"
#import "OrderListViewCell.h"
#import "SetCommentViewController.h"
#import "OrderDetailViewController.h"
#import "ShopCarViewController.h"

@interface ToCommentViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *noDataView;

@property (nonatomic, strong) NSMutableArray *dataArray;


@end

@implementation ToCommentViewController

- (void)showNoDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight)];
        _noDataView.backgroundColor = kBackGrayColor;
        
        UIImageView *noDataImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noData_orderList"]];
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
        label.text = @"暂无订单";
        [_noDataView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX);
            make.top.equalTo(noDataImageView.mas_bottom).offset(15);
            make.width.equalTo(@180);
            make.height.equalTo(@20);
        }];
        
    }
    
    if (![self.view.subviews containsObject:_noDataView]) {
        [self.view addSubview:_noDataView];
    }
}

- (void)requestOrderList {
    [self.dataArray removeAllObjects];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dic setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWOrderListString) parameters:dic success:^(id responseObject) {
        [self.view stopLoading];
        for (NSDictionary *dict in [responseObject objectForKey:@"resultData"]) {
            if ([[dict objectForKey:@"orderState"] intValue] == 3 || [[dict objectForKey:@"orderState"] intValue] == 10 || [[dict objectForKey:@"orderState"] intValue] == 10) {
                
                if ([[dict objectForKey:@"isHasEvaluation"] intValue] == 0) {
                    [self.dataArray addObject:dict];
                }
                
            }
        }
        
        if (self.dataArray.count == 0) {
            [self showNoDataView];
        } else {
            [self.noDataView removeFromSuperview];
            [self.tableView reloadData];
        }
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf requestOrderList];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestOrderList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"待评价订单";
    _dataArray = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderListViewCell" bundle:nil] forCellReuseIdentifier:@"OrderListViewCell"];
    
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    
    //如果想要设置title的话也可以在这里设置,就是给btn设置title
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backItemDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    // Do any additional setup after loading the view from its nib.
}

- (void)backItemDidClick {
    
//    [YWNoteCenter postNotificationName:@"RefreshOrderNumber" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_dataArray[section] objectForKey:@"orderDetails"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *dict = _dataArray[section];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 50)];
    backView.backgroundColor = [UIColor whiteColor];
    
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 10)];
    grayView.backgroundColor = kBackGrayColor;
    [backView addSubview:grayView];
    
    UILabel *orderNumLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 270, 20)];
    orderNumLab.textColor = kBlackTextColor;
    orderNumLab.font = [UIFont systemFontOfSize:15.f];
    orderNumLab.text = @"订单编号：";
    if ([dict objectForKey:@"orderNo"]) {
        orderNumLab.text = [NSString stringWithFormat:@"订单编号：%@", [dict objectForKey:@"orderNo"]];
    }
    [backView addSubview:orderNumLab];
    
    UILabel *style = [[UILabel alloc] initWithFrame:CGRectMake(kIphoneWidth - 105, 18.5, 90, 20)];
    style.textColor = kBackGreenColor;
    style.font = [UIFont systemFontOfSize:15.f];
    style.textAlignment = NSTextAlignmentRight;
    
    switch ([[dict objectForKey:@"orderState"] intValue]) {
        case 0:
            style.text = @"待支付";
            break;
        case 1:
            style.text = @"待发货";
            break;
        case 2:
            style.text = @"待收货";
            break;
        case 3:
            style.text = @"已完成";
            break;
        case 4:
            style.text = @"已取消";
            break;
        case 5:
            style.text = @"已关闭";
            break;
        case 6:
            style.text = @"售后中";
            break;
        case 7:
            style.text = @"已退货退款";
            break;
        case 8:
            style.text = @"已换货";
            break;
        case 9:
            style.text = @"已支付";
            break;
        default:
            style.text = @"关闭售后";
            break;
    }
    [backView addSubview:style];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(backView.frame) - 0.5, kIphoneWidth - 20, 0.5)];
    lineView.backgroundColor = kGrayLineColor;
    [backView addSubview:lineView];
    
    return backView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSDictionary *dict = _dataArray[section];
    
    CGFloat height = 80;
    //    CGFloat height = [self getListCellHeightWithIndex:section];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, height)];
    backView.backgroundColor = [UIColor whiteColor];
    
    CGFloat orderPrice = [[dict objectForKey:@"orderPresentPrice"] floatValue];
    CGFloat orderPostage = [[dict objectForKey:@"postage"] floatValue];
    
    UILabel *priceLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, kIphoneWidth - 20 , 20)];
    priceLab.textColor = kBlackTextColor;
    priceLab.font = [UIFont systemFontOfSize:15.f];
    priceLab.text = [NSString stringWithFormat:@"共计%ld件商品 合计：¥%.2f（含运费¥%.2f）", [[dict objectForKey:@"orderDetails"] count], (orderPrice + orderPostage), orderPostage];
    priceLab.textAlignment = NSTextAlignmentRight;
    [backView addSubview:priceLab];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(backView.frame) - 45, kIphoneWidth - 20, 0.5)];
    bottomLineView.backgroundColor = kGrayLineColor;
    [backView addSubview:bottomLineView];
    
    CGFloat btnWidth = 75;
    for (int i = 0; i < 2; i ++) {
        UIButton *requireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        requireBtn.hidden = NO;
        requireBtn.frame = CGRectMake(kIphoneWidth - 88 - (btnWidth + 10) * i, CGRectGetHeight(backView.frame) - 38, 75, 32);
        requireBtn.tag = 1000 + i;
        //        [requireBtn setTitle:@"确认领取" forState:UIControlStateNormal];
        [requireBtn setTitleColor:kBackGreenColor forState:UIControlStateNormal];
        requireBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [requireBtn setBorder:kBackGreenColor width:1.f radius:13.f];
        [backView addSubview:requireBtn];
    }
    
    UIButton *leftBtn = [backView viewWithTag:1001];
    UIButton *rightBtn = [backView viewWithTag:1000];
    
    NSString *leftBtnStr = nil;
    NSString *rightBtnStr = nil;
    switch ([[dict objectForKey:@"orderState"] intValue]) {
        case 0: {
            rightBtnStr = @"支付";//@"待支付"
            leftBtnStr = nil;
        }
            break;
        case 1: {
            rightBtnStr = @"订单跟踪";//@"待发货";
            leftBtnStr = nil;
        }
            break;
        case 2: {
            rightBtnStr = @"订单跟踪";//@"待收货";
            leftBtnStr = @"确认收货";
        }
            break;
        case 3: {
            rightBtnStr = @"再次购买";//@"已完成";
            if ([[dict objectForKey:@"isHasEvaluation"] intValue] == 0) {
                leftBtnStr = @"晒单评价";
            } else if ([[dict objectForKey:@"isHasEvaluation"] intValue] == 1) {
                leftBtnStr = @"评价详情";
            } else {
                leftBtnStr = nil;
            }
        }
            break;
        case 4: {
            rightBtnStr = @"再次购买";//@"已取消";
            leftBtnStr = nil;
        }
            break;
        case 5: {
            rightBtnStr = @"再次购买";//@"已关闭";
            leftBtnStr = nil;
        }
            break;
        case 6: {
            rightBtnStr = @"订单跟踪";//@"售后中";
            leftBtnStr = nil;
        }
            break;
        case 7: {
            rightBtnStr = @"再次购买";//@"已退货退款";
            leftBtnStr = nil;
        }
            break;
        case 8: {
            rightBtnStr = @"再次购买";//@"已换货";
            if ([[dict objectForKey:@"isHasEvaluation"] intValue] == 0) {
                leftBtnStr = @"晒单评价";
            } else if ([[dict objectForKey:@"isHasEvaluation"] intValue] == 1) {
                leftBtnStr = @"评价详情";
            } else {
                leftBtnStr = nil;
            }
        }
            break;
        case 9: {
            rightBtnStr = @"订单跟踪";//@"已支付";
            leftBtnStr = nil;
        }
            break;
        case 10: {
            rightBtnStr = @"再次购买";//@"关闭售后";
            if ([[dict objectForKey:@"isHasEvaluation"] intValue] == 0) {
                leftBtnStr = @"晒单评价";
            } else if ([[dict objectForKey:@"isHasEvaluation"] intValue] == 1) {
                leftBtnStr = @"评价详情";
            } else {
                leftBtnStr = nil;
            }
            break;
        }
        default:
            break;
    }
    
    if (rightBtnStr == nil) {
        rightBtn.hidden = YES;
    } else {
        [rightBtn setTitle:rightBtnStr forState:UIControlStateNormal];
        rightBtn.hidden = NO;
    }
    if (leftBtnStr == nil) {
        leftBtn.hidden = YES;
    } else {
        [leftBtn setTitle:leftBtnStr forState:UIControlStateNormal];
        leftBtn.hidden = NO;
    }
    
    YWWeakSelf;
    [[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        UIButton *button = (UIButton *)x;
        if ([button.currentTitle isEqualToString:@"再次购买"]) {
            
            NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
            NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
            [parameter setValue:userID forKey:@"userId"];
            [parameter setValue:[dict objectForKey:@"id"] forKey:@"orderId"];
            
            [HttpTools Post:kAppendUrl(YWCopyOrderShopCarString) parameters:parameter success:^(id responseObject) {
                [SVProgressHUD showSuccessWithStatus:@"成功添加商品到购物车"];
                
                ShopCarViewController *shopcarVC = [[ShopCarViewController alloc] init];
                [self.navigationController pushViewController:shopcarVC animated:YES];
            } failure:^(NSError *error) {
                
            }];
            
        }
    }];
    
    [[leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        UIButton *button = (UIButton *)x;
        if ([button.currentTitle isEqualToString:@"晒单评价"]) {
            
            NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
            NSMutableDictionary *idDic = [NSMutableDictionary dictionary];
            [idDic setValue:userID forKey:@"userId"];
            [idDic setValue:[dict objectForKey:@"id"] forKey:@"orderId"];
            
            [HttpTools Get:kAppendUrl(YWOrderNoCommentString) parameters:idDic success:^(id responseObject) {
                NSDictionary *orderDic = [responseObject objectForKey:@"resultData"];
                SetCommentViewController *setCommentVC = [[SetCommentViewController alloc] init];
                setCommentVC.orderDic = orderDic;
                [weakSelf.navigationController pushViewController:setCommentVC animated:YES];
            } failure:^(NSError *error) {
                
            }];
            
        }
    }];
    
    return backView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderListViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = _dataArray[indexPath.section];
    NSArray *array = [dict objectForKey:@"orderDetails"];
    [cell setDataWithDic:array[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrderDetailViewController *detailVC = [[OrderDetailViewController alloc] init];
    NSDictionary *dict = _dataArray[indexPath.section];
    detailVC.orderID = [dict objectForKey:@"id"];
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
