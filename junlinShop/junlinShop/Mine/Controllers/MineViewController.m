//
//  MineViewController.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "MineViewController.h"
#import "AddressListViewController.h"
#import "SettingViewController.h"
#import "LoginViewController.h"
#import "InvoiceInfoViewController.h"
#import "YouHuiQuanListController.h"
#import "OrderListViewController.h"
#import "GetYouHuiQuanViewController.h"
#import "UserNameSetViewController.h"
#import "UIImage+Compress.h"
#import "YWWebViewController.h"
#import "NoticeCenterViewController.h"
#import "ToCommentViewController.h"

@interface MineViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIStackView *orderStackView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *AllOrderBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AddressBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *noticeBtn;

@end

@implementation MineViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary *userInfo = [YWUserDefaults objectForKey:@"UserInfo"];
    if (userInfo) {
        NSString *picurl = [userInfo objectForKey:@"userPicUrl"];
        NSString *userName = [userInfo objectForKey:@"userName"];
        if (![ASHValidate isBlankString:picurl]) {
            [_headerImageView sd_setImageWithURL:[NSURL URLWithString:kAppendUrl(picurl)] placeholderImage:kDefaultImage];
        }
        if (![ASHValidate isBlankString:userName]) {
            [_loginBtn setTitle:userName forState:UIControlStateNormal];
        }
        
        [self requestOrderList];
        
    } else {
        _headerImageView.image = [UIImage imageNamed:@"mine_headerImage"];
        [_loginBtn setTitle:@"登录/注册" forState:UIControlStateNormal];
        
        [self setOrderBtnBadgeValue:0 atIndex:0];
        [self setOrderBtnBadgeValue:0 atIndex:1];
        [self setOrderBtnBadgeValue:0 atIndex:2];
        [self setOrderBtnBadgeValue:0 atIndex:3];
    }
    if ([YWUserDefaults objectForKey:@"HeaderImage"]) {
        NSData* imageData = [YWUserDefaults objectForKey:@"HeaderImage"];
        UIImage *image = [UIImage imageWithData:imageData];
        _headerImageView.image = image;
    }
    
    if ([[YWUserDefaults objectForKey:@"HasNotice"] integerValue] == 1) {
        _noticeBtn.badgeValue = @" ";
    } else {
        _noticeBtn.badgeValue = @"";
    }
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [YWUserDefaults setValue:UIImagePNGRepresentation(_headerImageView.image) forKey:@"HeaderImage"];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)requestOrderList {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dic setValue:userID forKey:@"userId"];
    
    [HttpTools Get:kAppendUrl(YWOrderListString) parameters:dic success:^(id responseObject) {
        [self.view stopLoading];
        
        NSInteger zhifuCount = 0;
        NSInteger shouhuoCount = 0;
        NSInteger pingjiaCount = 0;
        NSInteger shouhouCount = 0;
        for (NSDictionary *dict in [responseObject objectForKey:@"resultData"]) {
            NSInteger state = [[dict objectForKey:@"orderState"] integerValue];
            if (state == 0) {
                zhifuCount ++;
            } else if (state == 2) {
                shouhuoCount ++;
            } else if (state == 6) {
                shouhouCount ++;
            }
            
            if (state == 3 || state == 10 || state == 10) {
                
                if ([[dict objectForKey:@"isHasEvaluation"] intValue] == 0) {
                    pingjiaCount ++;
                }
            }
            
        }
        
        [self setOrderBtnBadgeValue:zhifuCount atIndex:0];
        [self setOrderBtnBadgeValue:shouhuoCount atIndex:1];
        [self setOrderBtnBadgeValue:pingjiaCount atIndex:2];
        [self setOrderBtnBadgeValue:shouhouCount atIndex:3];
                
    } failure:^(NSError *error) {
        
        
    }];
}

- (void)setOrderBtnBadgeValue:(NSInteger)count atIndex:(NSInteger)index {
    
    UIButton *btn = [[[_orderStackView viewWithTag:1000 + index] subviews] firstObject];
    if (count) {
        btn.badgeValue = [NSString stringWithFormat:@"%ld", count];
    } else {
        btn.badgeValue = @"";
    }
}

//- (void)refreshOrderNum {
//    [self requestOrderList];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    _topImageView.image = [UIImage createImageWithSize:CGSizeMake(kIphoneWidth, 180) andColor:kBackGreenColor];
    if (kIphoneWidth < 375.0) {
        _AddressBtnWidthConstraint.constant = 44.0;
    } else if (kIphoneWidth == 375.0) {
        _AddressBtnWidthConstraint.constant = 48.0;
    } else {
        _AddressBtnWidthConstraint.constant = 56.0;
    }
    [self.headerImageView setRadius:40.f];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(changeHeaderImage:)];
    [_headerImageView addGestureRecognizer:tapGesture];
    
    _loginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
//    [YWNoteCenter addObserver:self selector:@selector(refreshOrderNum) name:@"RefreshOrderNumber" object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)changeHeaderImage:(UIGestureRecognizer *)gesture {
    if ([self isShowLoginVC]) {
        return;
    }
    SettingViewController *settingVC = [[SettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (BOOL)isShowLoginVC {
    if (![YWUserDefaults objectForKey:@"UserID"]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
        return YES;
    }
    return NO;
}

- (IBAction)clickNoticeBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    
    NoticeCenterViewController *noticeVC = [[NoticeCenterViewController alloc] init];
    [self.navigationController pushViewController:noticeVC animated:YES];
}

- (IBAction)clickLoginBtn:(UIButton *)sender {
    if ([YWUserDefaults objectForKey:@"UserID"]) {
        
        SettingViewController *settingVC = [[SettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:settingVC animated:YES];
        
    } else {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

//待支付
- (IBAction)clickunPayBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    OrderListViewController *orderListVC = [[OrderListViewController alloc] init];
    orderListVC.statusType = 1;
    [self.navigationController pushViewController:orderListVC animated:YES];
}

//待收货
- (IBAction)clickunTakeGoodsBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    OrderListViewController *orderListVC = [[OrderListViewController alloc] init];
    orderListVC.statusType = 2;
    [self.navigationController pushViewController:orderListVC animated:YES];
}

//待评价
- (IBAction)clickunMarkBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    ToCommentViewController *toCommentVC = [[ToCommentViewController alloc] init];
    [self.navigationController pushViewController:toCommentVC animated:YES];
}

//售后服务
- (IBAction)clickOverSaleServiceBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    OrderListViewController *orderListVC = [[OrderListViewController alloc] init];
    orderListVC.statusType = 4;
    [self.navigationController pushViewController:orderListVC animated:YES];
}

//全部订单
- (IBAction)clickAllOrderBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    OrderListViewController *orderListVC = [[OrderListViewController alloc] init];
    orderListVC.statusType = 0;
    [self.navigationController pushViewController:orderListVC animated:YES];
}

//我的地址
- (IBAction)clickMyAddressBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    AddressListViewController *addressVC = [[AddressListViewController alloc] init];
    [self.navigationController pushViewController:addressVC animated:YES];
}

//发票管理
- (IBAction)clickInvoiceBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    InvoiceInfoViewController *invoiceVC = [[InvoiceInfoViewController alloc] init];
    [self.navigationController pushViewController:invoiceVC animated:YES];
}

//优惠券
- (IBAction)clickCouponBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    YouHuiQuanListController *listVC = [[YouHuiQuanListController alloc] init];
    [self.navigationController pushViewController:listVC animated:YES];
}

//客服服务
- (IBAction)clickJunlinServiceBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    YWWebViewController *webVC = [[YWWebViewController alloc] init];
    NSDictionary *dict = [YWUserDefaults objectForKey:@"UserInfo"];
    webVC.titleStr = @"客服服务";
    webVC.webURL = [NSString stringWithFormat:@"%@%@&userName=%@&isVip=%@&clientId=%@", YWServiceHtmlString, [dict objectForKey:@"userPhone"],  [dict objectForKey:@"userName"], [dict objectForKey:@"isVIP"], [dict objectForKey:@"userId"]];
    [self.navigationController pushViewController:webVC animated:YES];
}

//设置
- (IBAction)clickSettingBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    SettingViewController *settingVC = [[SettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingVC animated:YES];
}

//领券中心
- (IBAction)clickLingQuanCenterBtn:(UIButton *)sender {
    if ([self isShowLoginVC]) {
        return;
    }
    GetYouHuiQuanViewController *getVC = [[GetYouHuiQuanViewController alloc] init];
    [self.navigationController pushViewController:getVC animated:YES];
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
    
    self.headerImageView.image = scaleImage;
    [self uploadImage:scaleImage];
    [YWUserDefaults setValue:UIImagePNGRepresentation(scaleImage) forKey:@"HeaderImage"];
    
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
            
        } failure:^(NSError *error) {
            [YWUserDefaults removeObjectForKey:@"HeaderImage"];
        }];
        
    } failure:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
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
