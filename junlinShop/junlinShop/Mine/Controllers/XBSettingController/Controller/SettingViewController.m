//
//  SettingViewController.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/29.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "SettingViewController.h"
#import "XBConst.h"
#import "XBSettingCell.h"
#import "XBSettingItemModel.h"
#import "XBSettingSectionModel.h"
#import "CacheManager.h"
#import "NoticeSettingViewController.h"
#import "InfoSettingViewController.h"

@interface SettingViewController ()

@property (nonatomic, strong) NSArray *sectionArray;

@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupSections];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    
    self.tableView.backgroundColor = kBackGrayColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
//    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage) object:nil];
//    [operationQueue addOperation:op];
    
    UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [quitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [quitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quitBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(200, 50) andColor:kBackGreenColor] forState:UIControlStateNormal];
    [self.tableView addSubview:quitBtn];
    YWWeakSelf;
    [[quitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [YWAlertView showNotice:@"确定要退出登录吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            
            [YWUserDefaults removeObjectForKey:@"UserID"];
            [YWUserDefaults removeObjectForKey:@"HeaderImage"];
            [YWUserDefaults removeObjectForKey:@"UserInfo"];
            [YWUserDefaults removeObjectForKey:@"HasNotice"];
            
            [SVProgressHUD showSuccessWithStatus:@"已退出登录"];
            
            [weakSelf.tableView reloadData];
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
    
    quitBtn.frame = CGRectMake(80, kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 50, kIphoneWidth - 160, 40);
    [self.tableView addSubview:quitBtn];
    
}

//- (void)downloadImage {
//    NSDictionary *userInfo = [YWUserDefaults objectForKey:@"UserInfo"];
//    if (userInfo) {
//        NSString *picurl = [userInfo objectForKey:@"userPicUrl"];
//        NSURL *imageURL = [NSURL URLWithString:kAppendUrl(picurl)];
//        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//        UIImage *image = [UIImage imageWithData:imageData];
//        [self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];
//    }
//}
//
//- (void)updateUI:(UIImage *)image {
//    XBSettingSectionModel *item = self.sectionArray[0];
//    XBSettingItemModel *item1 = item.itemArray[0];
//    item1.img = image;
//    [self.tableView reloadData];
//}

- (void)setupSections
{
    YWWeakSelf;
    NSDictionary *userDic = [YWUserDefaults objectForKey:@"UserInfo"];
    XBSettingItemModel *item1 = [[XBSettingItemModel alloc]init];
    item1.funcName = [userDic objectForKey:@"userName"];
    item1.rowHeight = 80.f;
    item1.executeCode = ^{
        InfoSettingViewController *infoVC = [[InfoSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [weakSelf.navigationController pushViewController:infoVC animated:YES];
    };
        
    item1.img = [UIImage imageNamed:@"mine_headerImage"];
    if ([YWUserDefaults objectForKey:@"HeaderImage"]) {
        NSData* imageData = [YWUserDefaults objectForKey:@"HeaderImage"];
        UIImage *image = [UIImage imageWithData:imageData];
        item1.img = image;
    }
    item1.accessoryType = XBSettingAccessoryTypeDisclosureIndicator;
    
    XBSettingSectionModel *section1 = [[XBSettingSectionModel alloc]init];
    section1.sectionHeaderHeight = 3;
    section1.sectionHeaderBgColor = kBackGrayColor;
    section1.itemArray = @[item1];
    
    //************************************section2
    XBSettingItemModel *item2 = [[XBSettingItemModel alloc]init];
    item2.funcName = @"推送消息设置";
    item2.executeCode = ^{
        NoticeSettingViewController *noticeVC = [[NoticeSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [weakSelf.navigationController pushViewController:noticeVC animated:YES];
    };
    item2.accessoryType = XBSettingAccessoryTypeDisclosureIndicator;
    
    
    XBSettingItemModel *item3 = [[XBSettingItemModel alloc]init];
    item3.funcName = @"非WIFI环境下手动下载图片";
    item3.accessoryType = XBSettingAccessoryTypeSwitch;
    item3.switchValueChanged = ^(BOOL isOn)
    {
        NSLog(@"推送提醒开关状态===%@",isOn?@"open":@"close");
        
    };
    
    XBSettingItemModel *item4 = [[XBSettingItemModel alloc]init];
    item4.funcName = @"清除本地缓存";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    CGFloat size = [CacheManager folderSizeAtPath:cachesDir];
    NSString *cacheStr = [NSString stringWithFormat:@"%.2fM", size];
    item4.detailText = cacheStr;
    item4.accessoryType = XBSettingAccessoryTypeDisclosureIndicator;
    
    __weak XBSettingItemModel *item = item4;
    item4.executeCode = ^{
        [YWAlertView showNotice:@"确定要清除缓存吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            item.detailText = @"0.00M";
            [CacheManager clearFile];
            [weakSelf.tableView reloadData];
        }];
    };
    
    XBSettingSectionModel *section2 = [[XBSettingSectionModel alloc]init];
    section2.sectionHeaderHeight = 13;
    section2.sectionHeaderBgColor = kBackGrayColor;
    section2.itemArray = @[item2,item3,item4];
    
    XBSettingItemModel *item5 = [[XBSettingItemModel alloc]init];
    item5.funcName = @"版本检测";
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    item5.detailText = [NSString stringWithFormat:@"v%@.%@", app_Version, app_build];
    item5.accessoryType = XBSettingAccessoryTypeDisclosureIndicator;
    
    XBSettingSectionModel *section3 = [[XBSettingSectionModel alloc]init];
    section3.sectionHeaderHeight = 13;
    section3.sectionHeaderBgColor = kBackGrayColor;
    section3.itemArray = @[item5];
    
    self.sectionArray = @[section1,section2,section3];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
