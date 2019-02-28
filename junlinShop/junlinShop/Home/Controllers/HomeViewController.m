//
//  HomeViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "HomeViewController.h"
#import "SearchViewController.h"
#import "HomeViewHotCell.h"
#import "HomeViewNewGoodsCell.h"
#import "HomeViewSecendCell.h"
#import "SDCycleScrollView.h"
#import "HomeTitleView.h"
#import "HomeHeaderView.h"
#import "HomeCollectionReusableView.h"
#import "UIButton+WebCache.h"
#import "GoodsListViewController.h"
#import "GoodsListSpecViewController.h"
#import "GoodsDetailViewController.h"
#import "NoticeCenterViewController.h"
#import "LoginViewController.h"
#import "JFLocation.h"
#import "JFAreaDataManager.h"
#import "JFCityViewController.h"
#import "YWBaseNavigationController.h"
#import "ActiveDetailViewController.h"
#import "AddShopCarManager.h"
#import "YWCountdownView.h"
#import "IQKeyboardManager.h"

#define cellWith ((kIphoneWidth - 30) / 2)
#define hotCellHeight (180 * kIphoneWidth / 375)
#define homeHeaderHeight (360 * kIphoneWidth / 375 + 155)
#define isHotCollectionView (collectionView == _hotCollectionView)
@interface HomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, SDCycleScrollViewDelegate, JFLocationDelegate, JFCityViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *hotCollectionView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) HomeHeaderView *headerView;
@property (nonatomic, strong) HomeTitleView *titleView;
@property (nonatomic, strong) SDCycleScrollView *firstCycleView;
@property (nonatomic, strong) SDCycleScrollView *presellCycleView;
@property (nonatomic, strong) JFLocation *locationManager;
@property (nonatomic, strong) UIImageView *adsImageView;

@property (nonatomic, strong) NSArray *adsArray;
@property (nonatomic, strong) NSDictionary *adsDic;
@property (nonatomic, strong) NSArray *hotBtnArray;
@property (nonatomic, strong) NSArray *hotGoodsArray;
@property (nonatomic, strong) NSArray *preSellGoodsArray;
@property (nonatomic, strong) NSArray *newsGoodsArray;
@property (nonatomic, strong) NSArray *tuiJianGoodsArray;
@property (nonatomic, strong) NSDictionary *qiangGouDic;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //    [YWUserDefaults setValue:@"48" forKey:@"UserID"];
    
    
    [self setupUI];
    
    [self requestAdsDataWithType:@(1)];
    
    [self requestAdsDataWithType:@(3)];
    [self requestAdsDataWithType:@(4)];
    [self requestAdsDataWithType:@(0)];
    [self requestPreSellGoodsList];
    //    [self setListAction];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
 

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    UIEdgeInsets inset = self.collectionView.contentInset;
    [self.collectionView setContentOffset:CGPointMake(0, - inset.top) animated:NO];
    
    [self requestNewGoodsList];
    [self requestTuiJianGoodsList];
    
    [self getNoticeData];
    
    self.locationManager = [[JFLocation alloc] init];
    _locationManager.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:kRGBColor(110, 110, 110, 0.8)];
    
    //键盘
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enable = YES;
    keyboardManager.shouldResignOnTouchOutside = YES;
    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES;
    keyboardManager.enableAutoToolbar = NO;
    
}

- (UIImageView *)adsImageView {
    if (!_adsImageView) {
        _adsImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _adsImageView.userInteractionEnabled = YES;
        _adsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _adsImageView.image = [UIImage imageNamed:@"launch_Image"];
        _adsImageView.tag = 1200;
        
        YWWeakSelf;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
        [[gesture rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            
            if (weakSelf.adsImageView.tag == 1200) {
                if (_adsDic) {
                    weakSelf.adsImageView.tag = 1201;
                    [weakSelf requestHotGoodsListWithDic:_adsDic];
                }
            }
            
        }];
        [_adsImageView addGestureRecognizer:gesture];
    }
    return _adsImageView;
}

- (UICollectionView *)hotCollectionView {
    if (!_hotCollectionView) {
        UICollectionViewFlowLayout *flowLayot = [[UICollectionViewFlowLayout alloc] init];
        flowLayot.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _hotCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, hotCellHeight) collectionViewLayout:flowLayot];
        _hotCollectionView.backgroundColor = [UIColor whiteColor];
        _hotCollectionView.delegate = self;
        _hotCollectionView.dataSource = self;
        _hotCollectionView.showsHorizontalScrollIndicator = NO;
        
        [_hotCollectionView registerNib:[UINib nibWithNibName:@"HomeViewHotCell" bundle:nil] forCellWithReuseIdentifier:@"HomeViewHotCell"];
        
        [_hotCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeHotCollectHeaderView"];
    }
    return _hotCollectionView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayot = [[UICollectionViewFlowLayout alloc] init];
        flowLayot.scrollDirection = UICollectionViewScrollDirectionVertical;
        CGFloat topHeight = 20;
        if (iphoneX) {
            topHeight = 44;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, -topHeight, kIphoneWidth, kIphoneHeight - 49 - SafeAreaBottomHeight + topHeight) collectionViewLayout:flowLayot];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        _collectionView.contentInset = UIEdgeInsetsMake(homeHeaderHeight, 0, 0, 0);
        
        [_collectionView registerNib:[UINib nibWithNibName:@"HomeViewSecendCell" bundle:nil] forCellWithReuseIdentifier:@"HomeViewSecendCell"];
        [_collectionView registerNib:[UINib nibWithNibName:@"HomeViewNewGoodsCell" bundle:nil] forCellWithReuseIdentifier:@"HomeViewNewGoodsCell"];
        [_collectionView registerNib:[UINib nibWithNibName:@"HomeCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeCollectionReusableView"];
    }
    return _collectionView;
}

- (void)requestAdsDataWithType:(NSNumber *)type {
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:type forKey:@"type"];
    [HttpTools Get:kAppendUrl(YWHomeAdsString) parameters:dic success:^(id responseObject) {
        
        if ([type intValue] == 0) {
            NSDictionary *dic = [[responseObject objectForKey:@"resultData"] firstObject];
            NSString *imageUrl = [dic objectForKey:@"picUrl"];
            if (imageUrl) {
                _adsDic = dic;
                [self.adsImageView sd_setImageWithURL:[NSURL URLWithString:kAppendUrl(imageUrl)] placeholderImage:[UIImage imageNamed:@"launch_Image"]];
                
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0/*延迟执行时间*/ * NSEC_PER_SEC));
                
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    
                    [self.adsImageView removeFromSuperview];
                    
                });
            } else {
                 [self.adsImageView removeFromSuperview];
            }
        } else if ([type intValue] == 1) {
            _adsArray = [responseObject objectForKey:@"resultData"];
            NSMutableArray *adsURLArray = [NSMutableArray array];
            for (NSDictionary *tempDic in _adsArray) {
                NSString *picURL = kAppendUrl([tempDic objectForKey:@"picUrl"]);
                [adsURLArray addObject:picURL];
            }
            _firstCycleView.imageURLStringsGroup = adsURLArray;
        } else if ([type intValue] == 3) {
            _qiangGouDic = [[responseObject objectForKey:@"resultData"] firstObject];
            
            if (_qiangGouDic != nil) {
                _headerView.bottomBackView.hidden = NO;
                UIButton *button = [_headerView.bottomBackView viewWithTag:11010];
                UIImageView *imageView = [_headerView.bottomBackView viewWithTag:11011];
                [imageView sd_setImageWithURL:[NSURL URLWithString: kAppendUrl([_qiangGouDic objectForKey:@"picUrl"])] placeholderImage:kDefaultImage];
                
                if ([[_qiangGouDic objectForKey:@"effectTime"] integerValue] != 0) {
                    YWCountdownView *countDownView = [[[NSBundle mainBundle] loadNibNamed:@"YWCountdownView" owner:nil options:nil] firstObject];
                    countDownView.frame = _headerView.timeBackView.bounds;
                    [_headerView.timeBackView setRadius:4.f];
                    if (_headerView.timeBackView.subviews.count == 0) {
                        [_headerView.timeBackView addSubview:countDownView];
                    }
                    NSString *payDate = [ASHString jsonDateToString:[_qiangGouDic objectForKey:@"effectTime"] withFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSTimeInterval time = [[ASHString NSStringToDate:payDate] timeIntervalSinceDate:[NSDate date]];
                    time += 24 * 60 * 60;
                    [countDownView setToEndTime:time];
                }
                
                
                YWWeakSelf;
                [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                    [weakSelf requestHotGoodsListWithDic:_qiangGouDic];
                }];
            }
            [self setCollectionViewContentInset];
            
        } else if ([type intValue] == 4) {
            _hotBtnArray = [responseObject objectForKey:@"resultData"];
            if (_hotBtnArray.count >= 4) {
                [self setHotBtnData];
                [self setListAction];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestHotGoodsListWithDic:(NSDictionary *)dic {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[dic objectForKey:@"id"] forKey:@"advertisementInformationId"];
    [HttpTools Get:kAppendUrl(YWHomeHotString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
        
        if ([[dataDic objectForKey:@"flag"] integerValue] == 2) {
            _hotGoodsArray = [dataDic objectForKey:@"goods"];
            [_hotCollectionView reloadData];
        } else if ([[dataDic objectForKey:@"flag"] integerValue] == 0) {
            NSArray *goodsArray = [dataDic objectForKey:@"goods"];
            if (goodsArray.count) {
                NSDictionary *goodsDic = [goodsArray firstObject];
                
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:[GoodsDetailViewController class]]) {
                        return;
                    }
                }
                
                GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
                detailVC.goodsID = [goodsDic objectForKey:@"id"];
                [self.navigationController pushViewController:detailVC animated:YES];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestPreSellGoodsList {
    [HttpTools Get:kAppendUrl(@"activityInformation/getAllEffectPreSellActivityInformation") parameters:nil success:^(id responseObject) {
        [self.view stopLoading];
        _preSellGoodsArray = [responseObject objectForKey:@"resultData"];
        [self setCollectionViewContentInset];
        
        if (!_presellCycleView) {
            _presellCycleView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 10, kIphoneWidth, 125) delegate:self placeholderImage:kDefaultImage];
            _presellCycleView.showPageControl = YES;
            _presellCycleView.bannerImageViewContentMode = UIViewContentModeScaleToFill;
            _presellCycleView.autoScrollTimeInterval = 3.5;
            [_headerView.presellBackView addSubview:_presellCycleView];
        }
        NSMutableArray *presellURLArray = [NSMutableArray array];
        for (NSDictionary *tempDic in _preSellGoodsArray) {
            NSString *picURL = kAppendUrl([tempDic objectForKey:@"showPicUrl"]);
            [presellURLArray addObject:picURL];
        }
        _presellCycleView.imageURLStringsGroup = presellURLArray;
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestNewGoodsList {
    [HttpTools Get:kAppendUrl(@"advertisementInformation/getNews_List") parameters:nil success:^(id responseObject) {
        [self.view stopLoading];
        _newsGoodsArray = [responseObject objectForKey:@"resultData"];
        [_collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestTuiJianGoodsList {
    [HttpTools Get:kAppendUrl(@"goodsInformation/getGoodsList?sortType=4&priceSort=""&searchName=""&isHasGoods=true&minPrice=0&maxPrice=0&brandName=all&classificationId=0") parameters:nil success:^(id responseObject) {
        [self.view stopLoading];
        _tuiJianGoodsArray = [responseObject objectForKey:@"resultData"];
        [_collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)getNoticeData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
    [HttpTools Get:kAppendUrl(YWGetMessageNumString) parameters:dict success:^(id responseObject) {
        
        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
        
        BOOL hasNotice = NO;
        if ([[dataDic objectForKey:@"ActivityNum"] integerValue] > 0) {
            hasNotice = YES;
        }
        if ([[dataDic objectForKey:@"UserMessageNum"] integerValue] > 0) {
            hasNotice = YES;
        }
        if ([[dataDic objectForKey:@"orderNum"] integerValue] > 0) {
            hasNotice = YES;
        }
        if (hasNotice) {
            [YWUserDefaults setValue:@"1" forKey:@"HasNotice"];
            _titleView.noticeBtn.badgeValue = @" ";
        }  else {
            _titleView.noticeBtn.badgeValue = @"";
        }
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getNoticeData];
        }];
    }];
}

- (HomeTitleView *)titleView {
    if (!_titleView) {
        [[JFAreaDataManager shareInstance] areaSqliteDBData];
        
        YWWeakSelf;
        _titleView = [[HomeTitleView alloc] initWithLocation:@"北京市" HasNotice:YES];
        _titleView.backgroundColor = [UIColor blackColor];
   
        [[_titleView.locationBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            JFCityViewController *cityViewController = [[JFCityViewController alloc] init];
            cityViewController.delegate = self;
            cityViewController.title = @"城市";
            YWBaseNavigationController *navigationController = [[YWBaseNavigationController alloc] initWithRootViewController:cityViewController];
            [weakSelf presentViewController:navigationController animated:YES completion:nil];
        }];
        [[_titleView.noticeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            NoticeCenterViewController *noticeVC = [[NoticeCenterViewController alloc] init];
            [weakSelf.navigationController pushViewController:noticeVC animated:YES];
        }];
        _titleView.clickSearchBar = ^{
            SearchViewController *searchVC = [[SearchViewController alloc] init];
            [weakSelf.navigationController pushViewController:searchVC animated:YES];
        };
    }
    return _titleView;
}

- (void)addBanner{
    _headerView = [[[NSBundle mainBundle] loadNibNamed:@"HomeHeaderView" owner:nil options:nil] firstObject];
    _headerView.frame = CGRectMake(0, homeHeaderHeight, kIphoneWidth, homeHeaderHeight);
    _headerView.backgroundColor = UIColor.whiteColor;
    
    _firstCycleView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kIphoneWidth, CGRectGetHeight(_headerView.topCycleBackView.frame) * kIphoneWidth / 375.0) delegate:self placeholderImage:nil];
    _firstCycleView.showPageControl = YES;
    _firstCycleView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    _firstCycleView.autoScrollTimeInterval = 3.5;
    _firstCycleView.backgroundColor = UIColor.orangeColor;
    [_headerView.topCycleBackView addSubview:_firstCycleView];
    
}
- (void)setupUI{
    [YWWindow addSubview:self.adsImageView];
    [self addBanner];
    [_headerView.qiangGouBackView addSubview:self.hotCollectionView];
    
    YWWeakSelf;
    [[_headerView.moreBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        GoodsListSpecViewController *listVC = [[GoodsListSpecViewController alloc] init];
        listVC.titleStr = @"热门促销";
        listVC.goodsArray = _hotGoodsArray;
        [weakSelf.navigationController pushViewController:listVC animated:YES];
    }];
    
    [self.collectionView addSubview:_headerView];
    [self.view addSubview:self.collectionView];
    
    [self.view addSubview:self.titleView];
   
}

- (void)setCollectionViewContentInset {
    
    CGFloat bottomViewHeight = 0;
    _headerView.qiangGouHeightConstraint.constant = 130;
    _headerView.presellBackViewHeightConstant.constant = 135;
    if (_qiangGouDic == nil && _preSellGoodsArray.count == 0) {
        bottomViewHeight = 0;
        _headerView.qiangGouHeightConstraint.constant = 0.1;
        _headerView.presellBackViewHeightConstant.constant = 0.1;
        _headerView.bottomBackView.hidden = YES;
        _headerView.presellBackView.hidden = YES;
    } else if (_qiangGouDic != nil && _preSellGoodsArray.count != 0) {
        _headerView.bottomBackView.hidden = NO;
        _headerView.presellBackView.hidden = NO;
        bottomViewHeight = 130 + 135;
    } else if (_qiangGouDic != nil) {
        _headerView.bottomBackView.hidden = NO;
        _headerView.presellBackView.hidden = YES;
        _headerView.presellBackViewHeightConstant.constant = 0.1;
        bottomViewHeight = 130;
    } else if (_preSellGoodsArray.count != 0) {
        _headerView.bottomBackView.hidden = YES;
        _headerView.presellBackView.hidden = NO;
        _headerView.qiangGouHeightConstraint.constant = 0.1;
        bottomViewHeight = 135;
    }
    CGFloat titleH = self.titleView.height;
    CGFloat headerH = homeHeaderHeight + bottomViewHeight;
    _headerView.frame = CGRectMake(0,-headerH, kIphoneWidth, homeHeaderHeight + bottomViewHeight);
    _collectionView.contentInset = UIEdgeInsetsMake(headerH+titleH, 0, 0, 0);
    
    UIEdgeInsets inset = self.collectionView.contentInset;
    [self.collectionView setContentOffset:CGPointMake(0, - inset.top) animated:NO];
}

- (void)setListAction {
    for (int i = 0; i < 4; i ++) {
        UIView *backView = [_headerView.stackView viewWithTag:1000 + i];
        UIButton *button = [backView viewWithTag:1200];
        UILabel *titleLab = [backView viewWithTag:1100];
        
        
        [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            
            if (i == 1) {
                
                if (_qiangGouDic) {

                    [self requestHotGoodsListWithDic:_qiangGouDic];
                } else {
                    [SVProgressHUD showInfoWithStatus:@"暂时未有抢购商品"];
                }
                return ;
            }
            
            
            NSDictionary *dic = _hotBtnArray[i];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[dic objectForKey:@"id"] forKey:@"advertisementInformationId"];
            [HttpTools Get:kAppendUrl(YWHomeHotString) parameters:dict success:^(id responseObject) {
                [self.view stopLoading];
                NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
                
                GoodsListSpecViewController *listVC = [[GoodsListSpecViewController alloc] init];
                listVC.titleStr = titleLab.text;
                listVC.goodsArray = [dataDic objectForKey:@"goods"];
                [self.navigationController pushViewController:listVC animated:YES];
                
            } failure:^(NSError *error) {
                
            }];
            
        }];
    }
}

- (void)setHotBtnData {
    
    for (int i = 0; i < _hotBtnArray.count; i ++) {
        NSDictionary *dic = _hotBtnArray[i];
        if (i == 0) {
            [self requestHotGoodsListWithDic:dic];
        }
        UIView *backView = [_headerView.stackView viewWithTag:1000 + i];
        UIButton *button = [backView viewWithTag:1200];
        UILabel *titleLab = [backView viewWithTag:1100];
        if (i == 1) {

        } else {
            [button sd_setImageWithURL:[NSURL URLWithString:kAppendUrl([dic objectForKey:@"picUrl"])] forState:UIControlStateNormal];
            titleLab.text = [dic objectForKey:@"name"];
        }
    }
}

#pragma mark --- JFLocationDelegate
//定位中...
- (void)locating {
    NSLog(@"定位中...");
}

//定位成功
- (void)currentLocation:(NSDictionary *)locationDictionary {
    NSString *city = [locationDictionary valueForKey:@"City"];
    if (![_titleView.locationBtn.currentTitle isEqualToString:city]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"您定位到%@，确定切换城市吗？",city] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([city containsString:@"北京"]) {
                [_titleView.locationBtn setTitle:city forState:UIControlStateNormal];
                [YWUserDefaults setObject:city forKey:@"locationCity"];
                [YWUserDefaults setObject:city forKey:@"currentCity"];
                [[JFAreaDataManager shareInstance] cityNumberWithCity:city cityNumber:^(NSString *cityNumber) {
                    [YWUserDefaults setObject:cityNumber forKey:@"cityNumber"];
                }];
            } else {
                [SVProgressHUD showInfoWithStatus:@"目前只开放北京地区"];
            }
            
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

/// 拒绝定位
- (void)refuseToUsePositioningSystem:(NSString *)message {
    NSLog(@"%@",message);
}

/// 定位失败
- (void)locateFailure:(NSString *)message {
//    [SVProgressHUD showSuccessWithStatus:@"定位失败"];
    NSLog(@"%@",message);
}

#pragma mark - JFCityViewControllerDelegate
- (void)cityName:(NSString *)name {
    if ([name containsString:@"北京"]) {
        [_titleView.locationBtn setTitle:name forState:UIControlStateNormal];
    } else {
        [SVProgressHUD showInfoWithStatus:@"目前只开放北京地区"];
    }
}

#pragma mark SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    
    if (cycleScrollView == _firstCycleView) {
        NSDictionary *dic = _adsArray[index];
        [self requestHotGoodsListWithDic:dic];
    } else {
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[ActiveDetailViewController class]]) {
                return;
            }
        }
        
        NSDictionary *dic = _preSellGoodsArray[index];
        ActiveDetailViewController *detailVC = [[ActiveDetailViewController alloc] init];
        detailVC.activeID = [dic objectForKey:@"id"];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark collectionView代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    if (isHotCollectionView) {
//        return 1;
//    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (isHotCollectionView) {
        return _hotGoodsArray.count;
    }
    if (_tuiJianGoodsArray.count > 6) {
        return 6;
    }
    return _tuiJianGoodsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isHotCollectionView) {
        HomeViewHotCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeViewHotCell" forIndexPath:indexPath];
        
        NSDictionary *dic = _hotGoodsArray[indexPath.row];
        [cell setDataWithDic:dic];
        
        YWWeakSelf;
        [[[cell.qiangBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            
            if (![YWUserDefaults objectForKey:@"UserID"]) {
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                [weakSelf.navigationController pushViewController:loginVC animated:YES];
                return ;
            }
            [AddShopCarManager addGoodsToShopCarWithGoodsDic:dic orGoodsSkuDic:nil andBuyCount:1 WithCouponId:nil];
           
        }];
        
        return cell;
    } else {
        
        HomeViewSecendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeViewSecendCell" forIndexPath:indexPath];
        [cell setDataWithDic:_tuiJianGoodsArray[indexPath.row]];
        return cell;
        
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (isHotCollectionView) {
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeHotCollectHeaderView" forIndexPath:indexPath];
        reusableview.backgroundColor = [UIColor clearColor];
        return reusableview;
    }
    HomeCollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeCollectionReusableView" forIndexPath:indexPath];
    for (int i = 0; i < _newsGoodsArray.count; i ++) {
        UIButton *button = [reusableview viewWithTag:1000 + i];
        UILabel  *titleLab = [reusableview viewWithTag:1100 + i];
        
        NSDictionary *dict = _newsGoodsArray[i];
        NSString *picURL = kAppendUrl([dict objectForKey:@"picUrl"]);
        [button sd_setBackgroundImageWithURL:[NSURL URLWithString:picURL] forState:UIControlStateNormal];
        titleLab.text = [dict objectForKey:@"name"];
        
        [button addTarget:self action:@selector(clickReuseViewButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //新品上架
    [reusableview.topMoreBtn addTarget:self action:@selector(clickReuseViewTopMoreButton) forControlEvents:UIControlEventTouchUpInside];
    //热门推荐
    [reusableview.bottomMoreBtn addTarget:self action:@selector(clickReuseViewBottonMoreButton) forControlEvents:UIControlEventTouchUpInside];
    
    return reusableview;
}

- (void)clickReuseViewButton:(UIButton *)button {
    NSInteger index = button.tag - 1000;
    if (index < _newsGoodsArray.count) {
        NSDictionary *dict = _newsGoodsArray[index];
        [self getToSpecListWithDic:dict];
    }
}

- (void)getToSpecListWithDic:(NSDictionary *)dic {
    GoodsListSpecViewController *listVC = [[GoodsListSpecViewController alloc] init];
    listVC.titleStr = [dic objectForKey:@"name"];
    listVC.newsID = [dic objectForKey:@"id"];
    [self.navigationController pushViewController:listVC animated:YES];
}

/**
 新品上架
 */
- (void)clickReuseViewTopMoreButton {
    if (_hotBtnArray.count < 2) {
        return;
    }
    NSDictionary *dic = _hotBtnArray[1];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[dic objectForKey:@"id"] forKey:@"advertisementInformationId"];
    [HttpTools Get:kAppendUrl(YWHomeHotString) parameters:dict success:^(id responseObject) {
        
        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
        
        GoodsListSpecViewController *listVC = [[GoodsListSpecViewController alloc] init];
        listVC.titleStr = @"新品上架";
        listVC.goodsArray = [dataDic objectForKey:@"goods"];
        [self.navigationController pushViewController:listVC animated:YES];
        
    } failure:^(NSError *error) {
        
    }];
    
}
//热门推荐
- (void)clickReuseViewBottonMoreButton {
    
    [SVProgressHUD show];
    [HttpTools Get:kAppendUrl(@"goodsInformation/getGoodsList?sortType=2&priceSort=""&searchName=""&isHasGoods=true&minPrice=0&maxPrice=0&brandName=all&classificationId=0") parameters:nil success:^(id responseObject) {
        [self.view stopLoading];
        
        if ([[responseObject objectForKey:@"resultData"] isKindOfClass:[NSArray class]]) {
            
            GoodsListSpecViewController *listVC = [[GoodsListSpecViewController alloc] init];
            listVC.titleStr = @"热门推荐";
            listVC.goodsArray = [responseObject objectForKey:@"resultData"];
            [self.navigationController pushViewController:listVC animated:YES];
            
        }
       
    } failure:^(NSError *error) {
        
    }];
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (isHotCollectionView) {
        return CGSizeMake(0.1, 0.1);
    }
    return CGSizeMake(kIphoneWidth, kIphoneWidth);
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (isHotCollectionView) {
        return CGSizeMake((kIphoneWidth - 30) / 3, hotCellHeight);
    } else {
        return CGSizeMake(cellWith, cellWith + 45);
    }
}


//定义每个Section /collectionView(指定区)的边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (isHotCollectionView) {
        return UIEdgeInsetsMake(1, 5, 1, 5);
    } else {
        return UIEdgeInsetsMake(5, 5, 5, 5);
    }
}

//设定指定区内Cell的最小行距，也可以直接设置UICollectionViewFlowLayout的minimumLineSpacing属性
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

//..设定指定区内Cell的最小间距，也可以直接设置UICollectionViewFlowLayout的minimumInteritemSpacing属性
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (isHotCollectionView) {
        NSDictionary *dic = _hotGoodsArray[indexPath.row];
        [self pushToGoodsDetailVCWithID:[dic objectForKey:@"id"]];
    } else {
        NSDictionary *dic = _tuiJianGoodsArray[indexPath.row];
        [self pushToGoodsDetailVCWithID:[dic objectForKey:@"id"]];
    }
}

- (void)pushToGoodsDetailVCWithID:(NSNumber *)goodsID {
    GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
    detailVC.goodsID = goodsID;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"11");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"--%f", scrollView.contentOffset.y);
    if (scrollView == _collectionView) {
        if (scrollView.contentOffset.y > SafeAreaTopHeight + 20 - homeHeaderHeight) {
            _titleView.backgroundColor =  [UIColor blackColor];kBackGreenColor;
        } else {
            _titleView.backgroundColor = [UIColor blackColor];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 

@end
