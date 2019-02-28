//
//  MakeOrderViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2017/12/5.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "MakeOrderViewController.h"
#import "MakeOrderHeaderView.h"
#import "AddressListViewController.h"
#import "MakeOrderGoodsListCell.h"
#import "SettleAccountsView.h"
#import "OrderSelectTimeView.h"
#import "YouHuiQuanListController.h"
#import "SelectInvoiceViewController.h"
#import "YWAlertView.h"
#import "SelectPaymentViewController.h"
#import "XianxiaPayViewController.h"
#import "ActiveSelectView.h"
#import "ComputeOrderAmountManager.h"
#import <CoreLocation/CoreLocation.h>

@interface MakeOrderViewController ()<UITableViewDelegate, UITableViewDataSource>


/** 地理编码管理器 */
@property (nonatomic, strong) CLGeocoder *geoC;


//配送商家地址
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
//选中地址
@property (nonatomic, assign) double selectedLatitude;
@property (nonatomic, assign) double selectedLongitude;
@property (nonatomic, assign) double distance;


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MakeOrderHeaderView *orderHeaderView;
@property (nonatomic, strong) SettleAccountsView *accountView;

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSDictionary *payDic;
@property (nonatomic, strong) NSString *expressTimeStr;
@property (nonatomic, strong) NSDictionary *invoiceDic;
@property (nonatomic) BOOL isNarmolInvoice;
@property (nonatomic) BOOL isInvoiceGeren;
@property (nonatomic) BOOL isInvoiceGoods;

@property (nonatomic, strong) NSDictionary *youHuiQuanDic;
@property (nonatomic, strong) NSDictionary *activeDic;
@property (nonatomic, strong) NSNumber *goodsPostage; //邮费
@property (nonatomic, assign) NSInteger postageTpye; //邮费方式
@property (nonatomic, strong) NSMutableArray *availableActiveArray;
@property (nonatomic, strong) NSMutableArray *availableYouhuiquanArray;

//优惠券是否可用
@property (nonatomic, assign)  BOOL isCouponAvailable;

@property (nonatomic, assign) CGFloat totalPrice;

@end

@implementation MakeOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"订单填写";
    self.isCouponAvailable = YES;
    
    _goodsPostage = @(0);
    YWWeakSelf;
    _accountView = [SettleAccountsView initWithButtonTitle:@"提交订单" hasTabBar:NO];
    _accountView.totlePriceLab.text = _orderPrice;
    [[_accountView.accountsBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        [weakSelf checkoutDecisionInventory];
    }];
    
    [self.view addSubview:_accountView];
    
    _titleArray = @[@"支付方式", @"配送时间", @"发票", @"优惠券"];
    for (NSDictionary *goodDic in _goodsArray) {
        if ([[goodDic objectForKey:@"specActArray"] count] > 0) {
            _titleArray = @[@"支付方式", @"配送时间", @"发票", @"优惠券", @"活动"];
        }
    }
    if (_yuShouActiveId) {
        _titleArray = @[@"支付方式", @"配送时间", @"发票", @"优惠券", @"活动"];
        NSMutableArray *activeArr = [NSMutableArray array];
        for (NSDictionary *dic in _goodsArray) {
            [activeArr addObjectsFromArray:[dic objectForKey:@"specActArray"]];
        }
        _activeDic = [activeArr firstObject];
    }
    
    [self createTableView];
    [self requestAddressData];
    
    if (_yuShouActiveId) {
        [self isShowTips:YES andTipsString:@"温馨提示：您的订单中含有预售商品，预售商品的送货时间以商家到货时间为准，感谢您的支持"];
    } else {
        if ([_orderPrice integerValue] > 50000) {
            [self isShowTips:YES andTipsString:nil];
        } else {
            [self isShowTips:NO andTipsString:nil];
        }
    }
    
    
    [self caulateDistance];
    [self requestCanUseCoupon];
}
#pragma mark - 地址
- (void)requestAddressData {
    if (_addressModel) {
        [self setAddressDataWithModel:_addressModel];
        return;
    }
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWAddressListString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        NSArray *dataArr = [responseObject objectForKey:@"resultData"];
        if (dataArr.count) {
            
            for (NSDictionary *addressDic in dataArr) {
                if ([[addressDic objectForKey:@"isCommonlyUsed"] integerValue] == 1) {
                    [self.addressModel mj_setKeyValues:addressDic];
                }
            }
            
            if (!self.addressModel.ID) {
                NSDictionary *addressDic = [dataArr firstObject];
                [self.addressModel mj_setKeyValues:addressDic];
            }
            
        }
        [self setAddressDataWithModel:_addressModel];
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf requestAddressData];
        }];
        [self setAddressDataWithModel:nil];
    }];
}

- (void)requestAddressPostage {
    
    CGFloat goodsPrice = 0;
    for (NSDictionary *goodsDic in _goodsArray) {
        CGFloat price = [[goodsDic objectForKey:@"goodsOriginalPrice"] floatValue];
        NSInteger count = [[goodsDic objectForKey:@"goodsQuantity"] integerValue];
        goodsPrice += price * count;
    }
    _orderPrice = [NSString stringWithFormat:@"%.2f", goodsPrice];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_addressModel.provinceCode forKey:@"provinceCode"];
    if ([ASHValidate isBlankString:_addressModel.cityCode]) {
        [dict setValue:@"0" forKey:@"cityCode"];
    } else {
        [dict setValue:_addressModel.cityCode forKey:@"cityCode"];
    }
    [dict setValue:_addressModel.countyCode forKey:@"countyCode"];
    [dict setValue:_addressModel.ringCode forKey:@"ringCode"];
    [dict setValue:_orderPrice forKey:@"orderMoney"];
    
    [HttpTools Get:kAppendUrl(YWGetPostageString) parameters:dict success:^(id responseObject) {
        if ([[responseObject objectForKey:@"code"] intValue] == 200) {
            _goodsPostage = [responseObject objectForKey:@"resultData"];
            _accountView.carriage = [_goodsPostage floatValue];
            _postageTpye = 0;
        }
        [self realityTotalPrice];
        
    } failure:^(NSError *error) {
        NSDictionary *dict = error.userInfo;
        if ([[dict objectForKey:@"code"] intValue] == 13001) {
            _accountView.carriage = -1.f;
            _goodsPostage = 0;
            _postageTpye = 1;
        }else{
            
        }
        [self realityTotalPrice];
    }];
}

- (void)setAddressDataWithModel:(AddressModel *)model {
    if (model.ID) {
        _orderHeaderView.addressNameLab.text = model.consigneeName;
        _orderHeaderView.addressPhoneLab.text = model.consigneeTel;
        _orderHeaderView.addressLab.text = [NSString stringWithFormat:@"%@ %@", model.region, model.detailedAddress];
        _orderHeaderView.morenLab.hidden = NO;
        [self caulateDistance];
//        [self requestAddressPostage];
    } else {
        _orderHeaderView.addressNameLab.text = @"暂无收货人";
        _orderHeaderView.addressPhoneLab.text = @"";
        _orderHeaderView.addressLab.text = @"还没添加收货地址呢，赶紧添加";
        _orderHeaderView.morenLab.hidden = YES;
    }
}

- (AddressModel *)addressModel {
    if (!_addressModel) {
        _addressModel = [[AddressModel alloc] init];
    }
    return _addressModel;
}


- (void)updateTotalPriceView{
    
    if (!_yuShouActiveId) {
        if (self.totalPrice > 50000) {
            [self isShowTips:YES andTipsString:nil];
        } else {
            [self isShowTips:NO andTipsString:nil];
        }
    }
    
    NSString *totlePrices = [NSString stringWithFormat:@"¥%.2f", self.totalPrice];
    _accountView.totlePriceLab.text = totlePrices;
}

//实际支付
- (CGFloat)realityTotalPrice{
   
    CGFloat totlePrice = 0;
 
    if (_activeDic) {
        for (NSDictionary *dic in _goodsArray) {
            if ([[dic objectForKey:@"goodsSpecificationDetailsId"] isEqual:[_activeDic objectForKey:@"goodsId"]]) {
                CGFloat activePrice = [ComputeOrderAmountManager computActiveGoodsPriceWithDic:dic andActiveDic:[_activeDic objectForKey:@"activityInformation"]];
                totlePrice += activePrice;
            } else {
                CGFloat price = [[dic objectForKey:@"goodsOriginalPrice"] floatValue];
                NSInteger count = [[dic objectForKey:@"goodsQuantity"] integerValue];
                totlePrice += (price * count);
            }
        }
    } else {
        for (NSDictionary *dic in _goodsArray) {
            CGFloat price = [[dic objectForKey:@"goodsOriginalPrice"] floatValue];
            NSInteger count = [[dic objectForKey:@"goodsQuantity"] integerValue];
            totlePrice += (price * count);
        }
    }
    
    //邮费
    totlePrice += [_goodsPostage floatValue];
    
    if (_youHuiQuanDic) {
        CGFloat youhuiPrice = [[[_youHuiQuanDic objectForKey:@"couponInformation"] objectForKey:@"price"] floatValue];
        CGFloat useLimit = [[[_youHuiQuanDic objectForKey:@"couponInformation"] objectForKey:@"useLimit"] floatValue];
        if (totlePrice >= useLimit) {
            totlePrice -= youhuiPrice;
            self.isCouponAvailable = YES;
        }else{
            self.isCouponAvailable = NO;
        }
    }
 
    
    self.totalPrice = totlePrice;
    [self updateTotalPriceView];
    
    return totlePrice;
}

#pragma mark - 其他
- (void)isShowTips:(BOOL)isShow andTipsString:(NSString *)tips {
    if (isShow) {
        _orderHeaderView.frame = CGRectMake(0, 0, kIphoneWidth, 135);
        _orderHeaderView.tipsBackView.hidden = NO;
        _orderHeaderView.addressTopConstaint.constant = 55;
        _tableView.tableHeaderView = _orderHeaderView;
        if (tips) {
            _orderHeaderView.tipsLab.text = tips;
        }
        
    } else {
        _orderHeaderView.frame = CGRectMake(0, 0, kIphoneWidth, 80);
        _orderHeaderView.tipsBackView.hidden = YES;
        _orderHeaderView.addressTopConstaint.constant = 0;
        _tableView.tableHeaderView = _orderHeaderView;
    }
}

#pragma mark - 支付参数
- (NSString *)getOrderJsonString {
    
    CGFloat price = [self realityTotalPrice];
    if (price > 50000 && _payDic == nil) {
        [SVProgressHUD showInfoWithStatus:@"订单金额超过50000元，只能进行线下支付"];
        XianxiaPayViewController *xianxiaPay = [[XianxiaPayViewController alloc] init];
        xianxiaPay.completePay = ^(NSString *payerName, NSString *payerTel) {
            _payDic = @{@"payerName":payerName, @"payerTel":payerTel};
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:xianxiaPay animated:YES];
        return nil;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dict setValue:userID forKey:@"userId"];
    
    if (!_addressModel.ID) {
        [SVProgressHUD showErrorWithStatus:@"请选择配送地址"];
        return nil;
    }else{
        [self caulateDistance];
    }
//    CGFloat totlePrice = [ComputeOrderAmountManager computeOrderAmountWithGoodsArray:_goodsArray byActiveDic:nil  andCouponDic:nil];
//    CGFloat originalPrice =  totlePrice + [_goodsPostage floatValue];
    
    CGFloat originalPrice = [self realityTotalPrice];
    
    [dict setValue:[NSString stringWithFormat:@"%.2f", originalPrice] forKey:@"orderOriginalPrice"];
    [dict setValue:[NSString stringWithFormat:@"%.2f", (price - [_goodsPostage floatValue])] forKey:@"orderPresentPrice"];
    
    [dict setValue:_addressModel.consigneeName forKey:@"consigneeName"];
    [dict setValue:_addressModel.consigneeTel forKey:@"consigneeTel"];
    [dict setValue:_orderHeaderView.addressLab.text forKey:@"consigneeAddress"];
    
    if (_goodsPostage) {
        [dict setValue:_goodsPostage forKey:@"postage"];
    } else {
        [dict setValue:@"0" forKey:@"postage"];
    }
    
    [dict setValue:@(_postageTpye) forKey:@"postagePayType"];
    
    if (_yuShouActiveId == nil) {
        if (_expressTimeStr == nil) {
            [SVProgressHUD showErrorWithStatus:@"请选择配送时间"];
            return nil;
        }
        [dict setValue:_expressTimeStr forKey:@"deliverGoodsTime"];
        
        [dict setValue:@"0" forKey:@"activityId"];
        
    } else {
        
        NSDictionary *ysActiveDic= [[_goodsArray[0] objectForKey:@"detailActArray"] firstObject];
        
        [dict setValue:[ASHString jsonDateToString:[ysActiveDic objectForKey:@"endValidityTime"] withFormat:@"yyyy-MM-dd"] forKey:@"deliverGoodsTime"];
        [dict setValue:_yuShouActiveId forKey:@"activityId"];
    }
    
    
    if (_payDic) {
        [dict setValue:@(1) forKey:@"payType"];
        
        NSMutableDictionary *payDict = [NSMutableDictionary dictionary];
        [payDict setValue:[_payDic objectForKey:@"payerName"] forKey:@"payerName"];
        [payDict setValue:[_payDic objectForKey:@"payerTel"] forKey:@"payerTel"];
        [dict setValue:payDict forKey:@"offlinePayment"];
        
    } else {
        [dict setValue:@(0) forKey:@"payType"];
    }
    
    if (_invoiceDic) {
        [dict setValue:@(1) forKey:@"isHasInvoice"];
        
        NSMutableDictionary *invoiceDict = [NSMutableDictionary dictionary];
        [invoiceDict setValue:[_invoiceDic objectForKey:@"couponInformation"] forKey:@"id"];
        
        
        if (_isNarmolInvoice) {
            [invoiceDict setValue:@(0) forKey:@"invoiceType"];
            
            [invoiceDict setValue:[_invoiceDic objectForKey:@"unitName"] forKey:@"unitName"];
            [invoiceDict setValue:[_invoiceDic objectForKey:@"taxpayerIdentificationNumber"] forKey:@"taxpayerIdentificationNumber"];
        } else {
            [invoiceDict setValue:@(1) forKey:@"invoiceType"];
            
            [invoiceDict setValue:[_invoiceDic objectForKey:@"unitName"] forKey:@"unitName"];
            [invoiceDict setValue:[_invoiceDic objectForKey:@"taxpayerIdentificationNumber"] forKey:@"taxpayerIdentificationNumber"];
            [invoiceDict setValue:[_invoiceDic objectForKey:@"registeredAddress"] forKey:@"registeredAddress"];
            [invoiceDict setValue:[_invoiceDic objectForKey:@"registeredTel"] forKey:@"registeredTel"];
            [invoiceDict setValue:[_invoiceDic objectForKey:@"depositBank"] forKey:@"depositBank"];
            [invoiceDict setValue:[_invoiceDic objectForKey:@"bankAccount"] forKey:@"bankAccount"];
            [invoiceDict setValue:[_invoiceDic objectForKey:@"businessLicenseUrl"] forKey:@"businessLicenseUrl"];
        }
        
        if (_isInvoiceGeren) {
            [invoiceDict setValue:@(1) forKey:@"invoiceLookedUpType"];
        } else {
            [invoiceDict setValue:@(0) forKey:@"invoiceLookedUpType"];
        }
        
        if (_isInvoiceGoods) {
            [invoiceDict setValue:@(0) forKey:@"invoiceContent"];
        } else {
            [invoiceDict setValue:@(1) forKey:@"invoiceContent"];
        }
        
        [dict setValue:invoiceDict forKey:@"invoice"];
        
    } else {
        
        if (_isInvoiceGeren) {
            NSMutableDictionary *invoiceDict = [NSMutableDictionary dictionary];
            
            [invoiceDict setValue:@(0) forKey:@"invoiceType"];
            
            if (_isInvoiceGeren) {
                [invoiceDict setValue:@(1) forKey:@"invoiceLookedUpType"];
            } else {
                [invoiceDict setValue:@(0) forKey:@"invoiceLookedUpType"];
            }
            
            if (_isInvoiceGoods) {
                [invoiceDict setValue:@(0) forKey:@"invoiceContent"];
            } else {
                [invoiceDict setValue:@(1) forKey:@"invoiceContent"];
            }
            
            [dict setValue:invoiceDict forKey:@"invoice"];
            [dict setValue:@(1) forKey:@"isHasInvoice"];
        } else {
            [dict setValue:@(0) forKey:@"isHasInvoice"];
        }
    }
    
    if (_isFromShopCar) {
        [dict setValue:@(1) forKey:@"isFromShoppingCart"];
    } else {
        [dict setValue:@(0) forKey:@"isFromShoppingCart"];
    }
    
    if (self.isCouponAvailable && _youHuiQuanDic) {
        [dict setValue:@(1) forKey:@"isUseCoupon"];
        NSMutableDictionary *couponDic = [NSMutableDictionary dictionary];
        [couponDic setValue:[_youHuiQuanDic objectForKey:@"id"] forKey:@"id"];
        [dict setValue:couponDic forKey:@"userCoupons"];
        
    } else {
        [dict setValue:@(0) forKey:@"isUseCoupon"];
    }
    
    NSMutableArray *goodsInfoArr = [NSMutableArray array];
    NSMutableArray *tempArr = _goodsArray;
    for (NSDictionary *infoDic in tempArr) {
        
        NSMutableDictionary *infoDict = [infoDic mutableCopy];
    
//        NSLog(@"优惠券%@",[infoDic objectForKey:@"goodsQuantity"]);
//        NSString *goodsOriginalPrice = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"goodsOriginalPrice"]];
//        if (IsStrEmpty(goodsOriginalPrice)) {
//            [infoDict setObject:@"0" forKey:@"goodsOriginalPrice"];
//        }
        if ([[infoDic objectForKey:@"specActArray"] containsObject:_activeDic]) {
            
            CGFloat activePrice = [ComputeOrderAmountManager computActiveGoodsPriceWithDic:infoDic andActiveDic:[_activeDic objectForKey:@"activityInformation"]];
            
            [infoDict setValue:[NSString stringWithFormat:@"%.2f", activePrice] forKey:@"goodsPaymentPrice"];
            
        } else {
            CGFloat paymentPrice = [[infoDic objectForKey:@"goodsQuantity"] integerValue] * [[infoDict objectForKey:@"goodsOriginalPrice"] floatValue];
            [infoDict setValue:[NSString stringWithFormat:@"%.2f", paymentPrice] forKey:@"goodsPaymentPrice"];
        }
        
        [infoDict removeObjectForKey:@"detailActArray"];
        [infoDict removeObjectForKey:@"specActArray"];
        [infoDict removeObjectForKey:@"zeroStock"];
        [goodsInfoArr addObject:infoDict];
    }
    [dict setValue:goodsInfoArr forKey:@"orderDetails"];
    
    NSString *jsonStr = [ASHString trasforconditionToJsonString:dict];
    return jsonStr;
}

#pragma mark -提交订单
- (void)uploadOderWithJsonStr:(NSString *)jsonStr {
    [SVProgressHUD show];
    WeakSelf
    [HttpTools Post:kAppendUrl(YWOrderInsertString) andBody:jsonStr success:^(id responseObject) {
        [SVProgressHUD dismiss];
        
        if (_payDic == nil) {
            SelectPaymentViewController *paymentVC = [[SelectPaymentViewController alloc] init];
            paymentVC.payPrice = [self realityTotalPrice];
            if(weakSelf.accountView.carriage == -2.0f){
                paymentVC.tipStr = @"订单超出配送范围，运费货到付款";
            }
            paymentVC.orderID = [[responseObject objectForKey:@"resultData"] firstObject];
            paymentVC.orderNum = [[responseObject objectForKey:@"resultData"] lastObject];
            [self.navigationController pushViewController:paymentVC animated:YES];
        } else {
            XianxiaPayViewController *xianxiaPay = [[XianxiaPayViewController alloc] init];
            xianxiaPay.payPrice = [self realityTotalPrice];
            xianxiaPay.orderID = [[responseObject objectForKey:@"resultData"] firstObject];
            xianxiaPay.orderNum = [[responseObject objectForKey:@"resultData"] lastObject];
            xianxiaPay.isPay = YES;
            
            [self.navigationController pushViewController:xianxiaPay animated:YES];
        }
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"11");
    }];
}


//查看库存
- (void)checkoutDecisionInventory {
    NSString *jsonStr = [self getOrderJsonString];
    if (jsonStr == nil) {
        return;
    }
    [SVProgressHUD show];
    [HttpTools Post:kAppendUrl(YWOrderInventoryString) andBody:jsonStr success:^(id responseObject) {
        [SVProgressHUD dismiss];
        if (_yuShouActiveId) {
            [self uploadOderWithJsonStr:jsonStr];
            return ;
        }
        
        BOOL hasGoods = YES;
        NSInteger sellout = 0;
        NSInteger understock = 0;
        NSArray *resultArr = [[responseObject objectForKey:@"resultData"] objectForKey:@"goodsMsg"];
        for (NSDictionary *resultDic in resultArr) {
            
            NSInteger type = [[resultDic objectForKey:@"code"] integerValue];
            if (type != 200) {
                hasGoods = NO;
                
                if (type == 80003 || type == 80001) {
                    sellout ++;
                    for (NSDictionary *goodsDic in _goodsArray) {
                        if ([[resultDic objectForKey:@"goodsSpecificationDetailsId"] isEqual:[goodsDic objectForKey:@"goodsSpecificationDetailsId"]]) {
                            [_goodsArray removeObject:goodsDic];
                            break;
                        }
                    }
                } else if (type == 80004) {
                    
                    for (NSDictionary *goodsDic in _goodsArray) {
                        if ([[resultDic objectForKey:@"goodsSpecificationDetailsId"] isEqual:[goodsDic objectForKey:@"goodsSpecificationDetailsId"]]) {
                            [goodsDic setValue:[resultDic objectForKey:@"stock"] forKey:@"goodsQuantity"];
                            understock ++;
                            break;
                        }
                    }
                    
                    if (_goodsArray.count == 1) {
                        
                        [self viewDidLoad];
                        [self.tableView reloadData];
                        
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"抱歉，您购买的商品仅剩 %@ 件，继续下单将购买当前商品的剩余数量", [resultDic objectForKey:@"stock"]] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"继续下单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            
                            if ([self getOrderJsonString] == nil) {
                                return;
                            }
                            [self uploadOderWithJsonStr:[self getOrderJsonString]];
                            [alertController dismissViewControllerAnimated:YES completion:nil];
                            
                        }];
                        [alertController addAction:cancelAction];
                        [alertController addAction:okAction];
                        [self presentViewController:alertController animated:YES completion:nil];
                        return;
                    }
                    
                }
            }
        }
        
        if (sellout == resultArr.count) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"抱歉，您购买的商品均已售空，请选择其他同类商品" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"返回首页" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [alertController dismissViewControllerAnimated:YES completion:nil];
                [YWNoteCenter postNotificationName:@"goToHomeController" object:nil];
                if (self.navigationController.viewControllers.count > 0) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];

        } else if (sellout > 0) {
            [SVProgressHUD showErrorWithStatus:@"抱歉，您购买的部分商品已售空，已为您剔除库存不足的商品"];
            [self viewDidLoad];
            [self.tableView reloadData];
        }
        if (understock > 0) {
            
            [self viewDidLoad];
            [self.tableView reloadData];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"抱歉，您购买的部分商品库存数量不足，继续下单将购买当前商品的剩余数量" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"继续下单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if ([self getOrderJsonString] == nil) {
                    return;
                }
                [self uploadOderWithJsonStr:[self getOrderJsonString]];
                [alertController dismissViewControllerAnimated:YES completion:nil];
                
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        if (hasGoods) {
            [self uploadOderWithJsonStr:jsonStr];
        }
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    
}


#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _goodsArray.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 96;
    }
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MakeOrderGoodsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MakeOrderGoodsListCell" forIndexPath:indexPath];
        
        NSMutableDictionary *dic = [_goodsArray[indexPath.row] mutableCopy];
        [cell setDataWithDic:dic];
        
        cell.AmountTextField.userInteractionEnabled = !_isFromShopCar;
        
        YWWeakSelf;
        cell.AmountTextField.changeNumber = ^(NSInteger number) {
            [dic setValue:@(number) forKey:@"goodsQuantity"];
            [weakSelf.goodsArray replaceObjectAtIndex:indexPath.row withObject:dic];
            [weakSelf.tableView reloadData];
            [weakSelf requestAddressPostage];
        };
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderTableViewCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"OrderTableViewCell"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = _titleArray[indexPath.section - 1];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        NSString *deatailStr = @"请选择";
        switch (indexPath.section) {
            case 1:{
                
                CGFloat price = [self realityTotalPrice];
                if (price > 50000) {
                    deatailStr = @"线下支付";
                } else {
                    deatailStr = @"快捷支付";
                }
            }
                break;
            case 2:{
                if (_yuShouActiveId) {
                    deatailStr = @"预售活动结束后7天内";
                } else {
                    if (_expressTimeStr) {
                        deatailStr = _expressTimeStr;
                    }
                }
            }
                break;
            case 3:{
                if (_invoiceDic) {
                    if (_isNarmolInvoice) {
                        if (_isInvoiceGeren) {
                            deatailStr = @"普通发票-个人";
                        } else {
                            deatailStr = @"普通发票-单位";
                        }
                    } else {
                        deatailStr = @"增值税发票";
                    }
                } else {
                    if (_isInvoiceGeren) {
                        deatailStr = @"普通发票-个人";
                    } else {
                        deatailStr = @"不开发票";
                    }
                    
                }
            }
                break;
            
            case 4:{
               
                
                 if (!self.isCouponAvailable) {
                        deatailStr = @"暂无合适的优惠券";
                        break;
                 }
               
               
                
                if (_youHuiQuanDic) {
  
                    if (self.isCouponAvailable) {
                         deatailStr = @"暂无合适的优惠券";
                    }else{
                        NSString *useLimit = [[_youHuiQuanDic objectForKey:@"couponInformation"] objectForKey:@"useLimit"];
                        NSString *price = [[_youHuiQuanDic objectForKey:@"couponInformation"] objectForKey:@"price"];
                        deatailStr = [NSString stringWithFormat:@"满%.2f元减%.2f元",[ useLimit floatValue],[price floatValue] ];
                    }
                } else {
                    deatailStr = @"选择优惠券";
                }
            }
                break;
            case 5:{
                if (_activeDic) {
                    
                    NSDictionary *actDic = [_activeDic objectForKey:@"activityInformation"];
                    
                    switch ([[actDic objectForKey:@"activityType"] intValue]) {
                        case 0:
                            deatailStr = [NSString stringWithFormat:@"打%.1f折,最多购买%@个", [[actDic objectForKey:@"discount"] floatValue] * 10, [actDic objectForKey:@"maxNum"]];
                            break;
                        case 1:
                            deatailStr = [NSString stringWithFormat:@"团购单价为%.2f元，最多购买%@个", [[actDic objectForKey:@"discount"] floatValue], [actDic objectForKey:@"maxNum"]];
                            break;
                        case 2:
                            deatailStr = [NSString stringWithFormat:@"秒杀单价为%.2f元，最多购买%@个", [[actDic objectForKey:@"discount"] floatValue], [actDic objectForKey:@"maxNum"]];
                            break;
                        case 3:
                            deatailStr = [NSString stringWithFormat:@"立减%.2f元，最多购买%@个", [[actDic objectForKey:@"discount"] floatValue], [actDic objectForKey:@"maxNum"]];
                            break;
                        case 4:
                            deatailStr = [NSString stringWithFormat:@"满%.2f元，可减%.2f元", [[actDic objectForKey:@"price"] floatValue], [[actDic objectForKey:@"discount"] floatValue]];
                            break;
                        case 5:
                            deatailStr = [NSString stringWithFormat:@"已参与预售活动：%@", [actDic objectForKey:@"name"]];
                            break;
                        default:
                            break;
                    }
                } else {
                    deatailStr = @"未参与活动";
                }
            }
                break;
            default:
                break;
        }
        
        cell.detailTextLabel.text = deatailStr;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.numberOfLines = 2;
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 10)];
    footerView.backgroundColor = kBackGrayColor;
    return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:{
            
        }
            break;
        case 1:{
            [YWAlertView showNotice:@"支付说明" WithType:YWAlertTypeShowPayTips clickSureBtn:^(UIButton *btn) {
                
            }];
//            [self selectPayment];
        }
            break;
        case 2:{
            
            NSNumber *endTime = nil;
            if (_yuShouActiveId) {
                NSDictionary *ysActiveDic = [[_goodsArray[0] objectForKey:@"detailActArray"] firstObject];
                endTime = [ysActiveDic objectForKey:@"endValidityTime"];
                _expressTimeStr = @"预售活动结束后7日内";
//                [SVProgressHUD showInfoWithStatus:@"送货时间以约定到货为准"];
            }
            OrderSelectTimeView *selectTimeView = [[OrderSelectTimeView alloc] initWithEndTime:endTime];
            YWWeakSelf;
            selectTimeView.selectedDateStr = ^(NSString *dateStr) {
                weakSelf.expressTimeStr = dateStr;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
//
        }
            break;
        case 3:{
            SelectInvoiceViewController *invoiceVC = [[SelectInvoiceViewController alloc] init];
            YWWeakSelf;
            invoiceVC.selectInvoice = ^(BOOL isNormal, BOOL isGeren, BOOL isGoods, NSDictionary *invoiceDic) {
                weakSelf.invoiceDic = invoiceDic;
                weakSelf.isNarmolInvoice = isNormal;
                weakSelf.isInvoiceGeren = isGeren;
                weakSelf.isInvoiceGoods = isGoods;
                
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            [self.navigationController pushViewController:invoiceVC animated:YES];
        }
            break;
        case 4:{
            YWWeakSelf;
            
            if (!self.isCouponAvailable) {
               NSLog(@"暂无合适的优惠券");
                return;
             }
            

            
   
            YouHuiQuanListController *youhuiquanVC = [[YouHuiQuanListController alloc] init];
            
            youhuiquanVC.goodsArray = [self getGoodsCouponArray];
            youhuiquanVC.isSelectYouHuiQuan = YES;
            youhuiquanVC.realityPrice = [self realityTotalPrice];
            youhuiquanVC.selectedYouHuiQuan = ^(NSDictionary *dict) {
                weakSelf.youHuiQuanDic = dict;
                [weakSelf realityTotalPrice];
                [weakSelf requestAddressPostage];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            [weakSelf.navigationController pushViewController:youhuiquanVC animated:YES];
        }
            break;
        case 5:{
            NSMutableArray *activeArr = [NSMutableArray array];
            for (NSDictionary *dic in _goodsArray) {
                [activeArr addObjectsFromArray:[dic objectForKey:@"specActArray"]];
            }
            YWWeakSelf;

            ActiveSelectView *selectView = [ActiveSelectView initWithActiveArray:activeArr isShow:NO];
            selectView.completeSelectActive = ^(NSDictionary *activeDic) {
                _activeDic = activeDic;
                if (activeDic) {
                    [weakSelf realityTotalPrice];
                }
                [weakSelf requestAddressPostage];

                [tableView reloadData];
            };
        }
            break;
       
        default:
            break;
    }
}

- (NSArray *)getGoodsCouponArray {
    NSMutableArray *goodsInfoArr = [NSMutableArray array];
    for (NSDictionary *goodsDic in _goodsArray) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[goodsDic objectForKey:@"goodsQuantity"] forKey:@"number"];
        [dic setValue:[goodsDic objectForKey:@"goodsOriginalPrice"] forKey:@"unitPrice"];
        [dic setValue:[goodsDic objectForKey:@"goodsSpecificationDetailsId"] forKey:@"goodsSpeId"];
        
        NSMutableArray *activeArr = [NSMutableArray array];
        for (NSDictionary *activeDic in [goodsDic objectForKey:@"specActArray"]) {
            [activeArr addObject:[activeDic objectForKey:@"activityInformation"]];
        }
        [dic setValue:activeArr forKey:@"goodsSpeActivityList"];
        [dic setValue:[goodsDic objectForKey:@"detailActArray"] forKey:@"goodsActivityList"];
        [goodsInfoArr addObject:dic];
    }
    return goodsInfoArr;
}

- (void)requestCanUseCoupon {
//    NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setValue:userID forKey:@"userId"];
//    [dict setValue:[self getGoodsCouponArray] forKey:@"goodsMsgList"];
//
//    NSString *jsonStr = [ASHString trasforconditionToJsonString:dict];
//
//
//
//    [HttpTools Post:kAppendUrl(YWGetActivitysAndCouponsString) andBody:jsonStr success:^(id responseObject) {
//        [self.view stopLoading];
//
//        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
//         self.availableActiveArray = [dataDic objectForKey:@"coupons"];
//         self.availableActiveArray = [dataDic objectForKey:@"activitys"];
//
//
//
//        if (self.availableYouhuiquanArray.count) {
//            BOOL isAvailable = NO;
//            for (NSDictionary *dict in self.availableYouhuiquanArray) {
//
//                NSString *useLimit = [[dict objectForKey:@"couponInformation"] objectForKey:@"useLimit"];
//                if ([useLimit floatValue] > self.totalPrice ) {
//                    isAvailable = YES;
//                }
//            }
//            self.isCouponAvailable = isAvailable;
//        }
//
//
//    } failure:^(NSError *error) {
//        NSLog(@"11");
//    }];
}
- (void)selectPayment {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"快捷支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CGFloat price = [self realityTotalPrice];
        if (price > 50000) {
            [SVProgressHUD showInfoWithStatus:@"订单金额超过50000元，只能进行线下支付"];
        } else {
            _payDic = nil;
        }
        [alertController dismissViewControllerAnimated:YES completion:nil];
        [_tableView reloadData];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"线下支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        XianxiaPayViewController *xianxiaPay = [[XianxiaPayViewController alloc] init];
        xianxiaPay.completePay = ^(NSString *payerName, NSString *payerTel) {
            _payDic = @{@"payerName":payerName, @"payerTel":payerTel};
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:xianxiaPay animated:YES];
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"查看支付说明" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        
        [YWAlertView showNotice:@"支付说明" WithType:YWAlertTypeShowPayTips clickSureBtn:^(UIButton *btn) {
            
        }];
        
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)caulateDistance{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.junlin.aculatedistance.queue", DISPATCH_QUEUE_CONCURRENT);
    WeakSelf
    dispatch_async(concurrentQueue, ^{
        [weakSelf geoCode:_addressModel.region :^(double latitude, double longitude) {
            weakSelf.longitude = longitude;
            weakSelf.latitude = latitude;
        }];
    });
    
    NSString *currentCity = [YWUserDefaults objectForKey:@"currentCity"];
    dispatch_async(concurrentQueue, ^{
        [weakSelf geoCode:currentCity :^(double latitude, double longitude) {
            weakSelf.selectedLongitude = longitude;
            weakSelf.selectedLatitude = latitude;
        }];
    });
    dispatch_barrier_async(concurrentQueue, ^{
        weakSelf.distance = [weakSelf distanceBetweenOrderBy :weakSelf.latitude :weakSelf.selectedLatitude:weakSelf.longitude:weakSelf.selectedLongitude];
        NSLog(@"配送范围%f",weakSelf.distance);
        //TODO
        if(weakSelf.distance >10){
            weakSelf.accountView.carriage = -2.0f;
        }else{
            [self requestAddressPostage];
        }
        
    });
}


-(double)distanceBetweenOrderBy:(double) lat1 :(double) lat2 :(double) lng1 :(double) lng2{
    
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:lat1 longitude:lng1];
    
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:lat2 longitude:lng2];
    
    double  distance  = [curLocation distanceFromLocation:otherLocation];
    
    return  distance;
}


#pragma mark - 地理编码 反地理编码
/** 地理编码管理器 */
- (CLGeocoder *)geoC
{
    if (!_geoC) {
        _geoC = [[CLGeocoder alloc] init];
    }
    return _geoC;
}


// 地理编码(地址关键字 ->经纬度 )(void (^)(id responseObject))success
- (void)geoCode:(NSString *)address :(void(^)(double latitude, double longitude))success{
    
    //    NSString *address =_addressModel.region;
    
    // 容错处理
    if([address length] == 0)
    {
        return;
    }
    
    // 根据地址关键字, 进行地理编码
    [self.geoC geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        /**
         *  CLPlacemark : 地标对象
         *  location : 对应的位置对象
         *  name : 地址全称
         *  locality : 城市
         *  按相关性进行排序
         */
        CLPlacemark *pl = [placemarks firstObject];
        
        if(error == nil)
        {
            NSLog(@"经纬度%f----%f", pl.location.coordinate.latitude, pl.location.coordinate.longitude);
            
            NSLog(@"%@", pl.name);
            
        }
    }];
    
    
    
}



// 反地理编码(把经纬度---> 详细地址)
- (void)reverseGeoCode
{
    double latitude = 120;
    double longitude = 20;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [self.geoC reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *pl = [placemarks firstObject];
        
        if(error == nil)
        {
            NSLog(@"%f----%f", pl.location.coordinate.latitude, pl.location.coordinate.longitude);
            
            NSLog(@"%@", pl.name);
//            self.addressTV.text = pl.name;
//            self.latitudeTF.text = @(pl.location.coordinate.latitude).stringValue;
//            self.longitudeTF.text = @(pl.location.coordinate.longitude).stringValue;
        }
    }];
}
#pragma mark - UI


- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 45) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderGoodsListCell" bundle:nil] forCellReuseIdentifier:@"MakeOrderGoodsListCell"];
        
        [self loadHeaderView];
        
        [self.view addSubview:_tableView];
    }
}

- (void)loadHeaderView {
    _orderHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"MakeOrderHeaderView" owner:nil options:nil] firstObject];
    _orderHeaderView.frame = CGRectMake(0, 0, kIphoneWidth, 135);
    _tableView.tableHeaderView = _orderHeaderView;
    
    YWWeakSelf;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [[tapGesture rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        AddressListViewController *addressListVC = [[AddressListViewController alloc] init];
        addressListVC.isSelectAddress = YES;
        addressListVC.selectedAddress = ^(AddressModel *model) {
            weakSelf.addressModel = model;
            [weakSelf setAddressDataWithModel:model];
        };
        [weakSelf.navigationController pushViewController:addressListVC animated:YES];
    }];
    [_orderHeaderView.addressBackView addGestureRecognizer:tapGesture];
}

@end
