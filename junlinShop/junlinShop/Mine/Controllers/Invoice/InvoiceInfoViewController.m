//
//  InvoiceInfoViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2017/12/5.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "InvoiceInfoViewController.h"
#import "SegmentSelectView.h"
#import "AddInvoicceInfoController.h"
#import "InvoiceNormalTableCell.h"
#import "AddNormalInvoiceController.h"
#import "YWAlertView.h"
#import "CircleImageView.h"

@interface InvoiceInfoViewController () <SegmentSelectViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UIButton *addZengpiaoBtn;
@property (weak, nonatomic) IBOutlet UILabel *stateLab;

@property (weak, nonatomic) IBOutlet UIView *zengPiaoBackView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *zengpiaoNumField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *bankNameField;
@property (weak, nonatomic) IBOutlet UITextField *bankNumField;
@property (weak, nonatomic) IBOutlet UIImageView *zengpiaoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomNoticeTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet UITableView *unitTableView;

@property (nonatomic, strong) NSMutableDictionary *aptitudeDic;
@property (nonatomic, strong) NSMutableArray *unitArray;

@property (nonatomic, assign) NSUInteger  selectedIndex;


@end

@implementation InvoiceInfoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getInvoiceAptitudeData];
    [self getInvoiceUnitData];
 
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"发票信息";
    self.selectedIndex = 0;
    
    _unitArray = [NSMutableArray array];
    _bottomNoticeTopConstraint.constant = 15;
    _zengpiaoImageView.hidden = YES;
    
    SegmentSelectView *selectView = [[SegmentSelectView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 50) andTitleArray:@[@"增票资质", @"普票单位"] andImageNameArray:nil byType:SegmentViewTypeBottonLine];
    selectView.delegate = self;
    [self.view addSubview:selectView];
    _noDataView.hidden = YES;
    _unitTableView.hidden = YES;
    
    [_unitTableView registerNib:[UINib nibWithNibName:@"InvoiceNormalTableCell" bundle:nil] forCellReuseIdentifier:@"InvoiceNormalTableCell"];
    
    [self setZengPiaoBackViewAction];
    
    YWWeakSelf;
    [_addZengpiaoBtn setBorder:kBackGreenColor width:1.f radius:5.f];
    
    [[_addZengpiaoBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        AddInvoicceInfoController *addVC = [[AddInvoicceInfoController alloc] init];
        [weakSelf.navigationController pushViewController:addVC animated:YES];
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        CircleImageView *circleView = [[CircleImageView alloc] init];
        [circleView setImageArray:@[weakSelf.zengpiaoImageView.image] andIndex:0];
    }];
    [_zengpiaoImageView addGestureRecognizer:tap];
}
- (void)setNoDataViewAction {
    _zengPiaoBackView.hidden = YES;
    _noDataView.hidden = NO;
}

- (void)setZengPiaoBackViewAction {
    
    YWWeakSelf;
    [_editBtn setBorder:kGrayLineColor width:1.f radius:4.f];
    [[_editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        AddInvoicceInfoController *addVC = [[AddInvoicceInfoController alloc] init];
        addVC.aptitudeDic = [weakSelf.aptitudeDic mutableCopy];
        addVC.isEdit = YES;
        [weakSelf.navigationController pushViewController:addVC animated:YES];
    }];
    
    [_deleteBtn setBorder:kGrayLineColor width:1.f radius:4.f];
    [[_deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        [YWAlertView showNotice:@"确认删除吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:userID forKey:@"userId"];
            [dict setValue:[weakSelf.aptitudeDic objectForKey:@"id"] forKey:@"id"];
            
            [HttpTools Post:kAppendUrl(YWDeleteInvoiceAptitudeString) parameters:dict success:^(id responseObject) {
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                weakSelf.aptitudeDic = nil;
                weakSelf.zengPiaoBackView.hidden = YES;
                weakSelf.noDataView.hidden = NO;
            } failure:^(NSError *error) {
                
            }];
        }];
        
    }];
}


//增票数据
- (void)setAptitudeData {
    if(!_aptitudeDic) return;
    
//    if (_selectedIndex == 0) {
//        _unitTableView.hidden = YES;
//        if (_aptitudeDic) {
//            _zengPiaoBackView.hidden = NO;
//            _noDataView.hidden = YES;
//        } else {
//            _zengPiaoBackView.hidden = YES;
//            _noDataView.hidden = NO;
//        }
//    }else{
//        _unitTableView.hidden = NO;
//        _zengPiaoBackView.hidden = YES;
//        _noDataView.hidden = YES;
//        return;
//    }
    [self clickButton:nil AtIndex:_selectedIndex];
    
    
    _nameField.text = [_aptitudeDic objectForKey:@"unitName"];
    _zengpiaoNumField.text = [_aptitudeDic objectForKey:@"taxpayerIdentificationNumber"];
    _addressField.text = [_aptitudeDic objectForKey:@"registeredAddress"];
    _phoneField.text = [_aptitudeDic objectForKey:@"registeredTel"];
    _bankNameField.text = [_aptitudeDic objectForKey:@"depositBank"];
    _bankNumField.text = [_aptitudeDic objectForKey:@"bankAccount"];
    
    _bottomNoticeTopConstraint.constant = 80;
    _zengpiaoImageView.hidden = NO;
    [_zengpiaoImageView sd_setImageWithURL:[NSURL URLWithString:kAppendUrl([_aptitudeDic objectForKey:@"businessLicenseUrl"])] placeholderImage:kDefaultImage];
    
    if ([[_aptitudeDic objectForKey:@"state"] integerValue] == 0) {
        _stateLab.text = @"正在等待审核";
    } else if ([[_aptitudeDic objectForKey:@"state"] integerValue] == 1) {
        _stateLab.text = @"您填写的增票资质未通过审核，请重新填写";
        _stateLab.textColor = [UIColor redColor];
        UIImageView *tipsImageV = [_stateLab.superview.subviews firstObject];
        tipsImageV.image = [UIImage imageNamed:@"pay_false"];
        
    } else if ([[_aptitudeDic objectForKey:@"state"] integerValue] == 2) {
        _stateLab.text = @"您填写的增票资质已通过审核";
    }
}

#pragma mark SegmentSelectViewDelegate
- (void)clickButton:(UIButton *)button AtIndex:(NSInteger)index {
    self.selectedIndex = index;
    if (index == 0) {
        
        _unitTableView.hidden = YES;
        if (_aptitudeDic) {
            
            _zengPiaoBackView.hidden = NO;
            _noDataView.hidden = YES;
        } else {
            _zengPiaoBackView.hidden = YES;
            _noDataView.hidden = NO;
        }
    } else {
        _unitTableView.hidden = NO;
        _zengPiaoBackView.hidden = YES;
        _noDataView.hidden = YES;
    }
}



#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _unitArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 60)];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(60, 24, kIphoneWidth - 120, 27);
    addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [addBtn setBorder:kBackGreenColor width:1.f radius:4.f];
    [addBtn setTitleColor:kBackGreenColor forState:UIControlStateNormal];
    [addBtn setTitle:@"添加普票单位" forState:UIControlStateNormal];
    
    [backView addSubview:addBtn];
    
    YWWeakSelf;
    [[addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        UIButton *button = (UIButton *)x;
        if ([button.currentTitle isEqualToString:@"添加普票单位"]) {
            AddNormalInvoiceController *normalVC = [[AddNormalInvoiceController alloc] init];
            normalVC.isEditing = NO;
            [weakSelf.navigationController pushViewController:normalVC animated:YES];
        }
    }];
    
    return backView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InvoiceNormalTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvoiceNormalTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    [cell setDataWithDic:_unitArray[indexPath.row]];
    
    YWWeakSelf;
    cell.refreshTable = ^{
        [weakSelf getInvoiceUnitData];
    };
    
    [[[cell.editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        AddNormalInvoiceController *normalVC = [[AddNormalInvoiceController alloc] init];
        normalVC.isEditing = YES;
        normalVC.normalDic = weakSelf.unitArray[indexPath.row];
        [weakSelf.navigationController pushViewController:normalVC animated:YES];
        
    }];
    
    return cell;
}

#pragma mark - 网络
//获取普票信息
- (void)getInvoiceUnitData {
    [_unitArray removeAllObjects];
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWGetInvoiceUnitString) parameters:dict success:^(id responseObject) {
        NSMutableArray *tmp = [NSMutableArray arrayWithArray: [responseObject objectForKey:@"resultData"]];
        if (!tmp.count) {
            [tmp addObject:@{@"nodata":@1}];
        }
    
        [_unitArray addObjectsFromArray:tmp];
        
        
        [_unitTableView reloadData];
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getInvoiceUnitData];
        }];
    }];
}

//获取增票信息
- (void)getInvoiceAptitudeData {
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWGetInvoiceAptitudeString) parameters:dict success:^(id responseObject) {
        
        if ([[responseObject objectForKey:@"resultData"] isKindOfClass:[NSDictionary class]]) {
            
            _aptitudeDic = [[responseObject objectForKey:@"resultData"] mutableCopy];
            
            //            if ([[_aptitudeDic objectForKey:@"state"] integerValue] != 1) {
            [self setAptitudeData];
            //            }
            
        } else {
            [self setNoDataViewAction];
        }
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf getInvoiceAptitudeData];
        }];
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 

@end
