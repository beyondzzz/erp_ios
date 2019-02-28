//
//  SearchViewController.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/21.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "SearchViewController.h"
#import "YWSearchBar.h"
#import "GoodsListViewController.h"
#import "YWAlertView.h"
#import "ClassifyListModel.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) NSMutableArray *hotSearchArray;
@property (nonatomic, strong) NSMutableArray *hisSearchArray;

@end

@implementation SearchViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        adjustsScrollViewInsets(_tableView);
        _tableView.showsVerticalScrollIndicator = NO;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self createTableFooterView];
        
        [self.view addSubview:_tableView];
    }
}

- (void)createTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 60)];
    footerView.backgroundColor = [UIColor clearColor];
    
    _deleteBtn = [UIButton creatBtnWithFrame:CGRectMake(60, 15, kIphoneWidth - 60 * 2, 40) title:@"清空搜索历史" font:15.f titleColor:kGrayTextColor highlightColor:kBackGreenColor taret:self action:@selector(deleteAllHisSearch)];
    _deleteBtn.layer.borderColor = kGrayTextColor.CGColor;
    _deleteBtn.layer.borderWidth = 1.f;
    [footerView addSubview:_deleteBtn];
    _tableView.tableFooterView = footerView;
}

- (void)requestHotSearchWord {
    [HttpTools Get:kAppendUrl(YWHotSearchWordString) parameters:nil success:^(id responseObject) {
        _hotSearchArray = [NSMutableArray arrayWithArray:[responseObject objectForKey:@"resultData"]];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    
    YWSearchBar *searchBar = [[YWSearchBar alloc] initWithFrame:CGRectMake(-40, 6, kIphoneWidth - 90, 30) andStyle:YWSearchBarStyleGrayColor];
    searchBar.delegate = self;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth - 120, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleView;
    [titleView addSubview:searchBar];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(doBack)];
    [self.navigationItem.rightBarButtonItem setTintColor:kBlackTextColor];
    
    _hisSearchArray = [NSMutableArray array];
    
    [_hisSearchArray addObjectsFromArray:[YWUserDefaults objectForKey:@"hisSearchArray"]];
    
    [self createTableView];
    [self requestHotSearchWord];
 }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_hisSearchArray.count > 0) {
        _deleteBtn.hidden = NO;
    } else {
        _deleteBtn.hidden = YES;
    }
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteAllHisSearch {
    
    [YWAlertView showNotice:@"确认清除吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
        [_hisSearchArray removeAllObjects];
        [self updateLocateData];
        _deleteBtn.hidden = YES;
        [_tableView reloadData];
    }];
    
}

- (void)updateLocateData {
    NSArray *hisArray = [NSArray arrayWithArray:_hisSearchArray];
    [YWUserDefaults setValue:hisArray forKey:@"hisSearchArray"];
    [YWUserDefaults synchronize];
    if (hisArray.count > 0) {
        _deleteBtn.hidden = NO;
    } else {
        _deleteBtn.hidden = YES;
    }
    [_tableView reloadData];
}

#pragma mark searchBar代理
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    if (searchBar.text.length > 0) {
        searchBar.text = @"";
    }
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"哈哈哈%@其他%lu",searchBar.text,searchBar.text.length);

    if (searchBar.text.length == 0) {
        [self getClassfiyDataWithSearchString:searchBar.text];

//        GoodsListViewController *goodListVC = [[GoodsListViewController alloc] init];
//        goodListVC.classifArray = nil;
//        goodListVC.isShowRightBtn = YES;
//        goodListVC.searchStr = searchBar.text;
//
//        [self.navigationController pushViewController:goodListVC animated:YES];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"其他%@其他%lu",searchBar.text,searchBar.text.length);
    if (IsStrEmpty(searchBar.text)) {
        [SVProgressHUD showErrorWithStatus:@"请输入搜索商品名称"];
        return ;
    }
    [searchBar resignFirstResponder];
    
    if (![_hisSearchArray containsObject:searchBar.text]) {
        [_hisSearchArray addObject:searchBar.text];
    }
    
    [self updateLocateData];
    [self getClassfiyDataWithSearchString:searchBar.text];

//
//    GoodsListViewController *goodListVC = [[GoodsListViewController alloc] init];
//    goodListVC.searchStr = searchBar.text;
//    goodListVC.classifArray = nil;
//    goodListVC.isShowRightBtn = YES;
//    [self.navigationController pushViewController:goodListVC animated:YES];
}


#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_hisSearchArray.count) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return _hisSearchArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (_hotSearchArray.count < 5) {
            return 50;
        } else {
            return 100;
        }
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 40)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20)];
    label.font = [UIFont systemFontOfSize:17.f];
    label.textColor = kBlackTextColor;
    [headView addSubview:label];
    
    if (section == 0) {
        label.text = @"热门搜索";
    } else {
        label.text = @"历史搜索";
    }
    
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchTableViewCell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSInteger hotNum = _hotSearchArray.count < 10 ? _hotSearchArray.count : 10;
        
        CGFloat btnWidth = (kIphoneWidth - 10) / 5 - 10;
        for (NSInteger i = 0; i < hotNum; i ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setRadius:5.f];
            [button setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(btnWidth, 32) andColor:kBackGrayColor] forState:UIControlStateNormal];
            [button setTitleColor:kBlackTextColor forState:UIControlStateNormal];
            [button setTitle:_hotSearchArray[i] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.tag = i + 1200;
            button.frame = CGRectMake(10 + (btnWidth + 10) * (i % 5), 9 + 50 * (i / 5), btnWidth, 32);
            [cell.contentView addSubview:button];
            
            YWWeakSelf;
            [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                NSString *hotStr = weakSelf.hotSearchArray[x.tag - 1200];
                if (![weakSelf.hisSearchArray containsObject:hotStr]) {
                    [weakSelf.hisSearchArray addObject:hotStr];
                    [weakSelf updateLocateData];
                }
                
                [weakSelf getClassfiyDataWithSearchString:hotStr];
                
            }];
        }
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 30)];
        label.font = [UIFont systemFontOfSize:15.f];
        label.textColor = kGrayTextColor;
        label.text = _hisSearchArray[indexPath.row];
        [cell.contentView addSubview:label];
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    
    NSString *hisStr = _hisSearchArray[indexPath.row];
    [self getClassfiyDataWithSearchString:hisStr];
    
}

- (void)getClassfiyDataWithSearchString:(NSString *)searchStr {
    [HttpTools Get:kAppendUrl(YWClassifyString) parameters:nil success:^(id responseObject) {
        if ([[responseObject objectForKey:@"resultData"] isKindOfClass:[NSArray class]]) {
            
            NSArray *array = [ClassifyListModel mj_objectArrayWithKeyValuesArray:[responseObject objectForKey:@"resultData"]];
            
            GoodsListViewController *goodListVC = [[GoodsListViewController alloc] init];
            goodListVC.searchStr = searchStr;
            goodListVC.classifArray = array;
            goodListVC.isShowRightBtn = YES;
            [self.navigationController pushViewController:goodListVC animated:YES];
        }
        
    } failure:^(NSError *error) {
        GoodsListViewController *goodListVC = [[GoodsListViewController alloc] init];
        goodListVC.searchStr = searchStr;
        goodListVC.classifArray = nil;
        goodListVC.isShowRightBtn = YES;
        [self.navigationController pushViewController:goodListVC animated:YES];
    }];
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
