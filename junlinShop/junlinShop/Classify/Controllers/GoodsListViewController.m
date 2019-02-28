//
//  GoodsListViewController.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "GoodsListViewController.h"
#import "GoodsListTableViewCell.h"
#import "GoodsListModel.h"
#import "GoodsTypeSelectModel.h"
#import "SegmentSelectView.h"
#import "DropdownTagSelectView.h"
#import "YWSearchBar.h"
#import "TagScreenView.h"
#import "LoginViewController.h"
#import "GoodsDetailViewController.h"
#import "AddShopCarManager.h"

#define SegmentViewHeight 45
@interface GoodsListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SegmentSelectViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *noDataView;

//全部数据
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *allDataArray;
//筛选结果
@property (nonatomic, strong) NSMutableArray *screenDataArray;
//品牌搜索结果
@property (nonatomic, strong) NSMutableArray *brandDataArray;

@property (nonatomic, strong) NSArray *brandArray;


@property (nonatomic, strong) GoodsTypeSelectModel *goodsTypeModel;
@property (nonatomic, assign) NSInteger selectBtnIndex;
//@property (nonatomic, strong) YWSearchBar *searchBar;

@end

@implementation GoodsListViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (YWWindow.subviews.count > 1) {
        UIView *view = YWWindow.subviews.lastObject;
        if ([view isKindOfClass:[DropdownTagSelectView class]]) {
            [view removeFromSuperview];
        }
    }
    [[CacheManager share].commonCache removeObjectForKey:SelectBrandArray];
    [[CacheManager share].commonCache removeObjectForKey:SelectIndexArray];
    [[CacheManager share].commonCache removeObjectForKey:SelectMinPrice];
    [[CacheManager share].commonCache removeObjectForKey:SelectMaxPrice];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetGoodsTypeModelDefaultData];
    [self addSearchBar];
   
    
    if (_classifId) {
        self.goodsTypeModel.classificationId = [NSString stringWithFormat:@"%@", _classifId];
    }
   
    [self setupUI];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GoodsListTableViewCell" bundle:nil] forCellReuseIdentifier:@"GoodsListTableViewCell"];
    
  
    [self getBrandListData];
    [self getGoodsListData];
}
#pragma mark -UI
- (void)setupUI{
    if (_isShowRightBtn) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setImage:[UIImage imageNamed:@"goodList_rightNavi"] forState:UIControlStateNormal];
        [rightBtn setTitle:@"筛选" forState:UIControlStateNormal];
        [rightBtn setTitleColor:kBlackTextColor forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [rightBtn sizeToFit];
        [rightBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:1.f];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        YWWeakSelf;
        [[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [weakSelf selectGoodsType];
        }];
    }
    SegmentSelectView *selectView = [[SegmentSelectView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, SegmentViewHeight) andTitleArray:@[@"综合", @"销量", @"价格", @"品牌"] andImageNameArray:nil byType:SegmentViewTypeGoodsList];
    selectView.delegate = self;
    [self.view addSubview:selectView];
    
    [self.view startLoadingWithY:SegmentViewHeight Height:kIphoneHeight - SafeAreaTopHeight - SegmentViewHeight];
}


- (void)addSearchBar {
    YWSearchBar *searchBar = [[YWSearchBar alloc] initWithFrame:CGRectMake(0, 6, kIphoneWidth - 160, 30) andStyle:YWSearchBarStyleGrayColor];
    searchBar.delegate = self;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth - 160, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleView;
    [titleView addSubview:searchBar];
 
    if (self.searchStr) {
        self.goodsTypeModel.searchName = self.searchStr;
        searchBar.text = self.searchStr;
    }
    
}


/**
 没有数据提示
 */
- (void)showNoDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, SegmentViewHeight, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight - SegmentViewHeight)];
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
        label.tag = 1000;
        label.text = @"抱歉，未搜索到您想要的商品";
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

- (void)dismissInputView {
    if (YWWindow.subviews.count > 1) {
        UIView *view = YWWindow.subviews.lastObject;
        [view removeFromSuperview];
    }
}

- (void)resetGoodsTypeModelDefaultData {
    _goodsTypeModel = [[GoodsTypeSelectModel alloc] init];
    
    _goodsTypeModel.sortType = @"1";
    _goodsTypeModel.priceSort = @"";
    _goodsTypeModel.searchName = @"";
    _goodsTypeModel.isHasGoods = @"true";
    _goodsTypeModel.minPrice = @"0";
    _goodsTypeModel.maxPrice = @"0";
    _goodsTypeModel.brandName = @"all";
    _goodsTypeModel.classificationId = @"0";
}
//商品筛选
- (void)selectGoodsType {
    
    YWWeakSelf;
    [TagScreenView initWithDataArray:@[self.brandArray, _classifArray] andGoodTypeModel:_goodsTypeModel andCompleteBlock:^(GoodsTypeSelectModel *selectModel) {
        if (selectModel.sortType) {
            weakSelf.goodsTypeModel.sortType = selectModel.sortType;
        }
        if (selectModel.priceSort) {
            weakSelf.goodsTypeModel.priceSort = selectModel.priceSort;
        }
 
        weakSelf.goodsTypeModel.isHasGoods = selectModel.isHasGoods;
        weakSelf.goodsTypeModel.minPrice = selectModel.minPrice;
        weakSelf.goodsTypeModel.maxPrice = selectModel.maxPrice;
        weakSelf.goodsTypeModel.brandName = selectModel.brandName;
        weakSelf.goodsTypeModel.classificationId = selectModel.classificationId;
        [weakSelf getGoodsListData];
     
    }];
}


#pragma mark searchBar代理
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    if (searchBar.text.length > 0) {
        searchBar.text = @"";
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        [self resetGoodsTypeModelDefaultData];
        [self getGoodsListData];
        return ;
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入搜索商品名称"];
        return ;
    }
    [searchBar resignFirstResponder];
    
    self.goodsTypeModel.classificationId = @"0";
    self.goodsTypeModel.searchName = searchBar.text;
    [self getGoodsListData];
}


#pragma mark - SegmentSelectViewDelegate  顶部类别选择
- (void)clickButton:(UIButton *)button AtIndex:(NSInteger)index {
    for (UIView *view in YWWindow.subviews) {
        if ([view isKindOfClass:[DropdownTagSelectView class]]) {
            [view removeFromSuperview];
            if (index == _selectBtnIndex) {
                button.selected = NO;
                return;
            }
        }
    }
    self.goodsTypeModel.priceSort = @"";
    
    switch (index) {
        case 0: {
            self.goodsTypeModel.sortType = @"1";
        }
            break;
        case 1: {
            
            if (button.selected) {
                self.goodsTypeModel.sortType = @"2";
            } else {
                self.goodsTypeModel.sortType = @"1";
            }
            
        }
            break;
        case 2: {
            self.goodsTypeModel.sortType = @"3";
            [button setImage:[UIImage imageNamed:@"segment_up_Jiantou"] forState:UIControlStateSelected];
            [button setImage:[UIImage imageNamed:@"segment_dwon_Jiantou"] forState:UIControlStateNormal];
            [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:3.f];
            
            if (button.selected) {
                self.goodsTypeModel.priceSort = @"asc";
                
            } else {
                self.goodsTypeModel.priceSort = @"desc";
            }
            
        }
            break;
        case 3: {
            //品牌筛选
            DropdownTagViewType type = DropdownTagViewTypeCollection;
            self.goodsTypeModel.priceSort = @"";
            YWWeakSelf;
            [DropdownTagSelectView initWithDataArray:_brandArray andType:type andCompleteBlock:^(NSArray *brandArray) {
  
                if (brandArray.count) {
                    NSString *brandStr = [brandArray componentsJoinedByString:@","];
                    weakSelf.goodsTypeModel.brandName = brandStr;
                } else {
                    weakSelf.goodsTypeModel.brandName = @"all";
                }
                
                [SVProgressHUD show];
                
                
                _selectBtnIndex = index;
                NSLog(@"112");
                 [weakSelf getGoodsListData];

                
            } orTableSelectComplete:^(NSString *selectStr) {
                NSLog(@"113");
            }];
            return;
        }
            break;
        default:
            break;
    }
    
    [SVProgressHUD show];
    [self getGoodsListData];
    
    _selectBtnIndex = index;
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 112;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsListTableViewCell" forIndexPath:indexPath];
    
    NSDictionary *dic = _dataArray[indexPath.row];
    [cell setDataWithDic:dic];
    
    //添加到购物车
    YWWeakSelf;
    [[[cell.addCarBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        if (![YWUserDefaults objectForKey:@"UserID"]) {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            [weakSelf.navigationController pushViewController:loginVC animated:YES];
            return ;
        }
        
        [AddShopCarManager addGoodsToShopCarWithGoodsDic:dic orGoodsSkuDic:nil andBuyCount:1 WithCouponId:nil];
        
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
    detailVC.goodsID = [_dataArray[indexPath.row] objectForKey:@"id"];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 网络

- (void)getBrandListData {
    [HttpTools Get:kAppendUrl(YWGoodsBrandString) parameters:nil success:^(id responseObject) {
        
        if ([[responseObject objectForKey:@"resultData"] isKindOfClass:[NSArray class]]) {
            self.brandArray = [responseObject objectForKey:@"resultData"];
            
        }
        
    } failure:^(NSError *error) {
        
    }];
}

/*
 Error Domain=NSCocoaErrorDomain Code=3840 "JSON text did not start with array or object and option to allow fragments not set." UserInfo={NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set., NSUnderlyingError=0x60400024c4b0 {Error Domain=com.alamofire.error.serialization.response Code=-1011 "Request failed: internal server error (500)" UserInfo={NSLocalizedDescription=Request failed: internal server error (500), NSErrorFailingURLKey=http://117.158.178.202:8001/JLMIS/goodsInformation/getGoodsList?bran
 */
- (void)getGoodsListData {
   
//    [self.dataArray removeAllObjects];
    [_noDataView removeFromSuperview];
 
    NSMutableDictionary *dic = [self.goodsTypeModel mj_keyValues];
    //商品列表
    [HttpTools Get:kAppendUrl(YWGoodsListString) parameters:dic success:^(id responseObject) {
        [self.view stopLoading];
        [SVProgressHUD dismiss];
        self.dataArray = [ responseObject objectForKey:@"resultData"];
     
        [self refreshView];
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getGoodsListData];
        }];
    }];
}

- (void)refreshView{
    if (![self.goodsTypeModel.searchName isEqualToString:@""]) {
        if (self.dataArray.count == 0) {
            [self showNoDataView];
        }
    }
    [self.tableView reloadData];
}



@end
