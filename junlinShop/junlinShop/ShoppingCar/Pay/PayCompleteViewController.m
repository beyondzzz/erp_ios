//
//  PayCompleteViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/26.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "PayCompleteViewController.h"
#import "OrderDetailViewController.h"
#import "XianxiaPayViewController.h"

@interface PayCompleteViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;

@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;

@end

@implementation PayCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"支付结果";
    [_leftBtn setBorder:kGrayTextColor width:1 radius:5.f];
    [_rightBtn setBorder:kBackGreenColor width:1 radius:5.f];
    
    if (_isPaySuccess) {
        _statusLabel.text = @"支付成功";
        _statusImageView.image = [UIImage imageNamed:@"pay_success"];
        _detailLab.text = [NSString stringWithFormat:@"您的订单（订单号：%@）已支付成功并提交仓库备货", _orderNum];
        [_leftBtn setTitle:@"返回首页" forState:UIControlStateNormal];
        [_rightBtn setTitle:@"查看订单" forState:UIControlStateNormal];
    } else {
        _statusLabel.text = @"支付失败";
        _statusImageView.image = [UIImage imageNamed:@"pay_false"];
        _detailLab.text = [NSString stringWithFormat:@"您的订单（订单号：%@）支付失败，请重新支付", _orderNum];
        [_leftBtn setTitle:@"线下支付" forState:UIControlStateNormal];
        [_rightBtn setTitle:@"继续支付" forState:UIControlStateNormal];
    }
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    
    //如果想要设置title的话也可以在这里设置,就是给btn设置title
    [btn sizeToFit];
    [btn addTarget:self action:@selector(clickBackItem) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
 }

- (void)clickBackItem {
    if (!_isPaySuccess) {
        WeakSelf
        [YWAlertView showNotice:@"订单支付失败，确认返回吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            [weakSelf gotoOrderDetailVC];
        }];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void)gotoOrderDetailVC{
    OrderDetailViewController *detailVC = [[OrderDetailViewController alloc] init];
//    NSDictionary *dict = _dataArray[indexPath.section];
    detailVC.orderID = _orderID;
    detailVC.toRoot = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (IBAction)clickLeftButton:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"返回首页"]) {
//
        [YWNoteCenter postNotificationName:@"goToHomeController" object:nil];
        [self clickBackItem];
    } else if ([sender.currentTitle isEqualToString:@"线下支付"]) {
        XianxiaPayViewController *xianxiaPay = [[XianxiaPayViewController alloc] init];
//        xianxiaPay.payPrice = ;
        xianxiaPay.orderID = _orderID;
        xianxiaPay.orderNum = _orderNum;
        xianxiaPay.payPrice = _orderPrice;
        xianxiaPay.isPay = YES;
        [self.navigationController pushViewController:xianxiaPay animated:YES];
    }
}

- (IBAction)clickRightButton:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"查看订单"]) {
        OrderDetailViewController *orderVC = [[OrderDetailViewController alloc] init];
        orderVC.orderID = _orderID;
        [self.navigationController pushViewController:orderVC animated:YES];
    } else if ([sender.currentTitle isEqualToString:@"继续支付"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 

@end
