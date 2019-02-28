//
//  SelectInvoiceViewController.m
//  junlinShop
//
//  Created by jianxuan on 2017/12/11.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "SelectInvoiceViewController.h"
#import "SelectInvoiceHeaderView.h"
#import "SelectInvoiceFooterView.h"
#import "SelectInvoiceTableCell.h"
#import "InvoiceInfoViewController.h"
#import "AddInvoicceInfoController.h"
#import "AddNormalInvoiceView.h"
#import "YWAlertView.h"

@interface SelectInvoiceViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SelectInvoiceHeaderView *headerView;
@property (nonatomic, strong) SelectInvoiceFooterView *footerView;
@property (nonatomic, strong) AddNormalInvoiceView *addInvoiceView;

@property (weak, nonatomic) IBOutlet UIButton *normalInvoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *specialInvoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *noInoviceBtn;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDictionary *aptitudeDic;
@property (nonatomic, strong) NSDictionary *aptitudeTempDic;
@property (nonatomic) BOOL isNarmolInvoice;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, strong) UIButton *addBtn;
//@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation SelectInvoiceViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 170, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight - 40 - SafeAreaBottomHeight - 170) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.backgroundColor = kBackGrayColor;
        adjustsScrollViewInsets(_tableView);
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"SelectInvoiceTableCell" bundle:nil] forCellReuseIdentifier:@"SelectInvoiceTableCell"];
        
        _headerView = [[[NSBundle mainBundle] loadNibNamed:@"SelectInvoiceHeaderView" owner:nil options:nil] lastObject];
        _headerView.frame = CGRectMake(0, 0, kIphoneWidth, 85);
        
        [_tableView setTableHeaderView:_headerView];
        
        _footerView = [[[NSBundle mainBundle] loadNibNamed:@"SelectInvoiceFooterView" owner:nil options:nil] lastObject];
        _footerView.frame = CGRectMake(0, 0, kIphoneWidth, 130);
        
        [_tableView setTableFooterView:_footerView];
        
//        [self.view addSubview:_tableView];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发票";
    _dataArray = [NSMutableArray array];
    
    [self.normalInvoiceBtn setBorder:kBackGrayColor width:1 radius:5.f];
    [self.specialInvoiceBtn setBorder:kBackGrayColor width:1 radius:5.f];
    [self.noInoviceBtn setBorder:kBackGreenColor width:1 radius:5.f];
    _isNarmolInvoice = YES;
    
    _addInvoiceView = [[[NSBundle mainBundle] loadNibNamed:@"AddNormalInvoiceView" owner:nil options:nil] lastObject];
    _addInvoiceView.frame = [UIScreen mainScreen].bounds;
    
    [self createTableView];
    [self createSureBtn];
    [self addBacKClickTarget];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发票须知" style:UIBarButtonItemStyleDone target:self action:@selector(showInvoiceTips)];
    self.navigationItem.rightBarButtonItem.tintColor = kGrayTextColor;
 }

- (void)showInvoiceTips {
    [YWAlertView showNotice:@"发票须知" WithType:YWAlertTypeShowInvoiceTips clickSureBtn:^(UIButton *btn) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    [self requestInvoiceData];
}

- (void)createSureBtn {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kIphoneHeight - 40 - SafeAreaTopHeight - SafeAreaBottomHeight, kIphoneWidth, 40)];
    view.backgroundColor = kBackGrayColor;
    [self.view addSubview:view];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(150, 32) andColor:kBackGreenColor] forState:UIControlStateNormal];
    [button setTitle:@"确认" forState:UIControlStateNormal];
    button.frame = CGRectMake((kIphoneWidth - 150) / 2, 4, 150, 32);
    [view addSubview:button];
    
    YWWeakSelf;
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        BOOL isGoods = YES;
        if (weakSelf.footerView.mingxiBtn.selected) {
            isGoods = NO;
        }
        BOOL isGeren = YES;
        if (weakSelf.headerView.danweiBtn.selected) {
            isGeren = NO;
        }
        
        if (weakSelf.noInoviceBtn.selected) {
            weakSelf.selectInvoice(NO, NO, NO, nil);
        } else if (weakSelf.normalInvoiceBtn.selected) {
            if (weakSelf.dataArray.count == 0 && weakSelf.headerView.danweiBtn.selected) {
                [SVProgressHUD showErrorWithStatus:@"没有普票单位可以选择， 请添加单位信息"];
                return ;
            }
            if (weakSelf.headerView.genrenBtn.selected) {
                weakSelf.selectInvoice(YES, isGeren, isGoods, nil);
            } else {
                NSDictionary *dict = weakSelf.dataArray[weakSelf.selectIndexPath.row];
                weakSelf.selectInvoice(YES, isGeren, isGoods, dict);
            }
        } else {
            if (weakSelf.aptitudeDic == nil) {
                [SVProgressHUD showErrorWithStatus:@"没有增票信息可以选择， 请添加单位信息"];
                return ;
            }
            weakSelf.selectInvoice(NO, isGeren, isGoods,weakSelf.aptitudeDic);
        }
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)addBacKClickTarget {
    YWWeakSelf;
    [[_normalInvoiceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        [weakSelf.normalInvoiceBtn setBorder:kBackGreenColor width:1 radius:5.f];
        
        weakSelf.specialInvoiceBtn.selected = !x.selected;
        [weakSelf.specialInvoiceBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.noInoviceBtn.selected = !x.selected;
        [weakSelf.noInoviceBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.isNarmolInvoice = YES;
        if (![weakSelf.view.subviews containsObject:weakSelf.tableView]) {
            [weakSelf.view addSubview:weakSelf.tableView];
        }
        
        [weakSelf.tableView reloadData];
    }];
    
    [[_specialInvoiceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        [weakSelf.specialInvoiceBtn setBorder:kBackGreenColor width:1 radius:5.f];
        
        weakSelf.normalInvoiceBtn.selected = !x.selected;
        [weakSelf.normalInvoiceBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.noInoviceBtn.selected = !x.selected;
        [weakSelf.noInoviceBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.isNarmolInvoice = NO;
        if (![weakSelf.view.subviews containsObject:weakSelf.tableView]) {
            [weakSelf.view addSubview:weakSelf.tableView];
        }
        
        weakSelf.headerView.genrenBtn.selected = NO;
        weakSelf.headerView.danweiBtn.selected = YES;
        
        [weakSelf.tableView reloadData];
        
        if ([[_aptitudeTempDic objectForKey:@"state"] integerValue] == 0) {
            [SVProgressHUD showInfoWithStatus:@"增票资质审核中"];
        } else if ([[_aptitudeTempDic objectForKey:@"state"] integerValue] == 1) {
            [SVProgressHUD showInfoWithStatus:@"增票资质审核未通过"];
        }
        if (_aptitudeTempDic == nil) {
            [SVProgressHUD showInfoWithStatus:@"未提交增票资质"];
        }
    }];
    
    [[_noInoviceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        [weakSelf.noInoviceBtn setBorder:kBackGreenColor width:1 radius:5.f];
        
        weakSelf.normalInvoiceBtn.selected = !x.selected;
        [weakSelf.normalInvoiceBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.specialInvoiceBtn.selected = !x.selected;
        [weakSelf.specialInvoiceBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        if ([weakSelf.view.subviews containsObject:weakSelf.tableView]) {
            [weakSelf.tableView removeFromSuperview];
        }
    }];
    
    [[_headerView.genrenBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        weakSelf.headerView.danweiBtn.selected = !x.selected;
        
        [weakSelf.tableView reloadData];
    }];
    
    [[_headerView.danweiBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        weakSelf.headerView.genrenBtn.selected = !x.selected;
        
        [weakSelf.tableView reloadData];
    }];
    
    [[_footerView.mingxiBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        weakSelf.footerView.shipinBtn.selected = !x.selected;
    }];
    
    [[_footerView.shipinBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        weakSelf.footerView.mingxiBtn.selected = !x.selected;
    }];
}

- (void)requestInvoiceData {
    [self.dataArray removeAllObjects];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dic setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWGetAllInvoiceUnitString) parameters:dic success:^(id responseObject) {
        [self.view stopLoading];
        
        NSDictionary *dataDic = [responseObject objectForKey:@"resultData"];
        for (NSDictionary *dict in [dataDic objectForKey:@"invoiceUnit"]) {
            [self.dataArray addObject:dict];
        }
        if ([[dataDic objectForKey:@"vatInvoiceAptitude"] isKindOfClass:[NSDictionary class]]) {
            if ([[[dataDic objectForKey:@"vatInvoiceAptitude"] objectForKey:@"state"] integerValue] == 2) {
                _aptitudeDic = [dataDic objectForKey:@"vatInvoiceAptitude"];
            }
            _aptitudeTempDic = [dataDic objectForKey:@"vatInvoiceAptitude"];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf requestInvoiceData];
        }];
    }];
    /*
     Error Domain=NSCocoaErrorDomain Code=3840 "JSON text did not start with array or object and option to allow fragments not set." UserInfo={NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set., NSUnderlyingError=0x60400065e600 {Error Domain=com.alamofire.error.serialization.response Code=-1011 "Request failed: internal server error (500)" UserInfo={NSLocalizedDescription=Request failed: internal server error (500), NSErrorFailingURLKey=http://117.158.178.202:8001/JLMIS/invoice/getInvoiceUnitAndVatInvoiceAptitudeByUserId?userId=45,
     */
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_headerView.genrenBtn.selected) {
        return 0;
    }
    
    if (_isNarmolInvoice) {
        return _dataArray.count;
    }
    if (_aptitudeDic) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_aptitudeDic) {
        return 175;
    }
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_headerView.genrenBtn.selected) {
        return 0;
    }
    
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (_headerView.genrenBtn.selected) {
        return [UIView new];
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 40)];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(26, 4, 90, 27);
    addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [addBtn setBorder:kBackGreenColor width:1.f radius:4.f];
    [addBtn setTitleColor:kBackGreenColor forState:UIControlStateNormal];
    
    if (_isNarmolInvoice) {
        [addBtn setTitle:@"新增单位" forState:UIControlStateNormal];
        addBtn.frame = CGRectMake(26, 4, 80, 27);
        addBtn.hidden = NO;
        _headerView.genrenBtn.hidden = NO;

    } else {
        addBtn.hidden = YES;
        _headerView.genrenBtn.hidden = YES;
//        if (_aptitudeDic) {
//            [addBtn setTitle:@"修改增票信息" forState:UIControlStateNormal];
//        } else {
//            [addBtn setTitle:@"新增增票信息" forState:UIControlStateNormal];
//        }
//        addBtn.frame = CGRectMake(26, 4, 100, 27);
    }
    [backView addSubview:addBtn];
    self.addBtn = addBtn;
    
    YWWeakSelf;
    [[addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        UIButton *button = (UIButton *)x;
        if ([button.currentTitle isEqualToString:@"新增单位"]) {
            [weakSelf.addInvoiceView initData];
            weakSelf.addInvoiceView.completeBlock = ^{
                [weakSelf requestInvoiceData];
            };
        }
//        else if ([button.currentTitle isEqualToString:@"修改增票信息"]) {
//            InvoiceInfoViewController *infoVC = [[InvoiceInfoViewController alloc] init];
//            [weakSelf.navigationController pushViewController:infoVC animated:YES];
//        } else {
//            AddInvoicceInfoController *addVC = [[AddInvoicceInfoController alloc] init];
//            [weakSelf.navigationController pushViewController:addVC animated:YES];
//        }
    }];
    
    return backView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectInvoiceTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectInvoiceTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_isNarmolInvoice) {
        
        cell.registAddressLa.hidden = YES;
        cell.registMobileLab.hidden = YES;
        cell.bankLab.hidden = YES;
        cell.bankNumLab.hidden = YES;
        
        [cell setDataWithDic:_dataArray[indexPath.row]];
        
        if (_selectIndexPath == nil && indexPath.row == 0) {
            _selectIndexPath = indexPath;
        }
        
        if (indexPath.row == _selectIndexPath.row) {
            cell.selectBtn.selected = YES;
        } else {
            cell.selectBtn.selected = NO;
        }
        
    } else {
        cell.selectBtn.selected = YES;
        [cell setDataWithDic:_aptitudeDic];
        
        cell.registAddressLa.hidden = NO;
        cell.registMobileLab.hidden = NO;
        cell.bankLab.hidden = NO;
        cell.bankNumLab.hidden = NO;
        
        cell.registAddressLa.text = [_aptitudeDic objectForKey:@"registeredAddress"];
        cell.registMobileLab.text = [_aptitudeDic objectForKey:@"registeredTel"];
        cell.bankLab.text = [_aptitudeDic objectForKey:@"depositBank"];
        cell.bankNumLab.text = [_aptitudeDic objectForKey:@"bankAccount"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isNarmolInvoice) {
        _selectIndexPath = indexPath;
        [_tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
