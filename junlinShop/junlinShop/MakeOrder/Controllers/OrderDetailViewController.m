//
//  OrderDetailViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderAddressStatusController.h"
#import "OrderListViewCell.h"
#import "OrderDetailHeaderView.h"
#import "OrderDetailFooterView.h"
#import "OrderDetailBottomView.h"
#import "SetCommentViewController.h"
#import "SelectPaymentViewController.h"
#import "OrderAddressStatusController.h"
#import "YWWebViewController.h"
#import "CustomerServiceViewController.h"
#import "LookCustomerServiceViewController.h"
#import "CommentDetailViewController.h"
#import "ShopCarViewController.h"
#import "YWCountdownView.h"
#import "XianxiaPayViewController.h"

@interface OrderDetailViewController () <UITableViewDelegate, UITableViewDataSource, YWCountdownViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *detailDic;
@property (nonatomic, strong) YWCountdownView *countDownView;

@property (nonatomic, strong) OrderDetailHeaderView *headerView;
@property (nonatomic, strong) OrderDetailFooterView *footerView;
@property (nonatomic, strong) OrderDetailBottomView *bottomView;

@end

@implementation OrderDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"订单详情";
    
    [self createTableView];
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    
    
    [self requestData];
    
    if (!_toRoot) return;
    
    NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.childViewControllers];
    NSLog(@"数量%lu",(unsigned long)vcs.count);
    
    while (vcs.count > 2) {
        [vcs removeObjectAtIndex:1];
    }
    
    [self.navigationController setViewControllers:vcs];
    
}



- (YWCountdownView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[[NSBundle mainBundle] loadNibNamed:@"YWCountdownView" owner:nil options:nil] firstObject];
        _countDownView.delegate = self;
        _countDownView.frame = CGRectMake(88, 15, 80, 20);
    }
    return _countDownView;
}

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight - 40) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        adjustsScrollViewInsets(_tableView);
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"OrderListViewCell" bundle:nil] forCellReuseIdentifier:@"OrderGoodsListTableCell"];
        
        _headerView = [[[NSBundle mainBundle] loadNibNamed:@"OrderDetailHeaderView" owner:nil options:nil] lastObject];
        _headerView.frame = CGRectMake(0, 0, kIphoneWidth, 184);
        
        [_tableView setTableHeaderView:_headerView];
        
        _footerView = [[[NSBundle mainBundle] loadNibNamed:@"OrderDetailFooterView" owner:nil options:nil] lastObject];
        _footerView.frame = CGRectMake(0, 0, kIphoneWidth, 160);
        
        [_tableView setTableFooterView:_footerView];
        
        [self.view addSubview:_tableView];
        
        _bottomView = [[[NSBundle mainBundle] loadNibNamed:@"OrderDetailBottomView" owner:nil options:nil] lastObject];
        [self.view addSubview:_bottomView];
        
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@40);
        }];
        
    }
}

- (void)addBottomClickTarget {
    
    YWWeakSelf;
    [[_bottomView.deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        UIButton *button = (UIButton *)x;
        NSString *operation = nil;
        NSString *noticeStr = nil;
        if ([button.currentTitle isEqualToString:@"取消订单"]) {
            operation = @"4";
            noticeStr = @"确认取消订单吗？";
        } else if ([button.currentTitle isEqualToString:@"删除订单"]) {
            operation = @"11";
            noticeStr = @"确认删除订单吗？";
        } else if ([button.currentTitle isEqualToString:@"确认收货"]) {
            operation = @"3";
            noticeStr = @"确认收货吗？";
        }
        
        [YWAlertView showNotice:noticeStr WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            
            NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
            NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
            [parameter setValue:userID forKey:@"userId"];
            [parameter setValue:[weakSelf.detailDic objectForKey:@"id"] forKey:@"orderId"];
            [parameter setValue:operation forKey:@"operation"];
            
            [SVProgressHUD show];
            [HttpTools Post:kAppendUrl(YWOrderCancleString) parameters:parameter success:^(id responseObject) {
                [SVProgressHUD showSuccessWithStatus:@"操作成功"];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                
            }];
            
        }];
        
    }];
    
    [[_bottomView.leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        UIButton *button = (UIButton *)x;
        [weakSelf MakeSureDataWithTitle:button.currentTitle];
    }];
    
    [[_bottomView.centerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        UIButton *button = (UIButton *)x;
        [weakSelf MakeSureDataWithTitle:button.currentTitle];
    }];
    
    [[_bottomView.rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        UIButton *button = (UIButton *)x;
        [weakSelf MakeSureDataWithTitle:button.currentTitle];
    }];
}

- (void)MakeSureDataWithTitle:(NSString *)title {
    
    if ([title isEqualToString:@"支付"]) {
        
        if ([[_detailDic objectForKey:@"orderPresentPrice"] floatValue] > 50000) {
            XianxiaPayViewController *xianxiaPay = [[XianxiaPayViewController alloc] init];
            xianxiaPay.payPrice = [[_detailDic objectForKey:@"orderPresentPrice"] floatValue];
            xianxiaPay.orderID = [_detailDic objectForKey:@"id"];
            xianxiaPay.orderNum = [_detailDic objectForKey:@"orderNo"];
            xianxiaPay.isPay = YES;
            [self.navigationController pushViewController:xianxiaPay animated:YES];
        } else {
            SelectPaymentViewController *paymentVC = [[SelectPaymentViewController alloc] init];
            paymentVC.orderID = [_detailDic objectForKey:@"id"];
            paymentVC.orderNum = [_detailDic objectForKey:@"orderNo"];
            paymentVC.payPrice = [[_detailDic objectForKey:@"orderPresentPrice"] floatValue];
            [self.navigationController pushViewController:paymentVC animated:YES];
        }
        
    } else if ([title isEqualToString:@"订单跟踪"]) {
        
        OrderAddressStatusController *statusVC = [[OrderAddressStatusController alloc] init];
        statusVC.orderID = [_detailDic objectForKey:@"id"];
        [self.navigationController pushViewController:statusVC animated:YES];
        
    } else if ([title isEqualToString:@"再次购买"]) {
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
        NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
        [parameter setValue:userID forKey:@"userId"];
        [parameter setValue:[_detailDic objectForKey:@"id"] forKey:@"orderId"];
        
        [HttpTools Post:kAppendUrl(YWCopyOrderShopCarString) parameters:parameter success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"成功添加商品到购物车"];
            
            ShopCarViewController *shopcarVC = [[ShopCarViewController alloc] init];
            [self.navigationController pushViewController:shopcarVC animated:YES];
            
        } failure:^(NSError *error) {
            
        }];
        
    } else if ([title isEqualToString:@"评价详情"]) {
        CommentDetailViewController *detailVC = [[CommentDetailViewController alloc] init];
        
        detailVC.orderNum = [_detailDic objectForKey:@"id"];
        
        [self.navigationController pushViewController:detailVC animated:YES];
    } else if ([title isEqualToString:@"晒单评价"]) {
        NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
        NSMutableDictionary *idDic = [NSMutableDictionary dictionary];
        [idDic setValue:userID forKey:@"userId"];
        [idDic setValue:[_detailDic objectForKey:@"id"] forKey:@"orderId"];
        
        [HttpTools Get:kAppendUrl(YWOrderNoCommentString) parameters:idDic success:^(id responseObject) {
            NSDictionary *orderDic = [responseObject objectForKey:@"resultData"];
            SetCommentViewController *setCommentVC = [[SetCommentViewController alloc] init];
            setCommentVC.orderDic = orderDic;
            [self.navigationController pushViewController:setCommentVC animated:YES];
        } failure:^(NSError *error) {
            
        }];
    } else if ([title isEqualToString:@"联系客服"]) {
        
//        YWWebViewController *webVC = [[YWWebViewController alloc] init];
//        NSDictionary *dict = [YWUserDefaults objectForKey:@"UserInfo"];
//        webVC.titleStr = @"客服服务";
//        webVC.webURL = [NSString stringWithFormat:@"%@%@&userName=%@&isVip=%@&clientId=%@", YWServiceHtmlString, [dict objectForKey:@"userPhone"],  [dict objectForKey:@"userName"], [dict objectForKey:@"isVIP"], [dict objectForKey:@"userId"]];
//        [self.navigationController pushViewController:webVC animated:YES];
        NSMutableString *str= [[NSMutableString alloc]initWithFormat:@"tel:%@",@"010-86488182"];
        
        UIWebView *callWebview = [[UIWebView alloc]init];
        
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        
        [self.view addSubview:callWebview];
        
    } else if ([title isEqualToString:@"查看售后"]) {
        LookCustomerServiceViewController *serviceVC = [[LookCustomerServiceViewController alloc] init];
        serviceVC.orderID = [_detailDic objectForKey:@"id"];
        [self.navigationController pushViewController:serviceVC animated:YES];
    }
}

- (void)requestData {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setValue:_orderID forKey:@"orderId"];
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dic setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWOrderDetailString) parameters:dic success:^(id responseObject) {
        
        _detailDic = [responseObject objectForKey:@"resultData"];
        [_tableView reloadData];
        [self setDataToHeaderView];
        [self setDataToFooterView];
        [self setDataToBottomView];
        [self addBottomClickTarget];
        
        [self.view stopLoading];
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf requestData];
        }];
    }];
}

- (void)setDataToBottomView {
    NSInteger status = [[_detailDic objectForKey:@"orderState"] integerValue];
    NSString *deleBtnStr = nil;
    NSString *leftBtnStr = nil;
    NSString *centerBtnStr = nil;
    NSString *rightBtnStr = nil;
    
    _bottomView.deleteBtn.hidden = NO;
    _bottomView.leftBtn.hidden = NO;
    _bottomView.centerBtn.hidden = NO;
    _bottomView.rightBtn.hidden = NO;
    switch (status) {
        case 0:
            deleBtnStr = @"取消订单";
            rightBtnStr = @"支付";
            centerBtnStr = @"联系客服";
            leftBtnStr = nil;
            break;
        case 1:
        case 2:
        case 9:
            if (status == 2) {
                deleBtnStr = @"确认收货";
            }
            rightBtnStr = @"订单跟踪";
            centerBtnStr = @"联系客服";
            leftBtnStr = nil;
            break;
        case 3:
            deleBtnStr = @"删除订单";
            rightBtnStr = @"再次购买";
            if ([[_detailDic objectForKey:@"isHasEvaluation"] intValue] == 0) {
                centerBtnStr = @"晒单评价";
            } else if ([[_detailDic objectForKey:@"isHasEvaluation"] intValue] == 1) {
                centerBtnStr = @"评价详情";
            }
            leftBtnStr = @"联系客服";
            break;
        case 4:
        case 5:
            deleBtnStr = @"删除订单";
            rightBtnStr = @"再次购买";
            centerBtnStr = @"联系客服";
            leftBtnStr = nil;
            break;
        case 6:
        case 7:
        case 8:
        case 10:
            deleBtnStr = nil;
            rightBtnStr = @"查看售后";
            centerBtnStr = @"联系客服";
            leftBtnStr = nil;
            break;
        default:
            break;
    }
    
    if (deleBtnStr == nil) {
        _bottomView.deleteBtn.hidden = YES;
    } else {
        [_bottomView.deleteBtn setTitle:deleBtnStr forState:UIControlStateNormal];
    }
    if (rightBtnStr == nil) {
        _bottomView.rightBtn.hidden = YES;
    } else {
        [_bottomView.rightBtn setTitle:rightBtnStr forState:UIControlStateNormal];
    }
    if (centerBtnStr == nil) {
        _bottomView.centerBtn.hidden = YES;
    } else {
        [_bottomView.centerBtn setTitle:centerBtnStr forState:UIControlStateNormal];
    }
    if (leftBtnStr == nil) {
        _bottomView.leftBtn.hidden = YES;
    } else {
        [_bottomView.leftBtn setTitle:leftBtnStr forState:UIControlStateNormal];
    }
}

- (void)setDataToHeaderView {
    NSInteger status = [[_detailDic objectForKey:@"orderState"] integerValue];
    NSString *statusStr = nil;
    NSString *statusImageName = nil;
    
    _headerView.rightBtn.hidden = YES;
    _headerView.noticeLab.hidden = YES;
    
    switch (status) {
        case 0:
            statusStr = @"待支付";
            statusImageName = @"orderDetail_zhifu";
            _headerView.noticeLab.hidden = NO;
            
            NSTimeInterval time = 0;
            for (NSDictionary *dict in [_detailDic objectForKey:@"orderStateDetails"]) {
                if ([[dict objectForKey:@"status"] integerValue] == 0) {
                    NSString *payDate = [ASHString jsonDateToString:[dict objectForKey:@"addTime"] withFormat:@"yyyy-MM-dd HH:mm:ss"];
                    time = [[NSDate date] timeIntervalSinceDate:[ASHString NSStringToDate:payDate]];
                }
            }
            
            NSTimeInterval maxTime = 0;
            if ([[_detailDic objectForKey:@"postagePayType"] integerValue] == 1) {
                maxTime = 24 * 60 * 60;
            } else {
                maxTime = 4 * 60 * 60;
            }
            if (time < maxTime) {
                [self.headerView.statusLab.superview addSubview: self.countDownView];
                [self.countDownView setToEndTime:maxTime - time];
            } else {
                [self countdownViewTimeCountToZero:nil];
            }
            
            
            break;
        case 1:
            statusStr = @"待发货";
            statusImageName = @"orderDetail_shouhuo";
            break;
        case 2:
        case 9:
            statusStr = @"待收货";
            statusImageName = @"orderDetail_shouhuo";
            break;
        case 3:
            statusStr = @"已完成";
            statusImageName = @"orderDetail_wancheng";
            _headerView.rightBtn.hidden = NO;
            break;
        case 4:
        case 5:
            statusStr = @"已取消";
            statusImageName = @"orderDetail_quxiao";
            break;
        case 6:
        case 7:
        case 8:
        case 10:
            statusStr = @"售后中";
            statusImageName = @"orderDetail_shouhou";
            break;
        default:
            break;
    }
    _headerView.statusLab.text = statusStr;
    _headerView.statusImageView.image = [UIImage imageNamed:statusImageName];
    
    NSArray *statusArr = [_detailDic objectForKey:@"orderStateDetails"];
    if (statusArr.count > 0) {
        NSDictionary *dic = [statusArr lastObject];
        _headerView.status02Lab.text = [dic objectForKey:@"orderStateDetail"];
        _headerView.timeLab.text = [ASHString jsonDateToString:[dic objectForKey:@"addTime"] withFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    if (status == 1) {
        _headerView.status02Lab.text = @"待发货";
    }
    
    YWWeakSelf;
    [[_headerView.rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        CustomerServiceViewController *customerVC = [[CustomerServiceViewController alloc] init];
        customerVC.orderDic = weakSelf.detailDic;
        [weakSelf.navigationController pushViewController:customerVC animated:YES];
    }];
    
    [[_headerView.statusAllBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        OrderAddressStatusController *statusVC = [[OrderAddressStatusController alloc] init];
        statusVC.orderID = weakSelf.orderID;
        [weakSelf.navigationController pushViewController:statusVC animated:YES];
    }];
    
    _headerView.addressNameLab.text = [_detailDic objectForKey:@"consigneeName"];
    _headerView.addPhoneLab.text = [_detailDic objectForKey:@"consigneeTel"];
    _headerView.addressLab.text = [_detailDic objectForKey:@"consigneeAddress"];
}

- (void)setDataToFooterView {
    _footerView.orderNumLab.text = [_detailDic objectForKey:@"orderNo"];
    _footerView.startTimeLab.text = [ASHString jsonDateToString:[_detailDic objectForKey:@"placeOrderTime"] withFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDictionary *invoiceDic = [_detailDic objectForKey:@"invoice"];
    if (invoiceDic && [invoiceDic isKindOfClass:[NSDictionary class]]) {
        NSString *invoiceType = nil;
        if ([[invoiceDic objectForKey:@"invoiceType"] integerValue] == 1) {
            invoiceType = @"增值税发票";
        } else {
            invoiceType = @"普通发票";
        }
        NSString *invoiceLookedUpType = nil;
        if ([[invoiceDic objectForKey:@"invoiceLookedUpType"] integerValue] == 1) {
            invoiceLookedUpType = @"个人";
        } else {
            invoiceLookedUpType = @"单位";
        }
        _footerView.invoiceInfoLab.text = [NSString stringWithFormat:@"%@-%@", invoiceType, invoiceLookedUpType];
    } else {
        _footerView.invoiceInfoLab.text = @"未开发票";
    }
    NSDictionary *paymentDic = [_detailDic objectForKey:@"offlinePayment"];
    if (paymentDic && [paymentDic isKindOfClass:[NSDictionary class]]) {
        _footerView.payTypeLab.text = @"线下支付";
    } else {
        _footerView.payTypeLab.text = @"线上支付";
    }
    
    if ([[_detailDic objectForKey:@"orderState"] integerValue] == 0) {
        _footerView.payTimeLab.hidden = YES;
        _footerView.payTypeLab.hidden = YES;
    } else {
        
        _footerView.payTimeLab.hidden = NO;
        _footerView.payTypeLab.hidden = NO;
        
        if ([[_detailDic objectForKey:@"orderStateDetails"] isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dict in [_detailDic objectForKey:@"orderStateDetails"]) {
                if ([[dict objectForKey:@"orderStateDetail"] containsString:@"订单支付成功"]) {
                    _footerView.payTimeLab.text = [ASHString jsonDateToString:[dict objectForKey:@"addTime"] withFormat:@"yyyy-MM-dd HH:mm"];
                }
            }
        }
    }
}



#pragma mark YWCountdownView代理
- (void)countdownViewTimeCountToZero:(YWCountdownView *)countdownView {
    [_countDownView removeFromSuperview];
    NSMutableDictionary *dict = [_detailDic mutableCopy];
    [dict setValue:@(4) forKey:@"orderState"];
    
    self.detailDic = dict;
    
    [self setDataToHeaderView];
    [self setDataToFooterView];
    [self setDataToBottomView];
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_detailDic objectForKey:@"orderDetails"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 45;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    CGFloat height = 44;
    //    CGFloat height = [self getListCellHeightWithIndex:section];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, height)];
    backView.backgroundColor = [UIColor whiteColor];
    
    CGFloat orderPrice = [[_detailDic objectForKey:@"orderPresentPrice"] floatValue];
    CGFloat orderPostage = 0;
    if ([_detailDic objectForKey:@"postage"]) {
        orderPostage = [[_detailDic objectForKey:@"postage"] floatValue];
    }
    
    UILabel *priceLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, kIphoneWidth - 20 , 20)];
    priceLab.textColor = kBlackTextColor;
    priceLab.font = [UIFont systemFontOfSize:15.f];
    
    NSArray *goods = [_detailDic objectForKey:@"orderDetails"];
    NSDictionary *goodDict = goods.firstObject;
    priceLab.text = [NSString stringWithFormat:@"共计%@件商品 合计：¥%.2f（含运费¥%.2f）", goodDict[@"goodsQuantity"], (orderPrice + orderPostage), orderPostage];
    priceLab.textAlignment = NSTextAlignmentRight;
    [backView addSubview:priceLab];
    
    return backView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderGoodsListTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *array = [_detailDic objectForKey:@"orderDetails"];
    [cell setDataWithDic:array[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%@ _ dealloc", NSStringFromClass([self class]));
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
