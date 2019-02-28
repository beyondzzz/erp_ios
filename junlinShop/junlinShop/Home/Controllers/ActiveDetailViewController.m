//
//  ActiveDetailViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/13.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ActiveDetailViewController.h"
#import "ActiceDetailHeaderView.h"
#import "ActiveDetailCollectionCell.h"
#import "ActiveQuanCollectionCell.h"
#import "GoodsDetailViewController.h"

#define homeHeaderHeight (230)
@interface ActiveDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ActiceDetailHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *goodsArray;
@property (nonatomic, strong) NSMutableArray *couponArray;

@end

@implementation ActiveDetailViewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayot = [[UICollectionViewFlowLayout alloc] init];
        flowLayot.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) collectionViewLayout:flowLayot];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        _collectionView.contentInset = UIEdgeInsetsMake(homeHeaderHeight, 0, 0, 0);
        
        [_collectionView registerNib:[UINib nibWithNibName:@"ActiveDetailCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ActiveDetailCollectionCell"];
        [_collectionView registerNib:[UINib nibWithNibName:@"ActiveQuanCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ActiveQuanCollectionCell"];
        
        [self loadHeaderView];
    }
    return _collectionView;
}

- (void)loadHeaderView {
    _headerView = [[[NSBundle mainBundle] loadNibNamed:@"ActiceDetailHeaderView" owner:nil options:nil] firstObject];
    _headerView.frame = CGRectMake(0, - homeHeaderHeight, kIphoneWidth, homeHeaderHeight);
    [_collectionView addSubview:_headerView];
    
}

- (void)requestInfoData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_activeID forKey:@"activityInformationId"];
    [HttpTools Get:kAppendUrl(YWActivityInformationString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        
        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
        
        for (NSDictionary *dic in [dataDic objectForKey:@"couponInformation"]) {
            [_couponArray addObject:dic];
        }
        for (NSDictionary *dic in [dataDic objectForKey:@"goods"]) {
            [_goodsArray addObject:dic];
        }
        
        [self setHeaderviewDataWithDic:[dataDic objectForKey:@"activityInformation"]];
        
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)setHeaderviewDataWithDic:(NSDictionary *)dict {
    if ([dict objectForKey:@"showPicUrl"]) {
        [_headerView.topImageView sd_setImageWithURL:[NSURL URLWithString:kAppendUrl([dict objectForKey:@"showPicUrl"])] placeholderImage:kDefaultImage];
    }
    _headerView.titleLab.text = [dict objectForKey:@"name"];
    
    NSString *beginStr = [ASHString jsonDateToString:[dict objectForKey:@"beginValidityTime"] withFormat:@"yyyy年MM月dd HH:mm"];
    NSString *endStr = [ASHString jsonDateToString:[dict objectForKey:@"endValidityTime"] withFormat:@"yyyy年MM月dd HH:mm"];
    _headerView.detailLab.text = [NSString stringWithFormat:@"%@至%@", beginStr, endStr];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _goodsArray = [NSMutableArray array];
    _couponArray = [NSMutableArray array];
    
    self.navigationItem.title = @"活动详情";
    
    [self.view addSubview:self.collectionView];
    
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    [self requestInfoData];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark collectionView代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _couponArray.count;
    } else {
        return _goodsArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ActiveQuanCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ActiveQuanCollectionCell" forIndexPath:indexPath];
        [cell setDataWithDic:_couponArray[indexPath.row]];
        return cell;
    } else {
        ActiveDetailCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ActiveDetailCollectionCell" forIndexPath:indexPath];
        [cell setDataWithDic:_goodsArray[indexPath.row]];
        return cell;
    }
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake((kIphoneWidth - 30) / 3, 130);
    } else {
        return CGSizeMake((kIphoneWidth - 40) / 4, (kIphoneWidth - 40) / 4 + 45);
    }
}


//定义每个Section /collectionView(指定区)的边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
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
    if (indexPath.section == 1) {
        GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
        detailVC.goodsID = [_goodsArray[indexPath.row] objectForKey:@"id"];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
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
