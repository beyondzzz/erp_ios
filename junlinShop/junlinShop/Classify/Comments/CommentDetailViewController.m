//
//  CommentDetailViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "CommentDetailTableCell.h"

@interface CommentDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CommentDetailViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"CommentDetailTableCell" bundle:nil] forCellReuseIdentifier:@"CommentDetailTableCell"];
        
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)requestCommentData {
    NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
    NSMutableDictionary *idDic = [NSMutableDictionary dictionary];
    [idDic setValue:userID forKey:@"userId"];
    [idDic setValue:_orderNum forKey:@"orderId"];
    
    [HttpTools Get:kAppendUrl(YWOrderCommentString) parameters:idDic success:^(id responseObject) {
        NSDictionary *orderDic = [responseObject objectForKey:@"resultData"];
        self.commentArray = [orderDic objectForKey:@"orderDetails"];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"评价详情";
    [self createTableView];
    if (_orderNum) {
        [self requestCommentData];
    }
    // Do any additional setup after loading the view from its nib.
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _commentArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CommentDetailTableCell getCellHeightWithDic:_commentArray[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentDetailTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_orderNum) {
        cell.isComeFromOrder = YES;
    }
    
    [cell setDataWithDic:_commentArray[indexPath.row]];
    
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
