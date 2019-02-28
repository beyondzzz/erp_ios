//
//  SetCommentViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/1/25.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "SetCommentViewController.h"
#import "SetCommentTableCell.h"
#import "SetCommentModel.h"

@interface SetCommentViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *commentArray;

@end

@implementation SetCommentViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"SetCommentTableCell" bundle:nil] forCellReuseIdentifier:@"SetCommentTableCell"];
        
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"评价晒单";
    _dataArray = [NSMutableArray array];
    
    for (NSDictionary *dic in [_orderDic objectForKey:@"orderDetails"]) {
        SetCommentModel *model = [[SetCommentModel alloc] init];
        model.orderDetailId = [dic objectForKey:@"id"];
        model.goodsImgUrl = [dic objectForKey:@"goodsCoverUrl"];
        
        [self.dataArray addObject:model];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(uploadComment)];
    self.navigationItem.rightBarButtonItem.tintColor = kBackGreenColor;
    
    [self createTableView];
    // Do any additional setup after loading the view from its nib.
}

- (void)uploadComment {
    for (int i = 0; i < _dataArray.count; i ++) {
        SetCommentModel *model = _dataArray[i];
//        if (!model.evaluationContent) {
//            [SVProgressHUD showErrorWithStatus:@"未输入评价内容无法提交"];
//            return;
//        }
//        if (!model.score) {
//            [SVProgressHUD showErrorWithStatus:@"未输入评分无法提交"];
//            return;
//        }
        
        NSMutableDictionary *commentDic = [NSMutableDictionary dictionary];
        
        NSMutableArray *imageUrlArr = [NSMutableArray array];
        for (NSString *string in model.imageUrlArr) {
            if (string.length > 1) {
                [imageUrlArr addObject:string];
            } else {
                if (string.intValue == 1) {
                    [SVProgressHUD showErrorWithStatus:@"图片正在上传中，请稍后再试"];
                    return;
                }
            }
        }
        if (imageUrlArr.count) {
            [commentDic setValue:[imageUrlArr componentsJoinedByString:@","] forKey:@"files"];
        } else {
            [commentDic setValue:@"" forKey:@"files"];
        }
        
        [commentDic setValue:model.orderDetailId forKey:@"orderDetailId"];
        [commentDic setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
        [commentDic setValue:model.evaluationContent forKey:@"evaluationContent"];
        [commentDic setValue:model.score forKey:@"score"];
        
        if (model.score && model.evaluationContent) {
            [HttpTools Post:kAppendUrl(YWCommentSaveString) parameters:commentDic success:^(id responseObject) {
                [SVProgressHUD showSuccessWithStatus:@"评价成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                [SVProgressHUD showSuccessWithStatus:@"评价失败"];
            }];
        }
        
    }
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 290;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SetCommentTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SetCommentTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    [cell setDataWithModel:_dataArray[indexPath.row]];
    
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
