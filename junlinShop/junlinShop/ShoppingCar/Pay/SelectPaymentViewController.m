//
//  SelectPaymentViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/26.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "SelectPaymentViewController.h"
#import "SelectPaymentHeaderView.h"
#import "PayCompleteViewController.h"
#import "XianxiaPayViewController.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "MakeOrderViewController.h"

@interface SelectPaymentViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SelectPaymentHeaderView *headerView;

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic) BOOL hasPay;

@end

@implementation SelectPaymentViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                
        [self loadHeaderView];
        
        [self.view addSubview:_tableView];
    }
}

- (void)loadHeaderView {
    _headerView = [[[NSBundle mainBundle] loadNibNamed:@"SelectPaymentHeaderView" owner:nil options:nil] firstObject];
    _headerView.frame = CGRectMake(0, 0, kIphoneWidth, 255);
    _headerView.payMoneyLab.text = [NSString stringWithFormat:@"¥ %.2f", _payPrice];
    
    _tableView.tableHeaderView = _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"订单支付";
    
    
    
    
    _titleArray = [NSArray arrayWithObjects:@"微信支付", @"支付宝支付", @"银联支付", nil];
    _imageArray = [NSArray arrayWithObjects:@"pay_weixin", @"pay_zhifubao", @"pay_yinlian", @"pay_xianxia", nil];
    [self createTableView];
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    
    //如果想要设置title的话也可以在这里设置,就是给btn设置title
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backItemDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [YWNoteCenter addObserver:self selector:@selector(wechatPayFailed) name:kWeChatPayFailedNotification object:nil];
    [YWNoteCenter addObserver:self selector:@selector(wechatPayComplete) name:kWeChatPaySuccessNotification object:nil];

    [YWNoteCenter addObserver:self selector:@selector(AliPayComplete) name:@"kAliPayComplete" object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)backItemDidClick {
    if (!_hasPay) {
        [YWAlertView showNotice:@"还未完成支付，确认返回吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[MakeOrderViewController class]]) {
                    if(self.navigationController.childViewControllers.count > 1){
                        [self.navigationController popToViewController:self.navigationController.childViewControllers[1] animated:YES];
                    }else{
                       [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    return ;
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentTableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PaymentTableViewCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.textLabel.textColor = kBlackTextColor;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    cell.imageView.image = [UIImage imageNamed:_imageArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_payPrice == 0) {
        [self completePay];
        return;
    }
    
    if ([_titleArray[indexPath.row] isEqualToString:@"微信支付"]) {
        
        if ([WXApi isWXAppInstalled]) {
            
            NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
            [parameter setValue:@"android" forKey:@"deviceType"];
            [parameter setValue:_orderID forKey:@"orderId"];
            
            [SVProgressHUD show];
            [HttpTools Post:kAppendUrl(YWWeChatPayString) parameters:parameter success:^(id responseObject) {
                [SVProgressHUD dismiss];
                [self weiXinPayWithDic:[responseObject objectForKey:@"resultData"]];
                
            } failure:^(NSError *error) {
                NSLog(@"111");
                
            }];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"未安装微信App，无法进行微信支付"];
        }
        
        
    } else if ([_titleArray[indexPath.row] isEqualToString:@"支付宝支付"]) {
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
        NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
        [parameter setValue:userID forKey:@"userId"];
        [parameter setValue:_orderID forKey:@"orderId"];
        
        [SVProgressHUD show];
        [HttpTools Post:kAppendUrl(YWAliPayString) parameters:parameter success:^(id responseObject) {
            [SVProgressHUD dismiss];
            
            [[AlipaySDK defaultService] payOrder:[responseObject objectForKey:@"resultData"] fromScheme:@"AlipayJunLinFood" callback:^(NSDictionary *resultDic) {
                [self AliPayComplete];
            }];
            
        } failure:^(NSError *error) {
            NSLog(@"111");
            
        }];
        
    } else if ([_titleArray[indexPath.row] isEqualToString:@"银联支付"]) {
        
    } else {
        XianxiaPayViewController *xianxiaPay = [[XianxiaPayViewController alloc] init];
        
        [self.navigationController pushViewController:xianxiaPay animated:YES];
    }
    
}

- (void)weiXinPayWithDic:(NSDictionary *)wechatPayDic {
    PayReq *req = [[PayReq alloc] init];
    req.openID = [wechatPayDic objectForKey:@"appid"];
    req.partnerId = [wechatPayDic objectForKey:@"partnerid"];
    req.prepayId = [wechatPayDic objectForKey:@"prepayid"];
    req.package = [wechatPayDic objectForKey:@"package"];
    req.nonceStr = [wechatPayDic objectForKey:@"noncestr"];
    req.timeStamp = [[wechatPayDic objectForKey:@"timestamp"] intValue];
    req.sign = [wechatPayDic objectForKey:@"sign"];
    [WXApi sendReq:req];
    NSLog(@"111");
}
- (void)wechatPayFailed{
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    //    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [parameter setValue:@"iOS" forKey:@"deviceType"];
    [parameter setValue:_orderID forKey:@"orderId"];
    
    [SVProgressHUD show];
    [HttpTools Post:kAppendUrl(YWWeChatPayResultString) parameters:parameter success:^(id responseObject) {
        [SVProgressHUD dismiss];
        //        [self completePay];
        
        [self showPayResultWithSuccess:YES];
        
    } failure:^(NSError *error) {
        NSLog(@"111");
        
        [self showPayResultWithSuccess:NO];
        
    }];
}

- (void)wechatPayComplete {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
//    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [parameter setValue:@"iOS" forKey:@"deviceType"];
    [parameter setValue:_orderID forKey:@"orderId"];
    
    [SVProgressHUD show];
    [HttpTools Post:kAppendUrl(YWWeChatPayResultString) parameters:parameter success:^(id responseObject) {
        [SVProgressHUD dismiss];
//        [self completePay];
        
        [self showPayResultWithSuccess:YES];
        
    } failure:^(NSError *error) {
        NSLog(@"111");
        
        [self showPayResultWithSuccess:NO];
        
    }];
}

- (void)AliPayComplete {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    //    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    //    [parameter setValue:userID forKey:@"userId"];
    [parameter setValue:_orderID forKey:@"orderId"];
    
    [SVProgressHUD show];
    [HttpTools Post:kAppendUrl(YWAliPayResultString) parameters:parameter success:^(id responseObject) {
        [SVProgressHUD dismiss];
//        [self completePay];
        [self showPayResultWithSuccess:YES];
        
    } failure:^(NSError *error) {
        
        [self showPayResultWithSuccess:NO];
        
    }];
}

- (void)completePay {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [parameter setValue:userID forKey:@"userId"];
    [parameter setValue:_orderID forKey:@"orderId"];
    [parameter setValue:@"1" forKey:@"operation"];
    
    [SVProgressHUD show];
    [HttpTools Post:kAppendUrl(YWOrderCancleString) parameters:parameter success:^(id responseObject) {
        [SVProgressHUD dismiss];
       
        [self showPayResultWithSuccess:YES];
        
    } failure:^(NSError *error) {
        NSLog(@"111");
        [self showPayResultWithSuccess:NO];
    }];
}

- (void)showPayResultWithSuccess:(BOOL)isSuccess {
    PayCompleteViewController *completeVC = [[PayCompleteViewController alloc] init];
    completeVC.orderID = _orderID;
    completeVC.orderNum = _orderNum;
    completeVC.orderPrice = _payPrice;
    completeVC.isPaySuccess = isSuccess;
    [self.navigationController pushViewController:completeVC animated:YES];
}

- (void)dealloc {
    [YWNoteCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 

@end
