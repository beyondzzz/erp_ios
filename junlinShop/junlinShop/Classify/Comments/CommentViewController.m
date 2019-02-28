//
//  CommentViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/1/24.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentHeaderView.h"
#import "CommentTableViewCell.h"
#import "CommentDetailViewController.h"

@interface CommentViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) CommentHeaderView *headerView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selectDataArr;

@end

@implementation CommentViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_goodsId) {
        [self getGoodsDetailData];
    } else {
       // [self getCommentListData];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTableView];
    [self loadHeaderView];
    _dataArray = [NSMutableArray array];
    _selectDataArr = [NSMutableArray array];
    
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
}


- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight - 0) style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(105, 0, 0, 0);
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
    }
}

- (void)loadHeaderView {
    _headerView = [[[NSBundle mainBundle] loadNibNamed:@"CommentHeaderView" owner:nil options:nil] firstObject];
    _headerView.frame = CGRectMake(0, -105, kIphoneWidth, 105);
    
    [_headerView.totleRatingBar setImageDeselected:@"emptyStar" halfSelected:@"halfStar" fullSelected:@"fullStar" andDelegate:nil];
    _headerView.totleRatingBar.isIndicator = YES;
    [_headerView.totleRatingBar displayRating:5];
    
    CGFloat width = kIphoneWidth / 5;
    NSArray *titleArray = [NSArray arrayWithObjects:@"全部评价", @"好评", @"中评", @"差评", @"有图", nil];
    for (int i = 0; i < 5; i ++) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(width * i, 0, width, CGRectGetHeight(_headerView.selectBackView.frame))];
        backView.tag = 1000 + i;
        
        UILabel *topLab = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width - 5, 16)];
        topLab.userInteractionEnabled = YES;
        topLab.font = [UIFont systemFontOfSize:15];
        topLab.textColor = kGrayTextColor;
        topLab.textAlignment = NSTextAlignmentCenter;
        topLab.text = titleArray[i];
        [backView addSubview:topLab];
        
        UILabel *countLab = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetHeight(backView.frame) - 24, width - 5, 18)];
        countLab.userInteractionEnabled = YES;
        countLab.tag = 1100 + i;
        countLab.font = [UIFont systemFontOfSize:15];
        countLab.textColor = kGrayTextColor;
        countLab.textAlignment = NSTextAlignmentCenter;
        countLab.text = @"0";
        [backView addSubview:countLab];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [[tapGesture rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            NSLog(@"111");
        }];
        [backView addGestureRecognizer:tapGesture];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = 1200 + i;
        button.frame = CGRectMake(0, 0, width, CGRectGetHeight(backView.frame));
        [button addTarget:self action:@selector(clickSelectCommentBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [backView addSubview:button];
        
        [_headerView.selectBackView addSubview:backView];
    }
    
    [_tableView addSubview:_headerView];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_tableView.mas_top).offset(-105);
        make.height.equalTo(@(105));
    }];
}


- (void)getGoodsDetailData {
    if (_goodsId == nil) {
        [self.view stopLoading];
        return;
    }
    [HttpTools Get:kAppendUrl(YWGoodsDetailString) parameters:@{@"goodsId":_goodsId} success:^(id responseObject) {
        [self.view stopLoading];
        NSDictionary *dict =[responseObject objectForKey:@"resultData"];
        //“goodsEvaluations”：该商品的所有评论。
       [self sortCommentListWithArray:[dict objectForKey:@"goodsEvaluations"]];
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getGoodsDetailData];
        }];
    }];
}
- (void)getCommentListData {
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    if (userID == nil) {
        [self showNoDataView];
        [self.view stopLoading];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userID forKey:@"userId"];
    
    
    [HttpTools Get:kAppendUrl(YWCommentListString) parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        [self sortCommentListWithArray:[responseObject objectForKey:@"resultData"]];
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getCommentListData];
        }];
    }];
}


- (void)sortCommentListWithArray:(NSArray *)listArray {
    /*
     “user”：用户信息。
     “evaluationPics”：评价时上传的图片信息。
     “orderDetail”：订单详情信息。
     “orderDetail”下的” orderTable”：订单信息。
     */
    NSMutableArray *goodPicArr = [NSMutableArray array];
    NSMutableArray *goodArr = [NSMutableArray array];
    NSMutableArray *picArr = [NSMutableArray array];
    
    NSMutableArray *otherArr = [NSMutableArray array];
    
    for (NSDictionary *dic in listArray) {
        
        if ([[dic objectForKey:@"score"] floatValue] >= 4.0) {//好评
            if ([[dic objectForKey:@"evaluationPics"] count] > 0) {//有图
                //                [goodPicArr addObject:dic];
             goodPicArr = [self insertComment:goodPicArr dict:dic];
            } else {
                //                [goodArr addObject:dic]; //无图
              goodArr = [self insertComment:goodArr dict:dic];
                
            }
            
            
        } else {//其他评分
            
            if ([[dic objectForKey:@"evaluationPics"] count] > 0) {//有图
                //                [picArr addObject:dic];
               picArr = [self insertComment:picArr dict:dic];
                
            } else { //无图
                //                [otherArr addObject:dic];
               otherArr = [self insertComment:otherArr dict:dic];
                
            }
        }
    }
    
    //    列表默认展示全部评价，全部评价排序权重：好评+有图>好评>有图，同等权重的评价字数多的排在前；
    [self.dataArray addObjectsFromArray:goodPicArr];
    [self.dataArray addObjectsFromArray:goodArr];
    [self.dataArray addObjectsFromArray:picArr];
    [self.dataArray addObjectsFromArray:otherArr];
    
    if (self.dataArray.count) {
        [self.selectDataArr addObjectsFromArray:self.dataArray];
        [self.tableView reloadData];
    } else {
        [self showNoDataView];
    }
    
    [self setHeaderViewData];
}



/**
 字数多的在前

 */
- (NSMutableArray *)insertComment:(NSMutableArray <NSDictionary *>*)array dict:(NSDictionary *)dict{
    if(array.count == 0){
        [array addObject:dict];
        return array;
    }
    __block NSUInteger index = array.count - 1;
    //evaluationContent：评价内容。(String)
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *tmpContent = [obj objectForKey:@"evaluationContent"];
        NSString *content =    [dict objectForKey:@"evaluationContent"];
        
        if(content.length > tmpContent.length){
            index = idx;
        }else{
            
        }
    }];
    
    
    
    if(array.count >= index-1){
        [array insertObject:dict atIndex:index];
    }else{
        [array addObject:dict];
    }
    return array;
}


/**
 评论个数统计
 */
- (void)setHeaderViewData {
    NSInteger goodCount = 0;
    NSInteger centerCount = 0;
    NSInteger badCount = 0;
    NSInteger picCount = 0;
    CGFloat totleScore = 0;
    
    for (NSDictionary *dic in self.dataArray) {
        if ([[dic objectForKey:@"score"] floatValue] >= 4.0) {
            goodCount ++;
        } else if ([[dic objectForKey:@"score"] floatValue] >= 2.0) {
            centerCount ++;
        } else {
            badCount ++;
        }
        
        if ([[dic objectForKey:@"evaluationPics"] count] > 0) {
            picCount ++;
        }
        
        totleScore += [[dic objectForKey:@"score"] floatValue];
    }
    
    CGFloat score = totleScore / self.dataArray.count;
    CGFloat good = (CGFloat)goodCount / self.dataArray.count;
    
    [_headerView.totleRatingBar displayRating:score];
    _headerView.scoreLab.text = [NSString stringWithFormat:@"%.1f", score];
    _headerView.totleCommentLab.text = [NSString stringWithFormat:@"%.1f%%", good * 100];
    
    UILabel *countLab01 = [[self.headerView.selectBackView viewWithTag:1000] viewWithTag:1100];
    countLab01.text = [NSString stringWithFormat:@"%ld", self.dataArray.count];
    
    UILabel *countLab02 = [[self.headerView.selectBackView viewWithTag:1001] viewWithTag:1101];
    countLab02.text = [NSString stringWithFormat:@"%ld", goodCount];
    
    UILabel *countLab03 = [[self.headerView.selectBackView viewWithTag:1002] viewWithTag:1102];
    countLab03.text = [NSString stringWithFormat:@"%ld", centerCount];
    
    UILabel *countLab04 = [[self.headerView.selectBackView viewWithTag:1003] viewWithTag:1103];
    countLab04.text = [NSString stringWithFormat:@"%ld", badCount];
    
    UILabel *countLab05 = [[self.headerView.selectBackView viewWithTag:1004] viewWithTag:1104];
    countLab05.text = [NSString stringWithFormat:@"%ld", picCount];
}

- (void)clickSelectCommentBtn:(UIButton *)button {
    [_selectDataArr removeAllObjects];
    
    for (NSDictionary *commentDic in _dataArray) {
      //  "全部评价", @"好评", @"中评", @"差评", @"有图"
        switch (button.tag) {
            case 1200:
            {
                [_selectDataArr addObject:commentDic];
            }
                break;
            case 1201:
            {
                if ([[commentDic objectForKey:@"score"] floatValue] >= 4.0) {
                    [_selectDataArr addObject:commentDic];
                }
            }
                break;
            case 1202:
            {
                if ([[commentDic objectForKey:@"score"] floatValue] >= 2.0 && [[commentDic objectForKey:@"score"] floatValue] < 4.0) {
                    [_selectDataArr addObject:commentDic];
                }
            }
                break;
            case 1203:
            {
                if ([[commentDic objectForKey:@"score"] floatValue] < 2.0) {
                    [_selectDataArr addObject:commentDic];
                }
            }
                break;
            case 1204:
            {
                if ([[commentDic objectForKey:@"evaluationPics"] count] > 0) {
                    [_selectDataArr addObject:commentDic];
                }
            }
                break;
            default:
                break;
        }
    }
    
    [self.tableView reloadData];
}


- (void)showNoDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight)];
        _noDataView.backgroundColor = kBackGrayColor;
        
//        UIImageView *noDataImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_noData"]];
//        [_noDataView addSubview:noDataImageView];
//        [noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(_noDataView.mas_centerX);
//            make.top.equalTo(_noDataView.mas_top).offset(150);
//            make.width.equalTo(@100);
//            make.height.equalTo(@100);
//        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = kGrayTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"该商品还没有评价";
        [_noDataView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noDataView.mas_centerX);
            make.top.equalTo(_noDataView.mas_top).offset(30);
            make.width.equalTo(@250);
            make.height.equalTo(@20);
        }];
        
    }
    
    if (![self.view.subviews containsObject:_noDataView]) {
        [self.view addSubview:_noDataView];
        [_noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectDataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CommentTableViewCell getCellHeightWithDic:_selectDataArr[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell" forIndexPath:indexPath];
    [cell setDataWithDic:_selectDataArr[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![YWUserDefaults objectForKey:@"UserID"]) {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
    [dict setValue:[_selectDataArr[indexPath.row] objectForKey:@"id"] forKey:@"id"];
    
    [SVProgressHUD show];
    [HttpTools Get:kAppendUrl(YWCommentDetailString) parameters:dict success:^(id responseObject) {
        [SVProgressHUD dismiss];
        CommentDetailViewController *detailVC = [[CommentDetailViewController alloc] init];
        NSDictionary *dict = [responseObject objectForKey:@"resultData"];
        NSArray *array = @[dict];
        detailVC.commentArray = array;
        [self.navigationController pushViewController:detailVC animated:YES];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        ///Error Domain=xxx Code=2 "(null)" UserInfo={msg=评价信息异常, code=15003}
//TODO
        //[SVProgressHUD showErrorWithStatus:@"评价信息异常"];
        NSLog(@"评价信息%@",error);
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
