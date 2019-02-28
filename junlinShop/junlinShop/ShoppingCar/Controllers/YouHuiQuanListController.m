//
//  YouHuiQuanListController.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "YouHuiQuanListController.h"
#import "YouHuiQuanListTableCell.h"
#import "SegmentSelectView.h"
#import "GoodsListSpecViewController.h"
#import "YWAlertView.h"

#define SegmentViewHeight 50


#define OnePageCount 5

@interface YouHuiQuanListController () <UITableViewDelegate, UITableViewDataSource, SegmentSelectViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *allListArray;
//所有的优惠券
@property (nonatomic, strong) NSMutableArray *allQuanListArray;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, strong) NSMutableArray *usableListArray;
@property (nonatomic, assign) BOOL usable;
@property (nonatomic, strong) SegmentSelectView *selectView;

@end

@implementation YouHuiQuanListController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SegmentViewHeight, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight - SegmentViewHeight) style:UITableViewStylePlain];
//        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
//        }];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"YouHuiQuanListTableCell" bundle:nil] forCellReuseIdentifier:@"YouHuiQuanListTableCell"];
        [self createTableFooterView];
        
        [self.view addSubview:_tableView];
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getAllListData];
            [self getUsableListData];
        }];
        self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self getAllListDataPull];
        }];
        
    }
}


/**
 可使用优惠券
 */
- (void)getAllListData {
    self.index = 0;
    
    NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userID forKey:@"userId"];
    [self.allListArray removeAllObjects];
    
    [HttpTools Get:kAppendUrl(YWCouponsListString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
   
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray: [dataDic objectForKey:@"usableCoupon"]];
        self.allQuanListArray = [tmpArray mutableCopy];
        self.index++;
        
        while (tmpArray.count > OnePageCount) {
            [tmpArray removeLastObject];
        }
        
        [self.allListArray addObjectsFromArray:tmpArray];
        
        [self.allListArray addObjectsFromArray:[dataDic objectForKey:@"disabledCoupon"]];
        
        if (_goodsArray == nil) {
            [self clickButton:nil AtIndex:0];
        } else {
            NSString *titleStr = [NSString stringWithFormat:@"不可使用优惠券(%lu)", (unsigned long)self.allListArray.count];
            _selectView.changeButtonTitle(1, titleStr);
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];

        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getAllListData];
        }];
    }];
}
/**
 上拉加载更多 可使用优惠券
 */
- (void)getAllListDataPull {
    if (self.index * OnePageCount > self.allQuanListArray.count) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    
    self.index++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUInteger count = self.allQuanListArray.count;
        while(self.allListArray.count < self.index * OnePageCount){
            if (count>0) {
                count --;
             }
            
            [self.allListArray addObject:self.allQuanListArray[count]];
        }
        
        if (_goodsArray == nil) {
            [self clickButton:nil AtIndex:0];
        } else {
            NSString *titleStr = [NSString stringWithFormat:@"不可使用优惠券(%lu)", (unsigned long)self.allListArray.count];
            _selectView.changeButtonTitle(1, titleStr);
        }
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    });
    
   
    
}


/**
 不可可使用优惠券
 */
- (void)getUsableListData {
    if (_goodsArray == nil) {
        _usable = NO;
        return;
    }
    NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userID forKey:@"userId"];
    [dict setValue:_goodsArray forKey:@"goodsMsgList"];
    
    NSString *jsonStr = [ASHString trasforconditionToJsonString:dict];
    
    [HttpTools Post:kAppendUrl(YWGetActivitysAndCouponsString) andBody:jsonStr success:^(id responseObject) {
        [self.view stopLoading];
        
        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
        for (NSDictionary *dic in [dataDic objectForKey:@"coupons"]) {
            [self.usableListArray addObject:[dic objectForKey:@"userCoupons"]];
        }
        
        [self clickButton:nil AtIndex:0];
        
    } failure:^(NSError *error) {
        NSLog(@"11");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"使用优惠券";
    
    _dataArray = [NSMutableArray array];
    _allListArray = [NSMutableArray array];
    _usableListArray = [NSMutableArray array];
    _usable = YES;
    
    [self createTableView];
    [self.view startLoadingWithY:SegmentViewHeight Height:kIphoneHeight - SafeAreaTopHeight - SegmentViewHeight];
    
    _selectView = [[SegmentSelectView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, SegmentViewHeight) andTitleArray:@[@"可使用优惠券(0)", @"不可使用优惠券(0)"] andImageNameArray:nil byType:SegmentViewTypeBottonLine];
    _selectView.delegate = self;
    [self.view addSubview:_selectView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"使用说明" style:UIBarButtonItemStyleDone target:self action:@selector(showYouHuiQuanUseTips)];
    self.navigationItem.rightBarButtonItem.tintColor = kGrayTextColor;
    
    [self getAllListData];
    [self getUsableListData];
}

- (void)createTableFooterView {
    //    UILabel *noMoreDataLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 50)];
    //    noMoreDataLab.font = [UIFont systemFontOfSize:15.f];
    //    noMoreDataLab.textAlignment = NSTextAlignmentCenter;
    //    noMoreDataLab.text = @"没有更多优惠券了";
    //    self.tableView.tableFooterView = noMoreDataLab;
}

- (void)showNoDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, SegmentViewHeight, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight - SegmentViewHeight)];
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
        tiplabel.text = @"您暂无可使用的优惠券";
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


- (void)showYouHuiQuanUseTips {
    [YWAlertView showNotice:@"优惠券使用说明" WithType:YWAlertTypeShowCouponTips clickSureBtn:^(UIButton *btn) {
        
    }];
}

#pragma mark SegmentSelectViewDelegate
- (void)clickButton:(UIButton *)button AtIndex:(NSInteger)index {
    [self.dataArray removeAllObjects];
    
    NSString *titleStr = nil;
    if (_goodsArray == nil) {
        
        if (index == 0) {
            for (NSDictionary *dic in _allListArray) {
                if ([[dic objectForKey:@"status"] intValue] == 0) {
                    [self.dataArray addObject:dic];
                }
            }
            titleStr = [NSString stringWithFormat:@"可使用优惠券(%lu)", (unsigned long)self.dataArray.count];
        } else {
            for (NSDictionary *dic in _allListArray) {
                if ([[dic objectForKey:@"status"] intValue] != 0) {
                    [self.dataArray addObject:dic];
                }
            }
            titleStr = [NSString stringWithFormat:@"不可使用优惠券(%lu)", (unsigned long)self.dataArray.count];
            
        }
    } else {
        if (index == 0) {
            _usable = YES;
            [self.dataArray addObjectsFromArray:self.usableListArray];
            
            titleStr = [NSString stringWithFormat:@"可使用优惠券(%lu)", (unsigned long)self.dataArray.count];
        } else {
            _usable = NO;
            
            for (NSDictionary *dict in self.allListArray) {
                
                BOOL containsDic = NO;
                for (NSDictionary *usDict in self.usableListArray) {
                    if ([[usDict objectForKey:@"id"] integerValue] == [[dict objectForKey:@"id"] integerValue]) {
                        containsDic = YES;
                    }
                }
                
                if (!containsDic) {
                    [self.dataArray addObject:dict];
                }
                
            }
            
            titleStr = [NSString stringWithFormat:@"不可使用优惠券(%lu)", (unsigned long)self.dataArray.count];
        }
    }
    
    if (self.dataArray.count == 0) {
        [self showNoDataView];
    } else {
        [self.noDataView removeFromSuperview];
    }
    
    _selectView.changeButtonTitle(index, titleStr);
    
    [self.tableView reloadData];
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YouHuiQuanListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YouHuiQuanListTableCell" forIndexPath:indexPath];
    [cell setDataWithDic:_dataArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    NSDictionary *dic = _dataArray[indexPath.row];
    if (_isSelectYouHuiQuan && _usable == YES) {
         CGFloat useLimit = [[[dic objectForKey:@"couponInformation"] objectForKey:@"useLimit"] floatValue];
        if (self.realityPrice >= useLimit) {
            _selectedYouHuiQuan(dic);
            [self.navigationController popViewControllerAnimated:YES];

        }else{
            [SVProgressHUD showErrorWithStatus:@"优惠券不可用"];
        }
        
    } else {
        if ([[dic objectForKey:@"status"] integerValue] == 0) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:[dic objectForKey:@"id"] forKey:@"couponId"];
            
            [HttpTools Get:kAppendUrl(YWCouponGoodsString) parameters:dict success:^(id responseObject) {
                NSDictionary *dict =  [responseObject objectForKey:@"resultData"];
               // [dict writeToFile:@"/Users/apple/Desktop/2.plist" atomically:YES];

                NSArray *goodsArr = [dict objectForKey:@"goods"];
                if (goodsArr.count) {
                    
                    GoodsListSpecViewController *listVC = [[GoodsListSpecViewController alloc] init];
                    listVC.titleStr = @"优惠券商品";
                    listVC.goodsArray = goodsArr;
                    listVC.couponID = [dic objectForKey:@"id"];
                    [self.navigationController pushViewController:listVC animated:YES];
                    
                } else {
                    [YWNoteCenter postNotificationName:@"goToHomeController" object:nil];
                    if (self.navigationController.viewControllers.count > 0) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }
                
            } failure:^(NSError *error) {
                
            }];
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 

@end
