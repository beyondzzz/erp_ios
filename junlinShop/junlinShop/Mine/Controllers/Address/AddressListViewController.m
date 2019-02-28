//
//  AddressListViewController.m
//  meirongApp
//
//  Created by jianxuan on 2017/12/1.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "AddressListViewController.h"
#import "AddressEditViewController.h"
#import "AddressListViewCell.h"
#import "YWAlertView.h"

@interface AddressListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation AddressListViewController

- (void)requestData {
    [self.dataArray removeAllObjects];
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWAddressListString) parameters:dict success:^(id responseObject) {
        
        NSArray *dataArr = [responseObject objectForKey:@"resultData"];
        self.dataArray = [AddressModel mj_objectArrayWithKeyValuesArray:dataArr];
        
        if (dataArr.count == 0) {
            [self.view showNoDataWithString:@"没有收货地址"];
        } else {
            [self.view stopLoading];
        }
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        YWWeakSelf;
        [self.view showErrorWithRefreshBlock:^{
            [weakSelf requestData];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight - 100];
    if (_isSelectAddress) {
        self.navigationItem.title = @"选择收货地址";
    } else {
        self.navigationItem.title = @"收货地址";
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AddressListViewCell" bundle:nil] forCellReuseIdentifier:@"AddressListViewCell"];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)addAddress:(UIButton *)sender {
    AddressEditViewController *editView = [[AddressEditViewController alloc] init];
    editView.titleStr = @"新增地址";
    [self.navigationController pushViewController:editView animated:YES];
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressListViewCell" forIndexPath:indexPath];
    
    YWWeakSelf;
    [cell setDataWithModel:_dataArray[indexPath.row] completeBlock:^(AddressModel *finishModel, NSInteger btnTag) {
        if (btnTag == 1000) {
            [weakSelf setDefaultAddressWithModel:finishModel];
        }
        if (btnTag == 1001) {
            [weakSelf goToEditAddress:finishModel];
        }
        if (btnTag == 1002) {
            [weakSelf deleteAddressWithModel:finishModel];
        }
    }];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isSelectAddress) {
        YWWeakSelf;
        self.selectedAddress(weakSelf.dataArray[indexPath.row]);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)goToEditAddress:(AddressModel *)model {
    AddressEditViewController *editView = [[AddressEditViewController alloc] init];
    editView.titleStr = @"编辑地址";
    editView.model = model;
    [self.navigationController pushViewController:editView animated:YES];
}

- (void)setDefaultAddressWithModel:(AddressModel *)model {
    [SVProgressHUD show];
    NSString *urlstr = kAppendUrl(YWAddressDefaultString);
    
    [HttpTools Post:urlstr parameters:@{@"id":model.ID, @"userId":model.userId} success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [self requestData];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)deleteAddressWithModel:(AddressModel *)model {
    
    [YWAlertView showNotice:@"确认删除该地址吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
        
        [SVProgressHUD show];
        NSString *urlstr = kAppendUrl(YWAddressDeleteString);
        
        [HttpTools Post:urlstr parameters:@{@"id":model.ID, @"userId":model.userId} success:^(id responseObject) {
            [SVProgressHUD dismiss];
            [self requestData];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
        
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
