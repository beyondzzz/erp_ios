//
//  InfoSettingViewController.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/29.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "InfoSettingViewController.h"
#import "XBConst.h"
#import "XBSettingCell.h"
#import "XBSettingItemModel.h"
#import "XBSettingSectionModel.h"
#import "UserNameSetViewController.h"
#import "UIImage+Compress.h"

@interface InfoSettingViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSArray *sectionArray;

@end

@implementation InfoSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"个人信息设置";
    
    self.tableView.backgroundColor = kBackGrayColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setupSections];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (void)setupSections
{
    YWWeakSelf;
    XBSettingItemModel *item1 = [[XBSettingItemModel alloc]init];
    item1.funcName = @"头像";
    item1.rowHeight = 80;
    item1.detailImage = [UIImage imageNamed:@"mine_headerImage"];
    if ([YWUserDefaults objectForKey:@"HeaderImage"]) {
        NSData* imageData = [YWUserDefaults objectForKey:@"HeaderImage"];
        UIImage *image = [UIImage imageWithData:imageData];
        item1.detailImage = image;
    }
    item1.executeCode = ^{
        [weakSelf addPictureImage];
    };
    item1.accessoryType = XBSettingAccessoryTypeDisclosureIndicator;
    
    NSDictionary *userDic = [YWUserDefaults objectForKey:@"UserInfo"];
    XBSettingItemModel *item2 = [[XBSettingItemModel alloc]init];
    item2.funcName = @"账号";
    item2.accessoryType = XBSettingAccessoryTypeNone;
    NSMutableString *string = [[userDic objectForKey:@"userPhone"] mutableCopy];
    if (string.length == 11) {
        [string replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    item2.detailText = string;
    
    
    XBSettingItemModel *item3 = [[XBSettingItemModel alloc]init];
    item3.funcName = @"用户名";
    item3.detailText = [userDic objectForKey:@"userName"];

    
    __weak XBSettingItemModel *item = item3;
    item3.executeCode = ^{
        UserNameSetViewController *userNameSetVC = [[UserNameSetViewController alloc] init];
        userNameSetVC.userNameField.text = item.detailText;
        userNameSetVC.completeChangeUserName = ^(NSString *userName) {
            item.detailText = userName;
            [weakSelf.tableView reloadData];
        };
        [weakSelf.navigationController pushViewController:userNameSetVC animated:YES];
    };
    item3.accessoryType = XBSettingAccessoryTypeDisclosureIndicator;
    
    XBSettingSectionModel *section1 = [[XBSettingSectionModel alloc]init];
    section1.sectionHeaderHeight = 3;
    section1.sectionHeaderBgColor = kBackGrayColor;
    section1.itemArray = @[item1, item2, item3];
    
    
    self.sectionArray = @[section1];
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

//添加图片
- (void)addPictureImage {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择修改头像的图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            //上面這一行主要是在判斷裝置是否支援此項功能
            NSLog(@"//从相机获取");
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;//允许用户进行编辑
            //picker.cameraViewTransform = CGAffineTransformMakeScale(1.5, 1.5);//全屏的效果，同时
            picker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            //上面這一行主要是在判斷裝置是否支援此項功能
            NSLog(@"//从相册获取");
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            picker.delegate=self;
            //picker.cameraViewTransform = CGAffineTransformMakeRotation(M_PI*45/180);//旋转45度的效果
            picker.allowsEditing=NO;//允许用户进行编辑
            picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -UIImagePickerController
-(void)imagePickerControllerDIdCancel:(UIImagePickerController*)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *scaleImage;
    if ([mediaType isEqualToString:@"public.image"]){
        //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始，哈哈
        //..现在拍出来一张照片分辨率很大，如果你直接放到内存里就很容易收到内存警告(Received memory warning)，通常的处理方法是拍完照压缩并缩放
        UIImage * compressDImage = [originImage compressedImage];
        NSData * data = UIImageJPEGRepresentation(compressDImage, 1.0);
        //将二进制数据生成UIImage
        scaleImage = [UIImage imageWithData:data];
    }
    
    [YWUserDefaults setValue:UIImagePNGRepresentation(scaleImage) forKey:@"HeaderImage"];
    [self uploadImage:scaleImage];
    
    [self setupSections];
    [self.tableView reloadData];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    /*
     //获取图片裁剪的图
     UIImage* edit = [info objectForKey:UIImagePickerControllerEditedImage];
     //获取图片裁剪后，剩下的图
     UIImage* crop = [info objectForKey:UIImagePickerControllerCropRect];
     //获取图片的url
     NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL];
     //获取图片的metadata数据信息
     NSDictionary* metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
     //如果是拍照的照片，则需要手动保存到本地，系统不会自动保存拍照成功后的照片
     UIImageWriteToSavedPhotosAlbum(edit, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
     */
    
}

- (void)uploadImage:(UIImage *)image {
    
    [SVProgressHUD showWithStatus:@"图片正在上传中"];
    [HttpTools UpLoadWithImage:image url:kAppendUrl(YWFileUploadString) filename:nil name:@"file" parameters:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        
    } success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSString *urlstr = [[responseObject objectForKey:@"resultData"] firstObject];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
        [dict setValue:urlstr forKey:@"files"];
        
        [SVProgressHUD show];
        [HttpTools Post:kAppendUrl(YWUpdateUserPicString) parameters:dict success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            [self.navigationController popToRootViewControllerAnimated:YES];
//            NSMutableDictionary *userDic = [[YWUserDefaults objectForKey:@"UserInfo"] mutableCopy];
//            [userDic setValue:[responseObject objectForKey:@"resultData"] forKey:@""];
            
        } failure:^(NSError *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
    }];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
