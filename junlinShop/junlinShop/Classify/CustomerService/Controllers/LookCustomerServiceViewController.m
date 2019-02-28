//
//  LookCustomerServiceViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "LookCustomerServiceViewController.h"
#import "LookServiceFooterView.h"
#import "CustomerServiceTableCell.h"
#import "CircleImageView.h"

@interface LookCustomerServiceViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LookServiceFooterView *footerView;

@property (nonatomic, strong) NSDictionary *detailDic;

@end

@implementation LookCustomerServiceViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"CustomerServiceTableCell" bundle:nil] forCellReuseIdentifier:@"CustomerServiceTableCell"];
        
        [self.view addSubview:_tableView];
        
        [self loadFooterView];
    }
}

- (void)loadFooterView {
    _footerView = [[[NSBundle mainBundle] loadNibNamed:@"LookServiceFooterView" owner:nil options:nil] lastObject];
    _footerView.frame = CGRectMake(0, 0, kIphoneWidth, 420);
    self.tableView.tableFooterView = _footerView;
}

- (void)requsetServiceData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
    
    NSString *urlStr = nil;
    if (_orderID) {
        [dict setValue:_orderID forKey:@"orderId"];
        urlStr = kAppendUrl(YWCustomerByOrderString);
    } else {
        [dict setValue:_serviceID forKey:@"id"];
        urlStr = kAppendUrl(YWCustomerString);
    }
    
    [HttpTools Get:urlStr parameters:dict success:^(id responseObject) {
        [self.view stopLoading];
        _detailDic = [responseObject objectForKey:@"resultData"];
        [self setFooterViewData];
        
        if ([[_detailDic objectForKey:@"status"] intValue] == 0) {
            _footerView.statusLab.text = @"处理中：售后申请提交成功";
        } else {
            _footerView.statusLab.text = @"已完成：客服后台操作完成";
        }
        
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf requsetServiceData];
        }];
    }];
}

- (void)setFooterViewData {
    NSNumber *stlye = [_detailDic objectForKey:@"serviceType"];
    if ([stlye integerValue] == 0) {
        _footerView.styleLab.text = @"退货";
    } else if ([stlye integerValue] == 1) {
        _footerView.styleLab.text = @"换货";
    } else if ([stlye integerValue] == 2) {
        _footerView.styleLab.text = @"其他";
    }
    
    _footerView.contentLab.text = [_detailDic objectForKey:@"problemDescription"];
    CGFloat height = [ASHString LabHeightWithString:_footerView.contentLab.text font:_footerView.contentLab.font andRectWithSize:CGSizeMake(kIphoneWidth - 30, 300)];
    _footerView.frame = CGRectMake(0, 0, kIphoneWidth, 400 + height);
    
    _footerView.nameLab.text = [_detailDic objectForKey:@"name"];
    _footerView.phoneLab.text = [_detailDic objectForKey:@"phone"];
    
    
    NSArray *picArr = [_detailDic objectForKey:@"afterSalePics"];
    if (picArr.count) {
        _footerView.imageBackView.hidden = NO;
        for (UIView *view in _footerView.imageBackView.subviews) {
            view.hidden = YES;
        }
        
        for (int i = 0; i < picArr.count; i ++) {
            UIImageView *imageView = [_footerView.imageBackView viewWithTag:i + 1000];
            imageView.hidden = NO;
            NSString *imageURL = kAppendUrl([picArr[i] objectForKey:@"picUrl"]);
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:kDefaultImage];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
            [[tapGesture rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
                CircleImageView *circleView = [[CircleImageView alloc] init];
                NSMutableArray *imageurlArr = [NSMutableArray array];
                [imageurlArr addObject:imageURL];
                [circleView setImageArray:imageurlArr andIndex:0];
            }];
            [imageView addGestureRecognizer:tapGesture];
        }
    } else {
        _footerView.imageBackView.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"售后详情";
    [self createTableView];
    
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    [self requsetServiceData];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *orderDic = [_detailDic objectForKey:@"orderTable"];
    return [[orderDic objectForKey:@"orderDetails"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerServiceTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomerServiceTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *orderDic = [_detailDic objectForKey:@"orderTable"];
    NSArray *array = [orderDic objectForKey:@"orderDetails"];
    [cell setDataWithDic:array[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
