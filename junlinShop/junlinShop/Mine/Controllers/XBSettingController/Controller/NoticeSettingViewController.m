//
//  NoticeSettingViewController.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/29.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "NoticeSettingViewController.h"
#import "XBConst.h"
#import "XBSettingCell.h"
#import "XBSettingItemModel.h"
#import "XBSettingSectionModel.h"

@interface NoticeSettingViewController ()

@property (nonatomic, strong) NSArray *sectionArray;

@end

@implementation NoticeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"消息设置";
    
    self.tableView.backgroundColor = kBackGrayColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setupSections];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [quitBtn setTitle:@"清空全部消息" forState:UIControlStateNormal];
    [quitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quitBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(200, 50) andColor:kBackGreenColor] forState:UIControlStateNormal];
    [self.tableView addSubview:quitBtn];
    
    [[quitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [YWAlertView showNotice:@"确定要清除所有消息吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
            [HttpTools Post:kAppendUrl(YWDeldectMessageString) parameters:dict success:^(id responseObject) {
                
                [YWUserDefaults setValue:@"0" forKey:@"HasNotice"];
                [SVProgressHUD showSuccessWithStatus:@"清除完成"];
                
            } failure:^(NSError *error) {
                
            }];
            
        }];
    }];
    
    quitBtn.frame = CGRectMake(80, kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 50, kIphoneWidth - 160, 40);
    [self.tableView addSubview:quitBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (void)setupSections
{
    XBSettingItemModel *item1 = [[XBSettingItemModel alloc]init];
    item1.funcName = @"新消息通知";
    item1.detailText = @"去开启";
    item1.executeCode = ^{
        NSString *urlStr = @"App-Prefs:root=NOTIFICATIONS_ID&path=com.yw.JunLinShop.junlinShop";
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
        }
    };
    item1.accessoryType = XBSettingAccessoryTypeDisclosureIndicator;
    
    XBSettingSectionModel *section1 = [[XBSettingSectionModel alloc]init];
    section1.sectionHeaderHeight = 3;
    section1.sectionHeaderBgColor = kBackGrayColor;
    section1.itemArray = @[item1];
    
    //************************************section2
    XBSettingItemModel *item2 = [[XBSettingItemModel alloc]init];
    item2.funcName = @"活动通知";
    item2.accessoryType = XBSettingAccessoryTypeSwitch;
    item2.switchValueChanged = ^(BOOL isOn)
    {
        NSLog(@"推送提醒开关状态===%@",isOn?@"open":@"close");
        
    };
    
    
    XBSettingItemModel *item3 = [[XBSettingItemModel alloc]init];
    item3.funcName = @"订单通知";
    item3.accessoryType = XBSettingAccessoryTypeSwitch;
    item3.switchValueChanged = ^(BOOL isOn)
    {
        NSLog(@"推送提醒开关状态===%@",isOn?@"open":@"close");
        
    };
    
    
    
    XBSettingSectionModel *section2 = [[XBSettingSectionModel alloc]init];
    section2.sectionHeaderHeight = 24;
    section2.sectionHeaderName = @"通知栏推送开关";
    section2.sectionHeaderBgColor = kBackGrayColor;
    section2.itemArray = @[item2, item3];
    
    self.sectionArray = @[section1,section2];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    XBSettingSectionModel *sectionModel = self.sectionArray[section];
    return sectionModel.itemArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XBSettingSectionModel *sectionModel = self.sectionArray[indexPath.section];
    XBSettingItemModel *itemModel = sectionModel.itemArray[indexPath.row];
    return itemModel.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"setting";
    XBSettingSectionModel *sectionModel = self.sectionArray[indexPath.section];
    XBSettingItemModel *itemModel = sectionModel.itemArray[indexPath.row];
    
    XBSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[XBSettingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.item = itemModel;
    return cell;
}

#pragma - mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    XBSettingSectionModel *sectionModel = self.sectionArray[section];
    return sectionModel.sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    XBSettingSectionModel *sectionModel = self.sectionArray[section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, sectionModel.sectionHeaderHeight)];
    view.backgroundColor = sectionModel.sectionHeaderBgColor;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, sectionModel.sectionHeaderHeight)];
    titleLab.text = sectionModel.sectionHeaderName;
    titleLab.textColor = kGrayTextColor;
    titleLab.font = [UIFont systemFontOfSize:13];
    titleLab.centerY = view.centerY;
    [view addSubview:titleLab];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XBSettingSectionModel *sectionModel = self.sectionArray[indexPath.section];
    XBSettingItemModel *itemModel = sectionModel.itemArray[indexPath.row];
    if (itemModel.executeCode) {
        itemModel.executeCode();
    }
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
