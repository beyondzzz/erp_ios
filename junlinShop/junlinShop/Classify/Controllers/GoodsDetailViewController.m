 //
//  GoodsDetailViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/1/19.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "GoodsDetailWebController.h"
#import "CommentViewController.h"
#import "GoodsDetailView.h"
#import "SegmentSelectView.h"
#import "SDCycleScrollView.h"
#import "GoodsDetailTableCell.h"
#import "CommentTableViewCell.h"
#import "AddressListViewController.h"
#import "SkuSelectView.h"
#import "ShopCarViewController.h"
#import "MakeOrderViewController.h"
#import "YWWebViewController.h"
#import "LoginViewController.h"
#import "AddressModel.h"
#import "AddShopCarManager.h"

#define kHeaderViewHeight ((kIphoneWidth * 3) / 5 + 90)
@interface GoodsDetailViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate, SegmentSelectViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) GoodsDetailView *headerView;

@property (nonatomic, strong) NSDictionary *detailDic;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) SegmentSelectView *selectView;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) NSDictionary *selectSpecDic;
@property (nonatomic, strong) AddressModel *addressModel;
@property (nonatomic) NSInteger buyCount;

@end

@implementation GoodsDetailViewController
- (void)loadHeaderView {
    _headerView = [[[NSBundle mainBundle] loadNibNamed:@"GoodsDetailView" owner:nil options:nil] firstObject];
    _headerView.frame = CGRectMake(0, 0, kIphoneWidth, kHeaderViewHeight);
 
    _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kIphoneWidth, kHeaderViewHeight - 90) delegate:self placeholderImage:[UIImage imageNamed:@"placeHolder_Image"]];
    _cycleScrollView.showPageControl = YES;
    _cycleScrollView.autoScroll = NO;
    _cycleScrollView.contentMode = UIViewContentModeScaleAspectFit;
    [_headerView.imageBackView insertSubview:_cycleScrollView belowSubview:_headerView.titleLab];;
    
    _tableView.tableHeaderView = _headerView;
}
- (UIScrollView *)backScrollView {
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight-SafeAreaTopHeight-SafeAreaBottomHeight-45)];
        _backScrollView.showsHorizontalScrollIndicator = NO;
        _backScrollView.contentSize = CGSizeMake(kIphoneWidth * 3, CGRectGetHeight(_backScrollView.frame));
        _backScrollView.delegate = self;
        _backScrollView.pagingEnabled = YES;
    }
    return _backScrollView;
}

-(void)setUpChildViewControllers {
    GoodsDetailWebController *goodsWebVC = [[GoodsDetailWebController alloc] init];
    goodsWebVC.view.frame = CGRectMake(kIphoneWidth, 0, kIphoneWidth, CGRectGetHeight(_backScrollView.frame));
    goodsWebVC.goodsId = _goodsID;
    [_backScrollView addSubview:goodsWebVC.view];
    [self addChildViewController:goodsWebVC];
    
    CommentViewController *commentVC = [[CommentViewController alloc] init];
    commentVC.view.frame = CGRectMake(kIphoneWidth * 2, 0, kIphoneWidth, CGRectGetHeight(_backScrollView.frame));
    commentVC.goodsId = _goodsID;
    [_backScrollView addSubview:commentVC.view];
    [self addChildViewController:commentVC];
}

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, CGRectGetHeight(_backScrollView.frame)) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"GoodsDetailTableCell" bundle:nil] forCellReuseIdentifier:@"GoodsDetailTableCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
        
        [self loadHeaderView];
        
        [self.backScrollView addSubview:_tableView];
    }
}



- (void)createTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 90)];
    footerView.backgroundColor = kBackViewColor;
    
    NSInteger count = [[_detailDic objectForKey:@"goodsEvaluations"] count];
    if (count > 2) {
        UIButton *moreCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreCarBtn setTitle:@"查看更多评论" forState:UIControlStateNormal];
        moreCarBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        moreCarBtn.frame = CGRectMake((kIphoneWidth - 120) / 2, 15, 120, 32);
        [moreCarBtn setTitleColor:kBackYellowColor forState:UIControlStateNormal];
        [moreCarBtn setBorder:kBackYellowColor width:1.f radius:3.f];
        [footerView addSubview:moreCarBtn];
        
        YWWeakSelf;
        [[moreCarBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [weakSelf.selectView srcollToSelectedBtnAtIndex:2];
            weakSelf.backScrollView.contentOffset = CGPointMake(kIphoneWidth * 2, 0);
        }];
        
        UILabel *textLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(moreCarBtn.frame) + 15, kIphoneWidth, 20)];
        textLab.text = @"下拉查看商品详情";
        textLab.textAlignment = NSTextAlignmentCenter;
        textLab.font = [UIFont systemFontOfSize:14];
        textLab.textColor = kGrayTextColor;
        [footerView addSubview:textLab];
        
    } else {
        
        footerView.frame = CGRectMake(0, 0, kIphoneWidth, 40);
        UILabel *textLab = [[UILabel alloc] initWithFrame:CGRectMake(0,  15, kIphoneWidth, 20)];
        textLab.text = @"下拉查看商品详情";
        textLab.textAlignment = NSTextAlignmentCenter;
        textLab.font = [UIFont systemFontOfSize:14];
        textLab.textColor = kGrayTextColor;
        [footerView addSubview:textLab];
    }
    
    
    self.tableView.tableFooterView = footerView;
}

- (void)requestAddressData {
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    if (userID == nil) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWAddressListString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        NSArray *dataArr = [responseObject objectForKey:@"resultData"];
        if (dataArr.count == 0) {
            return ;
        }
        
        NSDictionary *addressDic = [dataArr firstObject];
        if (addressDic) {
            self.addressModel = [[AddressModel alloc] init];
            [self.addressModel mj_setKeyValues:addressDic];
        }
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf requestAddressData];
        }];
    }];
}

- (void)getGoodsDetailData {
    if (_goodsID == nil) {
        [self.view stopLoading];
        return;
    }
    [HttpTools Get:kAppendUrl(YWGoodsDetailString) parameters:@{@"goodsId":_goodsID} success:^(id responseObject) {
        [self.view stopLoading];
        self.detailDic =[responseObject objectForKey:@"resultData"];
        
        NSArray *specArr = [_detailDic objectForKey:@"goodsSpecificationDetails"];
        _selectSpecDic = [specArr firstObject];
        [self changeCycsrollerImageWithSpecID:[_selectSpecDic objectForKey:@"id"]];
        [self setHeaderViewData];
        
        [self createTableFooterView];
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getGoodsDetailData];
        }];
    }];
}

- (void)setHeaderViewData {
//    _headerView.titleLab.text = [_detailDic objectForKey:@"name"];
    _headerView.introdutionLab.text = [_detailDic objectForKey:@"name"];
    _headerView.detailLab.text = [_detailDic objectForKey:@"introdution"];
}

- (void)changeCycsrollerImageWithSpecID:(NSNumber *)specID {
    NSArray *specArr = [_detailDic objectForKey:@"goodsSpecificationDetails"];
    NSArray *picArr = nil;
    for (NSDictionary *dic in specArr) {
        if ([specID intValue] == [[dic objectForKey:@"id"] intValue]) {
            picArr = [dic objectForKey:@"goodsDisplayPictures"];
            
            _headerView.priceLab.text = [NSString stringWithFormat:@" ¥ %.2f ", [[dic objectForKey:@"price"] floatValue]];
            
            if ([[dic objectForKey:@"oldPrice"] floatValue] == 0) {
                _headerView.oldPriceLab.hidden = YES;
            } else {
                _headerView.oldPriceLab.hidden = NO;
            }
            NSString *priceStr = [NSString stringWithFormat:@"¥ %.2f", [[dic objectForKey:@"oldPrice"] floatValue]];
            NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
            
            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:priceStr attributes:attribtDic];
            _headerView.oldPriceLab.attributedText = att;
            
            _headerView.saleCountLab.text = [NSString stringWithFormat:@"已售%@件", [dic objectForKey:@"salesCount"]];
        }
    }
    NSMutableArray *imageUrlArr = [NSMutableArray array];
    for (NSDictionary *dic in picArr) {
        NSString *urlstr = [dic objectForKey:@"picUrl"];
        [imageUrlArr addObject:kAppendUrl(urlstr)];
    }
    self.cycleScrollView.imageURLStringsGroup = imageUrlArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _buyCount = 1;
    
    _selectView = [[SegmentSelectView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth / 2, 40) andTitleArray:@[@"商品", @"详情", @"评价"] andImageNameArray:nil byType:SegmentViewTypeBottonLine];
    UIView *lineView = [_selectView viewWithTag:1250];
    lineView.hidden = YES;
    UIView *lineView02 = [_selectView viewWithTag:1260];
    lineView02.hidden = YES;
    _selectView.delegate = self;
    self.navigationItem.titleView = _selectView;
    
    SegmentSelectView *segmentView = [[SegmentSelectView alloc] initWithFrame:CGRectMake(0, kIphoneHeight - SafeAreaBottomHeight - 45 - SafeAreaTopHeight, kIphoneWidth, 45) andTitleArray:@[@"客服", @"购物车", @"加入购物车", @"立即购买"] andImageNameArray:nil byType:SegmentViewTypeBuy];
    segmentView.delegate = self;
    [self.view addSubview:segmentView];
    
    [self.view addSubview:self.backScrollView];
    [self setUpChildViewControllers];
    [self createTableView];
    
    [self getGoodsDetailData];
    [self requestAddressData];
 }

#pragma mark SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    
}

#pragma mark SegmentSelectViewDelegate
- (void)clickButton:(UIButton *)button AtIndex:(NSInteger)index {
    if (CGRectGetHeight(button.frame) == 45) { //底部
        
        if (![YWUserDefaults objectForKey:@"UserID"]) {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            [self.navigationController pushViewController:loginVC animated:YES];
            return;
        }
        
        switch (index) {
            case 0: {
                YWWebViewController *webVC = [[YWWebViewController alloc] init];
                NSDictionary *dict = [YWUserDefaults objectForKey:@"UserInfo"];
                webVC.titleStr = @"客服服务";
                webVC.webURL = [NSString stringWithFormat:@"%@%@&userName=%@&isVip=%@&clientId=%@", YWServiceHtmlString, [dict objectForKey:@"userPhone"],  [dict objectForKey:@"userName"], [dict objectForKey:@"isVIP"], [dict objectForKey:@"userId"]];
                [self.navigationController pushViewController:webVC animated:YES];
            }
                break;
            case 1: {
                ShopCarViewController *shopCarVC = [[ShopCarViewController alloc] init];
                [self.navigationController pushViewController:shopCarVC animated:YES];
            }
                break;
            case 2: {
                
                NSArray *skuArr = [_detailDic objectForKey:@"goodsSpecificationDetails"];
                SkuSelectView *skuSelectView = [[SkuSelectView alloc] init];
                skuSelectView.skusArr = skuArr;
                
                YWWeakSelf;
                skuSelectView.selectedSkuByShop = ^(NSDictionary *skuDic, NSInteger selectNum, NSInteger skuType) {
                    
                    if (skuType == 3) {
                        [weakSelf joinToShopCarBySkuDic:skuDic andSelectNum:selectNum];
                    } else if (skuType == 4) {
                        weakSelf.selectSpecDic = skuDic;
                        weakSelf.buyCount = selectNum;
                        [weakSelf.tableView reloadData];
                    }
                    
                };

                
            }
                break;
            default: {
                
                NSArray *skuArr = [_detailDic objectForKey:@"goodsSpecificationDetails"];
                
                SkuSelectView *skuSelectView = [[SkuSelectView alloc] init];
                skuSelectView.skusArr = skuArr;
                skuSelectView.selectNum = self.buyCount;
                skuSelectView.skuDic = self.selectSpecDic;
                
                YWWeakSelf;
                skuSelectView.selectedSkuByShop = ^(NSDictionary *skuDic, NSInteger selectNum, NSInteger skuType) {
                    
                    if (skuType == 3) {
                        [weakSelf buyNowBySkuDic:skuDic andSelectNum:selectNum];
                    } else if (skuType == 4) {
                        weakSelf.selectSpecDic = skuDic;
                        weakSelf.buyCount = selectNum;
                        [weakSelf.tableView reloadData];
                    }
                    
                    
                };
            }
                break;
        }
    } else {
        
        _backScrollView.contentOffset = CGPointMake(kIphoneWidth * index, 0);
        
    }
}

- (void)joinToShopCarBySkuDic:(NSDictionary *)skuDic andSelectNum:(NSInteger)selectNum {
    
    [AddShopCarManager addGoodsToShopCarWithGoodsDic:_detailDic orGoodsSkuDic:skuDic andBuyCount:selectNum WithCouponId:nil];
}

- (void)buyNowBySkuDic:(NSDictionary *)skuDic andSelectNum:(NSInteger)selectNum {
    
    if ([[_detailDic objectForKey:@"zeroStock"] integerValue] == 0 && [[skuDic objectForKey:@"gxcGoodsState"] integerValue] == 2) {
        
        if ([[_detailDic objectForKey:@"state"] integerValue] == 1 || [[skuDic objectForKey:@"gxcGoodsStock"] integerValue] <= 0) {
            [SVProgressHUD showInfoWithStatus:@"抱歉，您购买的商品已售空，请选择其他同类商品"];
            return;
        }
        if ([[skuDic objectForKey:@"gxcGoodsStock"] integerValue] - selectNum < 0) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"抱歉，您购买的部分商品库存数量不足，继续下单将购买当前商品的剩余数量" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"继续下单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSInteger buyNum = [[skuDic objectForKey:@"gxcGoodsStock"] integerValue];
                [self createOrderBySkuDic:skuDic andSelectNum:buyNum];
                [alertController dismissViewControllerAnimated:YES completion:nil];
                
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
    }
    
    [self createOrderBySkuDic:skuDic andSelectNum:selectNum];
    
}

- (void)createOrderBySkuDic:(NSDictionary *)skuDic andSelectNum:(NSInteger)selectNum {
    MakeOrderViewController *makeOrderVC = [[MakeOrderViewController alloc] init];
    
    NSMutableArray *goodsArray = [NSMutableArray array];
    
    NSMutableDictionary *goodDetailDic = [NSMutableDictionary dictionary];
    [goodDetailDic setValue:[self.detailDic objectForKey:@"id"] forKey:@"goodsDetailsId"];
    [goodDetailDic setValue:@(selectNum) forKey:@"goodsQuantity"];
    [goodDetailDic setValue:[skuDic objectForKey:@"id"] forKey:@"goodsSpecificationDetailsId"];
    [goodDetailDic setValue:[skuDic objectForKey:@"gxcPurchase"] forKey:@"goodsPurchasingPrice"];
    [goodDetailDic setValue:[skuDic objectForKey:@"price"] forKey:@"goodsOriginalPrice"];
    CGFloat price = [[skuDic objectForKey:@"price"] floatValue];
    [goodDetailDic setValue:[NSNumber numberWithFloat:(price * selectNum)] forKey:@"goodsPaymentPrice"];
    [goodDetailDic setValue:[self.detailDic objectForKey:@"name"] forKey:@"goodsName"];
    [goodDetailDic setValue:[[[skuDic objectForKey:@"goodsDisplayPictures"] firstObject] objectForKey:@"picUrl"] forKey:@"goodsCoverUrl"];
    [goodDetailDic setValue:[skuDic objectForKey:@"specifications"] forKey:@"goodsSpecificationName"];
    [goodDetailDic setValue:[_detailDic objectForKey:@"zeroStock"] forKey:@"zeroStock"];
    
    BOOL isYushou = NO;
    if ([[_detailDic objectForKey:@"goodsSpecificationDetails"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in [_detailDic  objectForKey:@"goodsSpecificationDetails"]) {
            if ([[dic objectForKey:@"gxcGoodsState"] integerValue] == 1) {
                isYushou = YES;
                NSArray *activeArr = [_detailDic objectForKey:@"goodsActivitys"];
                makeOrderVC.yuShouActiveId = [[activeArr firstObject] objectForKey:@"id"];
                
            }
        }
    }
    
    NSMutableArray *detailActArr = [NSMutableArray array];
    NSMutableArray *specActArr = [NSMutableArray array];
    
    if (isYushou) {
        NSArray *activeArr = [_detailDic objectForKey:@"goodsActivitys"];
        for (NSDictionary *actDic in activeArr) {
            [detailActArr addObject:[actDic objectForKey:@"activityInformation"]];
        }
        
        for (NSDictionary *actDic in activeArr) {
            [specActArr addObject:actDic];
        }
    } else {
        for (NSDictionary *actDic in [self.detailDic objectForKey:@"goodsActivitys"]) {
            [detailActArr addObject:[actDic objectForKey:@"activityInformation"]];
        }
        
        for (NSDictionary *actDic in [skuDic objectForKey:@"goodsActivitys"]) {
            [specActArr addObject:actDic];
        }
    }
    [goodDetailDic setValue:detailActArr forKey:@"detailActArray"];
    [goodDetailDic setValue:specActArr forKey:@"specActArray"];
    
    [goodsArray addObject:goodDetailDic];
    
    
    makeOrderVC.orderPrice = [NSString stringWithFormat:@"%.2f", price * selectNum];
    makeOrderVC.goodsArray = goodsArray;
    makeOrderVC.addressModel = self.addressModel;
    
    [self.navigationController pushViewController:makeOrderVC animated:YES];
}

#pragma mark - <UIScrollViewDelegate>
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        NSInteger count = [[_detailDic objectForKey:@"goodsEvaluations"] count];
        if (count > 3) {
            return 3;
        }
        return count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            return 75;
        } else if (indexPath.row == 0) {
            if ([[_selectSpecDic objectForKey:@"gxcGoodsState"] integerValue] == 2) {
                NSArray *activeArr = [_selectSpecDic objectForKey:@"goodsActivitys"];
                if (activeArr.count > 1) {
                    return 50 + 40 * (activeArr.count - 1);
                } else {
                    return 50;
                }
            } else {
                NSArray *activeArr = [_detailDic objectForKey:@"goodsActivitys"];
                if (activeArr.count > 1) {
                    return 50 + 40 * (activeArr.count - 1);
                } else {
                    return 50;
                }
            }
            
        }
        return 50;
    }
    NSArray *commentArr = [_detailDic objectForKey:@"goodsEvaluations"];
    return [CommentTableViewCell getCellHeightWithDic:commentArr[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GoodsDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsDetailTableCell" forIndexPath:indexPath];
        [cell setUIHiddenAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            
            NSArray *activeArr = [_selectSpecDic objectForKey:@"goodsActivitys"];
            if ([[_selectSpecDic objectForKey:@"gxcGoodsState"] integerValue] == 1) {
                activeArr = [_detailDic objectForKey:@"goodsActivitys"];
            }
            
            for (UIView *view in cell.contentView.subviews) {
                if (view.tag >= 2000 && view.tag < 2010) {
                    [view removeFromSuperview];
                }
            }
            
            if (activeArr.count) {
                cell.activeLab.hidden = YES;
                
                for (int i = 0; i < activeArr.count; i ++) {
                    UIView *activeView = [self createActiveViewWithDic:activeArr[i]];
                    activeView.frame = CGRectMake(60, 1 + 40 * i, kIphoneWidth - 80, 40);
                    activeView.tag = 2000 + i;
                    [cell.contentView addSubview:activeView];
                }
                
            } else {
                cell.activeLab.hidden = NO;
                cell.activeLab.text = @"暂无活动";
            }

        } else if (indexPath.row == 1) {
            cell.detailLab.text = [NSString stringWithFormat:@"%@, %ld件", [_selectSpecDic objectForKey:@"specifications"], _buyCount];
        } else if (indexPath.row == 2) {
            NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
            if (userID == nil || _addressModel == nil) {
                cell.detailLab.text = @"暂无收货地址";
            } else {
                cell.detailLab.text = [NSString stringWithFormat:@"%@%@", _addressModel.region, _addressModel.detailedAddress];
            }
        }
        return cell;
    } else {
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell" forIndexPath:indexPath];
        NSArray *commentArr = [_detailDic objectForKey:@"goodsEvaluations"];
        [cell setDataWithDic:commentArr[indexPath.row]];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            
            if (![YWUserDefaults objectForKey:@"UserID"]) {
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                [self.navigationController pushViewController:loginVC animated:YES];
                return ;
            }
            
            NSArray *skuArr = [_detailDic objectForKey:@"goodsSpecificationDetails"];
//            if (skuArr.count <= 1) {
//                [SVProgressHUD showInfoWithStatus:@"没有其他规格可供选择！"];
//                return;
//            }
            SkuSelectView *skuSelectView = [[SkuSelectView alloc] init];
            skuSelectView.type = 1;
            skuSelectView.skusArr = skuArr;
            skuSelectView.selectNum = self.buyCount;
            skuSelectView.skuDic = self.selectSpecDic;
            
            YWWeakSelf;
            skuSelectView.selectedSkuByShop = ^(NSDictionary *skuDic, NSInteger selectNum, NSInteger skuType) {
                
                if (![YWUserDefaults objectForKey:@"UserID"]) {
                    LoginViewController *loginVC = [[LoginViewController alloc] init];
                    [weakSelf.navigationController pushViewController:loginVC animated:YES];
                    return ;
                }
                
                weakSelf.selectSpecDic = skuDic;
                weakSelf.buyCount = selectNum;
                
                if (skuType == 1) {
                    [weakSelf joinToShopCarBySkuDic:skuDic andSelectNum:selectNum];
                } else if (skuType == 2) {
                    [weakSelf buyNowBySkuDic:skuDic andSelectNum:selectNum];
                } else if (skuType == 4) {
                    [weakSelf.tableView reloadData];
                }
                
                [weakSelf.tableView reloadData];
                [weakSelf changeCycsrollerImageWithSpecID:[skuDic objectForKey:@"id"]];
            };
            
        } else if (indexPath.row == 2) {
            if (![YWUserDefaults objectForKey:@"UserID"]) {
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                [self.navigationController pushViewController:loginVC animated:YES];
                return;
            }
            AddressListViewController *addressListVC = [[AddressListViewController alloc] init];
            addressListVC.isSelectAddress = YES;
            addressListVC.selectedAddress = ^(AddressModel *model) {
                self.addressModel = model;
                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            [self.navigationController pushViewController:addressListVC animated:YES];
        }
    } else {
        [_selectView srcollToSelectedBtnAtIndex:2];
        [self.backScrollView setContentOffset:CGPointMake(kIphoneWidth * 2, 0) animated:YES];
    }
}

- (UIView *)createActiveViewWithDic:(NSDictionary *)dic {
    
    NSDictionary *activeDic = [dic objectForKey:@"activityInformation"];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(60, 1, kIphoneWidth - 80, 44)];
    
    UILabel *tagLab = [[UILabel alloc] init];
    tagLab.font = [UIFont systemFontOfSize:13.f];
    tagLab.textAlignment = NSTextAlignmentCenter;
    [tagLab setBorder:kRedTextColor width:1.f radius:4.f];
    tagLab.textColor = kRedTextColor;
    [backView addSubview:tagLab];
    [tagLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backView.mas_centerY);
        make.left.equalTo(backView.mas_left).offset(2);
        make.width.equalTo(@(40));
        make.height.equalTo(@(18));
    }];
    
    UILabel *detailLab = [[UILabel alloc] init];
    detailLab.font = [UIFont systemFontOfSize:13.f];
    detailLab.numberOfLines = 2;
    detailLab.textColor = kGrayTextColor;
    [backView addSubview:detailLab];
    [detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backView.mas_centerY);
        make.left.equalTo(tagLab.mas_right).offset(5);
        make.right.equalTo(backView.mas_right).offset(-15);
        make.height.equalTo(@(40));
    }];
    
    switch ([[activeDic objectForKey:@"activityType"] intValue]) {
        case 0:
            tagLab.text = @"折扣";
            detailLab.text = [NSString stringWithFormat:@"打%.1f折,最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue] * 10, [activeDic objectForKey:@"maxNum"]];
            break;
        case 1:
            tagLab.text = @"团购";
            detailLab.text = [NSString stringWithFormat:@"团购单价为%.2f元，最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue], [activeDic objectForKey:@"maxNum"]];
            break;
        case 2:
            tagLab.text = @"秒杀";
            detailLab.text = [NSString stringWithFormat:@"秒杀单价为%.2f元，最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue], [activeDic objectForKey:@"maxNum"]];
            break;
        case 3:
            tagLab.text = @"立减";
            detailLab.text = [NSString stringWithFormat:@"该商品立减%.2f元，最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue], [activeDic objectForKey:@"maxNum"]];
            break;
        case 4:
            tagLab.text = @"满减";
            detailLab.text = [NSString stringWithFormat:@"该商品满%.2f元，可减%.2f元", [[activeDic objectForKey:@"price"] floatValue], [[activeDic objectForKey:@"discount"] floatValue]];
            break;
        case 5:
            tagLab.text = @"预售";
            detailLab.text = [NSString stringWithFormat:@"预售活动（%@-%@）", [ASHString jsonDateToString:[activeDic objectForKey:@"beginValidityTime"] withFormat:@"yyyy.MM.dd"],[ASHString jsonDateToString:[activeDic objectForKey:@"endValidityTime"] withFormat:@"yyyy.MM.dd"]];
            break;
        default:
            break;
    }
    
    return backView;
}

#pragma mark scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _backScrollView) {
        NSInteger index = scrollView.contentOffset.x / kIphoneWidth;
        [_selectView srcollToSelectedBtnAtIndex:index];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.tableView) {
        CGFloat height = scrollView.contentSize.height - (kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 45);
        if (scrollView.contentOffset.y - 40 > height) {
            [_selectView srcollToSelectedBtnAtIndex:1];
            _backScrollView.contentOffset = CGPointMake(kIphoneWidth, 0);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
