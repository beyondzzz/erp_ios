//
//  ShopCarViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "ShopCarViewController.h"
#import "SettleAccountsView.h"
#import "ShopCarViewCell.h"
#import "MakeOrderViewController.h"
#import "LoginViewController.h"
#import "NoticeCenterViewController.h"
#import "AppDelegate.h"
#import "YWBaseTabBarController.h"
#import "GoodsDetailViewController.h"
#import "GoodsListSpecViewController.h"
#import "YWAlertView.h"

@interface ShopCarViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) NSMutableArray <ShopCarModel*>*dataArray;
@property (nonatomic, strong) UIButton *selectAllBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *noticeBtn;
@property (nonatomic, strong) SettleAccountsView *accountView;

@property (nonatomic) BOOL isEditing;

@end

@implementation ShopCarViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([YWUserDefaults objectForKey:@"UserID"]) {
        [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 45];
        [self getShopCarData];
    }
    
    if ([[YWUserDefaults objectForKey:@"HasNotice"] integerValue] == 1) {
        _noticeBtn.badgeValue = @" ";
    } else {
        _noticeBtn.badgeValue = @"";
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"购物车";
    _dataArray = [NSMutableArray array];
    [self addAccountView];
  
    [self createTableHeaderView];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShopCarViewCell" bundle:nil] forCellReuseIdentifier:@"ShopCarViewCell"];
    
    [self createNavigationBarItem];
    
    if (![YWUserDefaults objectForKey:@"UserID"]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
        [self showNoDataView];
    }
    
 }


- (void)addAccountView{
    SettleAccountsView *accountView;
    if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
        accountView = [SettleAccountsView initWithButtonTitle:@"结算(0)" hasTabBar:YES];
    } else {
        accountView = [SettleAccountsView initWithButtonTitle:@"结算(0)" hasTabBar:NO];
    }
    
    accountView.totlePriceLab.text = @"0.00";
    accountView.tipLab.text = @"不含运费";
    YWWeakSelf;
    [[accountView.accountsBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        if (x.selected == NO) {
            return ;
        }
        
        NSMutableArray *tempArray = [NSMutableArray array];
        NSMutableArray *yuShouArr = [NSMutableArray array];
        for (ShopCarModel *model in weakSelf.dataArray) {
            if (!model.isSelect || model.isShiXiao || model.isWuHuo) {
                continue;
            }
            [tempArray addObject:model];
            if (model.isYuShou) {
                [yuShouArr addObject:model];
            }
        }
        
        if (yuShouArr.count > 0) {
            
            if (tempArray.count != yuShouArr.count) {
                [SVProgressHUD showErrorWithStatus:@"预售商品与非预售商品不能同时下单"];
                return;
            }
            
            BOOL hasDiffYuShouGoods = NO;
            NSNumber *yushouId = nil;
            for (ShopCarModel *model in yuShouArr) {
                if (!yushouId) {
                    yushouId = model.yuShouActiveId;
                } else {
                    if ([model.yuShouActiveId integerValue] != [yushouId  integerValue]) {
                        hasDiffYuShouGoods = YES;
                    }
                }
            }
            if (hasDiffYuShouGoods) {
                [SVProgressHUD showErrorWithStatus:@"参与不同预售活动的商品不能同时下单"];
                return;
            }
        }
        
        NSInteger noStock = 0;
        NSInteger selectCount = 0;
        for (ShopCarModel *model in weakSelf.dataArray) {
            if (!model.isSelect) {
                continue;
            }
            if ([[model.skuSelectedDic objectForKey:@"gxcGoodsState"] integerValue] == 1) {
                continue;
            }
            if (model.isSelect) {
                selectCount ++;
            }
            if ([[[model.dataDic objectForKey:@"goodsDetails"] objectForKey:@"zeroStock"] integerValue] == 1) {
                continue;
            }
            if ([[model.dataDic objectForKey:@"state"] integerValue] == 1 || [[model.skuSelectedDic objectForKey:@"gxcGoodsStock"] integerValue] <= 0) {
                noStock ++;
            }
        }
        
        if (noStock && noStock == selectCount) {
            [SVProgressHUD showInfoWithStatus:@"抱歉，您购买的商品均已售空，请选择其他同类商品"];
            return;
        }
        
        BOOL isShowAlert = NO;
        for (ShopCarModel *model in weakSelf.dataArray) {
            
            if (!model.isSelect) {
                continue;
            }
            
            if ([[[model.dataDic objectForKey:@"goodsDetails"] objectForKey:@"zeroStock"] integerValue] == 1 || [[model.skuSelectedDic objectForKey:@"gxcGoodsState"] integerValue] == 1) {
                continue;
            }
            
            if ([[model.skuSelectedDic objectForKey:@"gxcGoodsStock"] integerValue] - model.selectNumber < 0) {
                
                isShowAlert = YES;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"抱歉，您购买的部分商品库存数量不足，继续下单将购买当前商品的剩余数量" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"继续下单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self createOrder];
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                    
                }];
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
        }
        
        if (!isShowAlert) {
            [self createOrder];
        }
    }];
    
    [self.view addSubview:accountView];
    self.accountView = accountView;

}

# pragma mark -生成订单

- (void)createOrder {
    
    MakeOrderViewController *makeOrderVC = [[MakeOrderViewController alloc] init];
    
    BOOL hasYuShou = NO;
    NSMutableArray *goodsArray = [NSMutableArray array];
    for (ShopCarModel *model in self.dataArray) {
        
        if (!model.isSelect) {
            continue;
        }
        
        if ([[model.dataDic objectForKey:@"state"] integerValue] == 1) {
            continue;
        }
        
        if (model.isYuShou) {
            hasYuShou = YES;
        } else {
            
            if ([[[model.dataDic objectForKey:@"goodsDetails"] objectForKey:@"zeroStock"] integerValue] == 0) {
                if ([[model.skuSelectedDic objectForKey:@"gxcGoodsStock"] integerValue] <= 0) {
                    continue;
                } else if ([[model.skuSelectedDic objectForKey:@"gxcGoodsStock"] integerValue] - model.selectNumber < 0) {
                    
                    model.selectNumber = [[model.skuSelectedDic objectForKey:@"gxcGoodsStock"] integerValue];
                    
                }
            }
            
        }
        
        NSMutableDictionary *goodDetailDic = [NSMutableDictionary dictionary];
        [goodDetailDic setValue:[model.dataDic objectForKey:@"goodsDetailsId"] forKey:@"goodsDetailsId"];
        [goodDetailDic setValue:@(model.selectNumber) forKey:@"goodsQuantity"];
        [goodDetailDic setValue:[model.skuSelectedDic objectForKey:@"id"] forKey:@"goodsSpecificationDetailsId"];
        [goodDetailDic setValue:[model.skuSelectedDic objectForKey:@"gxcPurchase"] forKey:@"goodsPurchasingPrice"];
        [goodDetailDic setValue:[model.skuSelectedDic objectForKey:@"price"] forKey:@"goodsOriginalPrice"];
        CGFloat price = [[model.skuSelectedDic objectForKey:@"price"] floatValue];
        [goodDetailDic setValue:[NSNumber numberWithFloat:(price * model.selectNumber)] forKey:@"goodsPaymentPrice"];
        [goodDetailDic setValue:[model.dataDic objectForKey:@"goodsName"] forKey:@"goodsName"];
        [goodDetailDic setValue:model.goodsImageUrl forKey:@"goodsCoverUrl"];
        [goodDetailDic setValue:[model.skuSelectedDic objectForKey:@"specifications"] forKey:@"goodsSpecificationName"];
        [goodDetailDic setValue:[[model.dataDic objectForKey:@"goodsDetails"] objectForKey:@"zeroStock"] forKey:@"zeroStock"];
        
        NSMutableArray *detailActArr = [NSMutableArray array];
        NSMutableArray *specActArr = [NSMutableArray array];
        
        if (model.isYuShou) {
            NSArray *actArr = [[model.dataDic objectForKey:@"goodsDetails"] objectForKey:@"goodsActivitys"];
            if (actArr.count) {
                [detailActArr addObject:[[actArr firstObject] objectForKey:@"activityInformation"]];
                makeOrderVC.yuShouActiveId = [[actArr firstObject] objectForKey:@"id"];
                for (NSDictionary *ysActive in actArr) {
                    [specActArr addObject:ysActive];
                }
                
            }
        } else {
            for (NSDictionary *actDic in [model.dataDic objectForKey:@"goodsActivitys"]) {
                [detailActArr addObject:[actDic objectForKey:@"activityInformation"]];
            }
            for (NSDictionary *actDic in [model.skuSelectedDic objectForKey:@"goodsActivitys"]) {
                [specActArr addObject:actDic];
            }
        }
        [goodDetailDic setValue:detailActArr forKey:@"detailActArray"];
        
        [goodDetailDic setValue:specActArr forKey:@"specActArray"];
        
        [goodsArray addObject:goodDetailDic];
    }
    
    makeOrderVC.goodsArray = goodsArray;
    makeOrderVC.isFromShopCar = YES;
    NSString *price = [self countTotlePrice];
    makeOrderVC.orderPrice = [price substringFromIndex:1];
    [self.navigationController pushViewController:makeOrderVC animated:YES];
}

# pragma mark - 编辑选择
- (void)createNavigationBarItem {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"编辑" forState:UIControlStateNormal];
    [button setTitleColor:kBlackTextColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button sizeToFit];
    
    YWWeakSelf;
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        weakSelf.isEditing = !weakSelf.isEditing;
        if (weakSelf.isEditing) {
            [button setTitle:@"完成" forState:UIControlStateNormal];
            weakSelf.deleteBtn.hidden = NO;
        } else {
            [button setTitle:@"编辑" forState:UIControlStateNormal];
            weakSelf.deleteBtn.hidden = YES;
        }
        for (ShopCarModel *model in weakSelf.dataArray) {
            model.isEditing = weakSelf.isEditing;
        }
        [weakSelf.tableView reloadData];
    }];
    
    UIBarButtonItem *item01 = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    _noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_noticeBtn setBackgroundImage:[UIImage imageNamed:@"shopcar_notice_icon"] forState:UIControlStateNormal];
    [[_noticeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NoticeCenterViewController *noticeVC = [[NoticeCenterViewController alloc] init];
        [weakSelf.navigationController pushViewController:noticeVC animated:YES];
    }];
    [_noticeBtn sizeToFit];
    
    UIBarButtonItem *item02 = [[UIBarButtonItem alloc] initWithCustomView:_noticeBtn];
    
    self.navigationItem.rightBarButtonItems = @[item02, item01];
}

- (void)createTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 40)];
    headerView.backgroundColor = kBackViewColor;
    
    _selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectAllBtn.frame = CGRectMake(0, 5, 80, 30);
    [_selectAllBtn setImage:[UIImage imageNamed:@"shopcar_selectBack"] forState:UIControlStateNormal];
    [_selectAllBtn setImage:[UIImage imageNamed:@"shopcar_selected"] forState:UIControlStateSelected];
    [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    _selectAllBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_selectAllBtn setTitleColor:kBlackTextColor forState:UIControlStateNormal];
    [_selectAllBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:8.f];
    YWWeakSelf;
    [[_selectAllBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = !x.selected;
        
        for (ShopCarModel *model in weakSelf.dataArray) {
            //编辑状态  可全选

            if(weakSelf.isEditing){

            }else{
                if(model.isShiXiao){
                    break;
                }
            }

            
            if ([[model.dataDic objectForKey:@"state"] integerValue] != 1) {
                model.isSelect = x.selected;
            }
        }
        
        [weakSelf countTotlePrice];
          
        [weakSelf.tableView reloadData];
    }];
    [headerView addSubview:_selectAllBtn];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = CGRectMake(kIphoneWidth - 80, 5, 80, 30);
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_deleteBtn setTitleColor:kBlackTextColor forState:UIControlStateNormal];
    [[_deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        [YWAlertView showNotice:@"确认删除选中商品吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            
            NSMutableArray *goodsIdArr = [NSMutableArray array];
            for (ShopCarModel *model in weakSelf.dataArray) {
                if (model.isSelect) {
                    [goodsIdArr addObject:[model.dataDic objectForKey:@"id"]];
                }
            }
            
            if (goodsIdArr.count == 0) {
                [SVProgressHUD showInfoWithStatus:@"请选择需要删除的商品"];
                return ;
            }
            
            NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:userID forKey:@"userId"];
            [dict setValue:[goodsIdArr componentsJoinedByString:@","] forKey:@"ids"];
            [HttpTools Post:kAppendUrl(YWDeleteShopCarGoodsString) parameters:dict success:^(id responseObject) {
                [SVProgressHUD showErrorWithStatus:@"删除成功"];
                
                weakSelf.isEditing = NO;
                [weakSelf getShopCarData];
                
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"删除失败"];
            }];
            
        }];
        
    }];
    _deleteBtn.hidden = YES;
    [headerView addSubview:_deleteBtn];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)showNoDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight)];
        _noDataView.backgroundColor = kBackGrayColor;
        
        UIImageView *noDataImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shopcar_noData"]];
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
        label.text = @"购物车竟然是空的";
        [_noDataView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX);
            make.top.equalTo(noDataImageView.mas_bottom).offset(15);
            make.width.equalTo(@180);
            make.height.equalTo(@20);
        }];
        
        YWWeakSelf;
        UIButton *goHomeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [goHomeBtn setTitleColor:kBlackTextColor forState:UIControlStateNormal];
        [goHomeBtn setTitle:@"返回首页" forState:UIControlStateNormal];
        [goHomeBtn setBorder:kGrayTextColor width:1 radius:5.f];
        [_noDataView addSubview:goHomeBtn];
        [goHomeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX).offset(-70);
            make.top.equalTo(label.mas_bottom).offset(100);
            make.width.equalTo(@110);
            make.height.equalTo(@36);
        }];
        [[goHomeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [YWNoteCenter postNotificationName:@"goToHomeController" object:nil];
            if (weakSelf.navigationController.viewControllers.count > 0) {
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
//            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            YWBaseTabBarController *tab = (YWBaseTabBarController *)delegate.window.rootViewController;
//            tab.selectedIndex = 0;
        }];
        
        UIButton *miaoShaBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [miaoShaBtn setTitleColor:kBackGreenColor forState:UIControlStateNormal];
        [miaoShaBtn setTitle:@"逛逛秒杀" forState:UIControlStateNormal];
        [miaoShaBtn setBorder:kBackGreenColor width:1 radius:5.f];
        [_noDataView addSubview:miaoShaBtn];
        [miaoShaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX).offset(70);
            make.top.equalTo(label.mas_bottom).offset(100);
            make.width.equalTo(@110);
            make.height.equalTo(@36);
        }];
        [[miaoShaBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [weakSelf requestAdsData];
        }];
    }
    
    if (![self.view.subviews containsObject:_noDataView]) {
        [self.view addSubview:_noDataView];
    }
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopCarModel *model = _dataArray[indexPath.row];
    NSArray *activeArr = [model.skuSelectedDic objectForKey:@"goodsActivitys"];
    if (model.isYuShou) {
        activeArr = [[model.dataDic objectForKey:@"goodsDetails"] objectForKey:@"goodsActivitys"];
    }
    if (activeArr.count) {
        return 135;
    }
    return 105;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShopCarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCarViewCell" forIndexPath:indexPath];
    
    YWWeakSelf;
    [cell setDataWithModel:_dataArray[indexPath.row] completeBlock:^(BOOL isReloadData) {
        [weakSelf countTotlePrice];

        if (isReloadData) {
            [weakSelf.tableView reloadData];
        }
    }];
    
    cell.clickSelectBtn = ^(BOOL isSelected) {
//        BOOL isSelectAll = YES;
//        for (ShopCarModel *model in weakSelf.dataArray) {
//            if (!model.isSelect) {
//                isSelectAll = NO;
//            }
//        }
        weakSelf.dataArray[indexPath.row].isSelect = isSelected;
//       weakSelf.selectAllBtn.selected = isSelected;
        [weakSelf.tableView reloadData];

    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ShopCarModel *model = _dataArray[indexPath.row];
    GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
    detailVC.goodsID = [model.dataDic objectForKey:@"goodsDetailsId"];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return _isEditing;
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    YWWeakSelf;
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
     title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
         
         [YWAlertView showNotice:@"确认删除该商品吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
             
             ShopCarModel *model = weakSelf.dataArray[indexPath.row];
             NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
             [dict setValue:userID forKey:@"userId"];
             [dict setValue:[model.dataDic objectForKey:@"id"] forKey:@"id"];
             [HttpTools Post:kAppendUrl(YWDeleteShopCarString) parameters:dict success:^(id responseObject) {
                 [SVProgressHUD showErrorWithStatus:@"删除成功"];
               
                 [weakSelf.dataArray removeObjectAtIndex:indexPath.row];
                 [weakSelf.tableView reloadData];
                 [self countTotlePrice ];
             } failure:^(NSError *error) {
                 [SVProgressHUD showErrorWithStatus:@"删除失败"];
             }];
             
         }];
         
         
         NSLog(@"删除");
         
     }];

    rowAction.backgroundColor = kBackGreenColor;
    return @[rowAction];
}

- (NSString *)countTotlePrice {
//    if(self.isEditing){
//        return @"0";
//    }
//    
    CGFloat totlePrice = 0;
    NSInteger selectCount = 0;
    for (ShopCarModel *model in _dataArray) {
        if (model.isSelect ) {
            CGFloat price = model.selectNumber * [model.price floatValue];
            totlePrice += price;
            selectCount ++;
        }
    }
    NSString *totlePrices = [NSString stringWithFormat:@"¥%.2f", totlePrice];
    NSMutableDictionary *priceDic = [NSMutableDictionary dictionary];
    [priceDic setValue:totlePrices forKey:@"totlePrice"];
    [priceDic setValue:@(selectCount) forKey:@"selectCount"];
    [YWNoteCenter postNotificationName:@"ChangeTotlePrice" object:priceDic];
    return totlePrices;
}



#pragma mark - 数据

- (void)requestAdsData {
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"3" forKey:@"type"];
    [HttpTools Get:kAppendUrl(YWHomeAdsString) parameters:dic success:^(id responseObject) {
        
        NSDictionary *qiangGouDic = [[responseObject objectForKey:@"resultData"] firstObject];
        
        if (qiangGouDic != nil) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[qiangGouDic objectForKey:@"id"] forKey:@"advertisementInformationId"];
            [HttpTools Get:kAppendUrl(YWHomeHotString) parameters:dict success:^(id responseObject) {
                [self.view stopLoading];
                NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
                NSArray *goodsArray = [dataDic objectForKey:@"goods"];
                
                if ([[dataDic objectForKey:@"flag"] integerValue] == 2) {
                    if (goodsArray.count) {
                        GoodsListSpecViewController *listVC = [[GoodsListSpecViewController alloc] init];
                        listVC.goodsArray = goodsArray;
                        [self.navigationController pushViewController:listVC animated:YES];
                    }
                    
                } else if ([[dataDic objectForKey:@"flag"] integerValue] == 0) {
                    
                    if (goodsArray.count) {
                        NSDictionary *goodsDic = [goodsArray firstObject];
                        
                        GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
                        detailVC.goodsID = [goodsDic objectForKey:@"id"];
                        [self.navigationController pushViewController:detailVC animated:YES];
                    }
                }
                
            } failure:^(NSError *error) {
                
            }];
        } else {
            [SVProgressHUD showInfoWithStatus:@"暂时没有限时抢购商品"];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)getShopCarData {
    [self.dataArray removeAllObjects];
    NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWShopCarListString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        NSArray *array = [responseObject objectForKey:@"resultData"];
        if (array.count == 0) {
            [self showNoDataView];
        } else {
            [self.noDataView removeFromSuperview];
            for (NSDictionary *dic in array) {
                ShopCarModel *model = [[ShopCarModel alloc] init];
                model.dataDic = dic;
                model.specStr = [dic objectForKey:@"goodsSpecificationDetailsName"];
                model.price = [dic objectForKey:@"goodsUnitlPrice"];
                model.selectNumber = [[dic objectForKey:@"goodsNum"] integerValue];
                model.goodsImageUrl = [dic objectForKey:@"goodsPicUrl"];
                if ([[dic objectForKey:@"state"] integerValue] == 1) {
                    model.isShiXiao = YES;
                }
                NSArray *skuArray = [[dic objectForKey:@"goodsDetails"] objectForKey:@"goodsSpecificationDetails"];
                for (NSDictionary *skuDic in skuArray) {
                    if ([[skuDic objectForKey:@"id"] intValue] == [[dic objectForKey:@"goodsSpecificationDetailsId"] intValue]) {
                        model.skuSelectedDic = skuDic;
                        if ([[model.skuSelectedDic objectForKey:@"gxcGoodsState"] integerValue] == 1) {
                            model.isYuShou = YES;
                            
                            NSArray *activeArray = [[dic objectForKey:@"goodsDetails"] objectForKey:@"goodsActivitys"];
                            if (activeArray.count) {
                                model.yuShouActiveId = [[activeArray firstObject] objectForKey:@"id"];
                            }
                            
                        } else {
                            model.isYuShou = NO;
                            if ([[model.skuSelectedDic objectForKey:@"gxcGoodsStock"] integerValue] <= 0) {
                                model.isWuHuo = YES;
                            }
                        }
        
                    }
                }
                
                //TODO
//                model.isShiXiao = YES;
                
                model.isSelect = _selectAllBtn.isSelected;
                model.isEditing = _isEditing;
                [self.dataArray addObject:model];
            }
            [self countTotlePrice];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [self.view stopLoading];

        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getShopCarData];
        }];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
