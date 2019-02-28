//
//  OrderListViewController.m
//  meirongApp
//
//  Created by jianxuan on 2017/11/28.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "OrderListViewController.h"
#import "SegmentSelectView.h"
#import "OrderListViewCell.h"
#import "OrderDetailViewController.h"
#import "SetCommentViewController.h"
#import "SelectPaymentViewController.h"
#import "OrderAddressStatusController.h"
#import "CommentDetailViewController.h"
#import "ShopCarViewController.h"
#import "NoticeCenterViewController.h"
#import "XianxiaPayViewController.h"

@interface OrderListViewController ()<SegmentSelectViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) NSMutableArray *allOrderArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *noticeBtn;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) NSInteger pageCount;

@end

@implementation OrderListViewController

- (void)showNoDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight - 50)];
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
    [self.allOrderArray removeAllObjects];
    [self.dataArray removeAllObjects];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dic setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWOrderListString) parameters:dic success:^(id responseObject) {
        [self.view stopLoading];
        for (NSDictionary *dict in [responseObject objectForKey:@"resultData"]) {
            [self.dataArray addObject:dict];
            [self.allOrderArray addObject:dict];
        }
        if (self.dataArray.count <= 10) {
            self.pageCount = self.dataArray.count;
        } else {
            self.pageCount = 10;
        }
        
        [self clickButton:nil AtIndex:_statusType];
        
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
    
    if ([[YWUserDefaults objectForKey:@"HasNotice"] integerValue] == 1) {
        _noticeBtn.badgeValue = @" ";
    } else {
        _noticeBtn.badgeValue = @"";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的订单";
    _pageIndex = 1;
    _dataArray = [NSMutableArray array];
    _allOrderArray = [NSMutableArray array];
    
    UIView *segmentBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 50)];
    segmentBackView.backgroundColor = kBackGrayColor;
    
    NSArray *segmentArray = @[@"全部", @"待支付", @"待收货", @"已完成", @"售后中"];
    
    SegmentSelectView *segmentView = [[SegmentSelectView alloc] initWithFrame:CGRectMake(1, 0, kIphoneWidth, 48) andTitleArray:segmentArray andImageNameArray:nil byType:SegmentViewTypeBottonLine];
    [segmentView srcollToSelectedBtnAtIndex:_statusType];
    segmentView.delegate = self;
    [segmentBackView addSubview:segmentView];
    
    [self.view addSubview:segmentBackView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderListViewCell" bundle:nil] forCellReuseIdentifier:@"OrderListViewCell"];
    
    [self.view startLoadingWithY:50 Height:kIphoneHeight - 50 - SafeAreaTopHeight];
    
    [self setNaviItem];
    
    YWWeakSelf;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.pageIndex ++;
        
        if (weakSelf.pageCount == weakSelf.dataArray.count) {
            
            [weakSelf.tableView.mj_footer performSelector:@selector(endRefreshingWithNoMoreData) withObject:nil/*可传任意类型参数*/ afterDelay:1.0];
            return ;
        }
        
        if (weakSelf.dataArray.count > weakSelf.pageIndex * 10) {
            weakSelf.pageCount = weakSelf.pageIndex * 10;
        } else {
            weakSelf.pageCount = weakSelf.dataArray.count;
        }
        [weakSelf performSelector:@selector(endRefreshingData) withObject:nil/*可传任意类型参数*/ afterDelay:1.0];
        
    }];
}

- (void)endRefreshingData {
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
}

- (void)setNaviItem {
    
    YWWeakSelf;
    _noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_noticeBtn setBackgroundImage:[UIImage imageNamed:@"shopcar_notice_icon"] forState:UIControlStateNormal];
    [[_noticeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NoticeCenterViewController *noticeVC = [[NoticeCenterViewController alloc] init];
        [weakSelf.navigationController pushViewController:noticeVC animated:YES];
    }];
    [_noticeBtn sizeToFit];
    
    UIBarButtonItem *item02 = [[UIBarButtonItem alloc] initWithCustomView:_noticeBtn];
    
    self.navigationItem.rightBarButtonItem = item02;
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    
    //如果想要设置title的话也可以在这里设置,就是给btn设置title
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backItemDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)backItemDidClick {
    
//    [YWNoteCenter postNotificationName:@"RefreshOrderNumber" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark SegmentSelectViewDelegate
- (void)clickButton:(UIButton *)button AtIndex:(NSInteger)index {
    NSLog(@"%ld", index);
    [_dataArray removeAllObjects];
    _pageIndex = 1;
    [self.tableView.mj_footer endRefreshing];
    
    _statusType = index;
    NSArray *statusArr = nil;
    if (index == 0) {
        statusArr = @[];
        [_dataArray addObjectsFromArray:_allOrderArray];
    }
    if (index == 1) {
        statusArr = @[@"0"];
    }
    if (index == 2) {
        statusArr = @[@"2"]; //, @"9"
    }
    if (index == 3) {
        statusArr = @[@"3"];
    }
    if (index == 4) {
        statusArr = @[@"6", @"7", @"8", @"10"];
    }
    
    for (NSDictionary *dic in _allOrderArray) {
        NSString *status = [NSString stringWithFormat:@"%@", [dic objectForKey:@"orderState"]];
        if ([statusArr containsObject:status]) {
            [_dataArray addObject:dic];
        }
    }
    
    if (_dataArray.count > 0) {
        [self.noDataView removeFromSuperview];
        
        if (self.dataArray.count <= 10) {
            self.pageCount = self.dataArray.count;
        } else {
            self.pageCount = 10;
        }
        
        [self.tableView reloadData];
    } else {
        [self showNoDataView];
    }
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _pageCount;
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
    NSArray *goods = [dict objectForKey:@"orderDetails"];
    NSDictionary *goodDict = goods.firstObject;
    priceLab.text = [NSString stringWithFormat:@"共计%@件商品 合计：¥%.2f（含运费¥%.2f）", goodDict[@"goodsQuantity"], (orderPrice + orderPostage), orderPostage];
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
            leftBtnStr = @"审核中";
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
        if ([button.currentTitle isEqualToString:@"支付"]) {
            
            if ([[dict objectForKey:@"orderPresentPrice"] floatValue] > 50000) {
                XianxiaPayViewController *xianxiaPay = [[XianxiaPayViewController alloc] init];
                xianxiaPay.payPrice = [[dict objectForKey:@"orderPresentPrice"] floatValue];
                xianxiaPay.orderID = [dict objectForKey:@"id"];
                xianxiaPay.orderNum = [dict objectForKey:@"orderNo"];
                xianxiaPay.isPay = YES;
                [weakSelf.navigationController pushViewController:xianxiaPay animated:YES];
            } else {
                SelectPaymentViewController *paymentVC = [[SelectPaymentViewController alloc] init];
                paymentVC.orderID = [dict objectForKey:@"id"];
                paymentVC.orderNum = [dict objectForKey:@"orderNo"];
                paymentVC.payPrice = [[dict objectForKey:@"orderPresentPrice"] floatValue];
                [weakSelf.navigationController pushViewController:paymentVC animated:YES];
            }
        } else if ([button.currentTitle isEqualToString:@"订单跟踪"]) {
            
            OrderAddressStatusController *statusVC = [[OrderAddressStatusController alloc] init];
            statusVC.orderID = [dict objectForKey:@"id"];
            [weakSelf.navigationController pushViewController:statusVC animated:YES];
            
        } else if ([button.currentTitle isEqualToString:@"再次购买"]) {
            
            NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
            NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
            [parameter setValue:userID forKey:@"userId"];
            [parameter setValue:[dict objectForKey:@"id"] forKey:@"orderId"];
            
            [HttpTools Post:kAppendUrl(YWCopyOrderShopCarString) parameters:parameter success:^(id responseObject) {
                [SVProgressHUD showSuccessWithStatus:@"成功添加商品到购物车"];
                
                ShopCarViewController *shopcarVC = [[ShopCarViewController alloc] init];
                [weakSelf.navigationController pushViewController:shopcarVC animated:YES];
                
            } failure:^(NSError *error) {

            }];
            
        }
    }];

    [[leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        UIButton *button = (UIButton *)x;
        if ([button.currentTitle isEqualToString:@"评价详情"]) {
            CommentDetailViewController *detailVC = [[CommentDetailViewController alloc] init];

            detailVC.orderNum = [dict objectForKey:@"id"];
            
            [weakSelf.navigationController pushViewController:detailVC animated:YES];
        } else if ([button.currentTitle isEqualToString:@"晒单评价"]) {
            
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
        } else if ([button.currentTitle isEqualToString:@"确认收货"]) {
            
            [YWAlertView showNotice:@"确认收货吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
                NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
                NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
                [parameter setValue:userID forKey:@"userId"];
                [parameter setValue:[dict objectForKey:@"id"] forKey:@"orderId"];
                [parameter setValue:@"3" forKey:@"operation"];
                
                [SVProgressHUD show];
                [HttpTools Post:kAppendUrl(YWOrderCancleString) parameters:parameter success:^(id responseObject) {
                    [SVProgressHUD showSuccessWithStatus:@"确认成功"];
                    [weakSelf requestOrderList];
                } failure:^(NSError *error) {
                    
                }];
                
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

- (void)dealloc {
    NSLog(@"%@ _ dealloc", NSStringFromClass([self class]));
}

@end
