//
//  SelectAddressViewController.m
//  meirongApp
//
//  Created by jianxuan on 2017/12/1.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "SelectAddressViewController.h"

@interface SelectAddressViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic) NSInteger num;
@property (nonatomic, strong) NSNumber *addressID;
@property (nonatomic, strong) NSMutableArray *addressArr;

@end

@implementation SelectAddressViewController

- (void)requestData {
    [_dataArray removeAllObjects];
    [SVProgressHUD show];
    NSString *str = nil;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (_num == 1) {
        str = @"/provinces";
    } else if (_num == 2) {
        [dic setValue:_addressID forKey:@"parentId"];
        str = @"/cities";
    } else if (_num == 3) {
        [dic setValue:_addressID forKey:@"parentId"];
        str = @"/districts";
    }
    NSString *urlStr = [kAppendUrl(@"") stringByAppendingString:str];
    
    [HttpTools Get:urlStr parameters:dic success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSArray *dataArr = [responseObject objectForKey:@"data"];
        [_dataArray addObjectsFromArray:dataArr];
        
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _num = 1;
    _dataArray = [NSMutableArray array];
    _addressArr = [NSMutableArray array];
    
    self.navigationItem.title = @"选择省份";
    [self requestData];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = [_dataArray[indexPath.row] objectForKey:@"regionName"];
    cell.textLabel.textColor = kBlackTextColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _dataArray[indexPath.row];
    _addressID = [dic objectForKey:@"id"];
    NSString *str = [dic objectForKey:@"regionName"];
    [_addressArr addObject:str];
    
    _num ++;
    if (_num == 2) {
        self.navigationItem.title = @"选择城市";
    }
    if (_num == 3) {
        self.navigationItem.title = @"选择区县";
    }
    if (_num == 4) {
        YWWeakSelf;
        NSString *addressStr = [_addressArr componentsJoinedByString:@","];
        self.completeSelectedAddress(weakSelf.addressID, addressStr);
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self requestData];
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
