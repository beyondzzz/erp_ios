//
//  ClassifyViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "ClassifyViewController.h"
#import "GoodsListViewController.h"
#import "GoodsDetailViewController.h"
#import "HomeViewFirstCell.h"
#import "ClassifyListModel.h"
#import "SDCycleScrollView.h"

#define MENU_WIDTH 100
#define ADSHEIGHT 120
#define LEFT_BTN_HEIGHT 50
#define CELL_WIDTH ((kIphoneWidth - MENU_WIDTH - 16) / 3)
@interface ClassifyViewController () <UICollectionViewDelegate, UICollectionViewDataSource, SDCycleScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *menuView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) SDCycleScrollView *firstCycleView;

@property (nonatomic, strong) NSArray *adsArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic) NSInteger selectIndex;

@end

@implementation ClassifyViewController

- (void)getClassfiyData {
    [HttpTools Get:kAppendUrl(YWClassifyString) parameters:nil success:^(id responseObject) {
        [self.view stopLoading];
        if ([[responseObject objectForKey:@"resultData"] isKindOfClass:[NSArray class]]) {
            self.dataArray = [ClassifyListModel mj_objectArrayWithKeyValuesArray:[responseObject objectForKey:@"resultData"]];
            _selectIndex = 1;
        }
        
//        ClassifyListModel *model = self.dataArray[0];
//        ClassifyListModel *model1 = model.twoClassifications[0];
        [self setMenuData];
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getClassfiyData];
        }];
    }];
}

- (void)requestAdsDataWithType:(NSNumber *)type {
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:type forKey:@"type"];
    [HttpTools Get:kAppendUrl(YWHomeAdsString) parameters:dic success:^(id responseObject) {
        if ([type intValue] == 2) {
            _adsArray = [responseObject objectForKey:@"resultData"];
            NSMutableArray *adsURLArray = [NSMutableArray array];
            for (NSDictionary *tempDic in _adsArray) {
                NSString *picURL = kAppendUrl([tempDic objectForKey:@"picUrl"]);
                [adsURLArray addObject:picURL];
            }
            
            if (adsURLArray.count > 0) {
                _firstCycleView.hidden = NO;
                _firstCycleView.imageURLStringsGroup = adsURLArray;
                _collectionView.frame = CGRectMake(MENU_WIDTH + 8, 8 + ADSHEIGHT, kIphoneWidth - MENU_WIDTH - 16, kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 49 - 16 - ADSHEIGHT);
            } else {
                _firstCycleView.hidden = YES;
                _collectionView.frame = CGRectMake(MENU_WIDTH + 8, 8, kIphoneWidth - MENU_WIDTH - 16, kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 49 - 16);
            }
            
        }
    } failure:^(NSError *error) {
        
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"分类";
    
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.collectionView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(MENU_WIDTH, 0, 8, CGRectGetHeight(self.menuView.frame))];
    lineView.backgroundColor = kBackGrayColor;
    [self.view addSubview:lineView];
    
    _firstCycleView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(MENU_WIDTH + 8, 0, kIphoneWidth - MENU_WIDTH - 16, ADSHEIGHT) delegate:self placeholderImage:kDefaultImage];
    _firstCycleView.showPageControl = YES;
    _firstCycleView.autoScrollTimeInterval = 3.5;
    [self.view addSubview:_firstCycleView];
    
    self.view.backgroundColor = kBackGrayColor;
    
    [self.view startLoadingWithY:0 Height:(kIphoneHeight - SafeAreaBottomHeight - SafeAreaTopHeight)];
    
    [self requestAdsDataWithType:@(2)];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getClassfiyData];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(MENU_WIDTH + 8, 8, kIphoneWidth - MENU_WIDTH - 16, kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 49 - 16) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = kBackGrayColor;
        
        [_collectionView registerNib:[UINib nibWithNibName:@"HomeViewFirstCell" bundle:nil] forCellWithReuseIdentifier:@"HomeViewFirstCell"];
    }
    return _collectionView;
}

- (UIScrollView *)menuView{
    if (!_menuView) {
        _menuView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MENU_WIDTH, kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 49)];
        _menuView.backgroundColor = [UIColor whiteColor];
        _menuView.scrollsToTop = NO;
        _menuView.showsVerticalScrollIndicator = NO;
        
    }
    return _menuView;
}

- (void)setMenuData {
    _menuView.contentSize = CGSizeMake(0, self.dataArray.count * LEFT_BTN_HEIGHT);
    
    for (int i = 1; i <= self.dataArray.count; i++) {
        UIButton *menuButton = [[UIButton alloc] init];
        
        menuButton.tag = i + 1000;
        menuButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [menuButton setTitle:[[self.dataArray objectAtIndex:(i - 1)] name] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, LEFT_BTN_HEIGHT * (i - 1), MENU_WIDTH, LEFT_BTN_HEIGHT);
        if (i == _selectIndex) {
            menuButton.selected = YES;
        }
        [menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [menuButton setTitleColor:kBackGreenColor forState:UIControlStateSelected];
        [menuButton setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(MENU_WIDTH, LEFT_BTN_HEIGHT) andColor:kBackViewColor] forState:UIControlStateNormal];
        [menuButton setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(MENU_WIDTH, LEFT_BTN_HEIGHT) andColor:kBackGrayColor] forState:UIControlStateSelected];
        [_menuView addSubview:menuButton];
        
        YWWeakSelf;
        [[menuButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            for (UIView *view in _menuView.subviews) {
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)view;
                    btn.selected = NO;
                }
            }
            x.selected = YES;
            
            weakSelf.selectIndex = x.tag - 1000;
            
            [weakSelf.collectionView reloadData];
        }];
    }
}

#pragma mark SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSDictionary *dic = _adsArray[index];
    [self requestHotGoodsListWithDic:dic];
}

- (void)requestHotGoodsListWithDic:(NSDictionary *)dic {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[dic objectForKey:@"id"] forKey:@"advertisementInformationId"];
    [HttpTools Get:kAppendUrl(YWHomeHotString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
        
        if ([[dataDic objectForKey:@"flag"] integerValue] == 0) {
            NSArray *goodsArray = [dataDic objectForKey:@"goods"];
            if (goodsArray.count) {
                NSDictionary *goodsDic = [goodsArray firstObject];
                
                GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
                detailVC.goodsID = [goodsDic objectForKey:@"id"];
                [self.navigationController pushViewController:detailVC animated:YES];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark collectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selectIndex > 0 && self.dataArray.count > 0) {
        return [[self.dataArray[_selectIndex - 1] twoClassifications] count];
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CELL_WIDTH, CELL_WIDTH + 24);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeViewFirstCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeViewFirstCell" forIndexPath:indexPath];
    
    if (self.dataArray.count > 0) {
        NSArray *classArr = [self.dataArray[_selectIndex - 1] twoClassifications];
        ClassifyListModel *model = classArr[indexPath.row];
        
        cell.goodsLab.text = model.name;
        
        NSString *imageUrl = model.picUrl;
        if (![imageUrl hasPrefix:@"http"]) {
            imageUrl = kAppendUrl(imageUrl);
        }
        [cell.goodsImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:kDefaultImage];
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *classArr = [self.dataArray[_selectIndex - 1] twoClassifications];
    ClassifyListModel *model = classArr[indexPath.row];
    GoodsListViewController *listVC = [[GoodsListViewController alloc] init];
    listVC.isShowRightBtn = YES;
    listVC.classifId = model.ID;
    listVC.classifArray = classArr;
    [self.navigationController pushViewController:listVC animated:YES];
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
