//
//  GoodsListSpecViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2018/3/18.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "GoodsListSpecViewController.h"
#import "GoodsListTableViewCell.h"
#import "GoodsDetailViewController.h"
#import "LoginViewController.h"
#import "AddShopCarManager.h"

@interface GoodsListSpecViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic)  UITableView *tableView;
@property (nonatomic, strong) UIView *noDataView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic) NSInteger goodsCount;

@end

@implementation GoodsListSpecViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"GoodsListTableViewCell" bundle:nil] forCellReuseIdentifier:@"GoodsListTableViewCell"];
        
        [self.view addSubview:_tableView];
    }
}

- (void)showNoDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight)];
        _noDataView.backgroundColor = kBackGrayColor;
        
        UIImageView *noDataImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_noData"]];
        [_noDataView addSubview:noDataImageView];
        [noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX);
            make.top.equalTo(_noDataView.mas_top).offset(150);
            make.width.equalTo(@100);
            make.height.equalTo(@100);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = kGrayTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"抱歉，该类别商品还未上架";
        [_noDataView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX);
            make.top.equalTo(noDataImageView.mas_bottom).offset(15);
            make.width.equalTo(@250);
            make.height.equalTo(@20);
        }];
        
    }
    
    if (![self.view.subviews containsObject:_noDataView]) {
        [self.view addSubview:_noDataView];
    }
}

- (void)requestGoodsList {
    NSString *urlStr = [NSString stringWithFormat:@"goodsInformation/getGoodsList_Ameliorate?sortType=1&priceSort=""&searchName=""&isHasGoods=true&minPrice=0&maxPrice=0&brandName=all&classificationId=%@", _newsID];
    [HttpTools Get:kAppendUrl(urlStr) parameters:nil success:^(id responseObject) {
        [self.view stopLoading];
        _dataArray = [responseObject objectForKey:@"resultData"];
        
        if (_dataArray.count > 10) {
            _goodsCount = 10;
        } else {
            _goodsCount = _dataArray.count;
        }
        
        [_tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _titleStr;
    [self createTableView];
    
    if (!_goodsArray) {
        [self requestGoodsList];
    } else {
        if (_goodsArray.count > 10) {
            _goodsCount = 10;
        } else {
            _goodsCount = _goodsArray.count;
        }
    }
    
    YWWeakSelf;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        NSInteger count = weakSelf.goodsArray.count;
        if (weakSelf.goodsArray.count == 0) {
            count = weakSelf.dataArray.count;
        }
        
        if (weakSelf.goodsCount == count) {
            [weakSelf.tableView.mj_footer performSelector:@selector(endRefreshingWithNoMoreData) withObject:nil/*可传任意类型参数*/ afterDelay:1.0];
            return ;
        }
        if (count > weakSelf.goodsCount + 10) {
            weakSelf.goodsCount += 10;
        } else {
            weakSelf.goodsCount = count;
        }
        [weakSelf performSelector:@selector(endRefreshingData) withObject:nil/*可传任意类型参数*/ afterDelay:1.0];
    }];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)endRefreshingData {
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.goodsCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 112;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsListTableViewCell" forIndexPath:indexPath];
    
    NSDictionary *dic = nil;
    if (_goodsArray) {
        dic = _goodsArray[indexPath.row];
    } else {
        dic = _dataArray[indexPath.row];
    }
    
    [cell setDataWithDic:dic];
    
    YWWeakSelf;
    [[[cell.addCarBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        if (![YWUserDefaults objectForKey:@"UserID"]) {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            [weakSelf.navigationController pushViewController:loginVC animated:YES];
            return ;
        }
        
        [AddShopCarManager addGoodsToShopCarWithGoodsDic:dic orGoodsSkuDic:nil andBuyCount:1 WithCouponId:_couponID];
        
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
    if (_goodsArray) {
        detailVC.goodsID = [_goodsArray[indexPath.row] objectForKey:@"id"];
    } else {
        detailVC.goodsID = [_dataArray[indexPath.row] objectForKey:@"id"];
    }
    
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
