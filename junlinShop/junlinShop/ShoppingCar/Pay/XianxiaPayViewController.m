//
//  XianxiaPayViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/26.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "XianxiaPayViewController.h"
#import "XianxiaPayHeaderView.h"
#import "XianxiaPayFooterView.h"
#import "InputTextTableViewCell.h"
#import "UIImage+Compress.h"
#import "PayCompleteViewController.h"
#import "CircleImageView.h"

@interface XianxiaPayViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) XianxiaPayFooterView *footerView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *inputArray;

@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, strong) NSMutableArray *imgUrlArray;

@end

@implementation XianxiaPayViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"InputTextTableViewCell" bundle:nil] forCellReuseIdentifier:@"InputTextTableViewCell"];
        
        if (_orderNum) {
            [self loadHeaderView];
            [self loadFooterView];
        }
        [self.view addSubview:_tableView];
    }
}

- (void)loadHeaderView {
    XianxiaPayHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"XianxiaPayHeaderView" owner:nil options:nil] firstObject];
    headerView.frame = CGRectMake(0, 0, kIphoneWidth, 200);
    headerView.titleLab.text = [NSString stringWithFormat:@"您的订单（订单号：%@）已提交成功！由于订单金额过大，需进行线下汇款，汇款信息如下", _orderNum];
    
    _tableView.tableHeaderView = headerView;
}

- (void)loadFooterView {
    _footerView = [[[NSBundle mainBundle] loadNibNamed:@"XianxiaPayFooterView" owner:nil options:nil] firstObject];
    _footerView.frame = CGRectMake(0, 0, kIphoneWidth, 180);
    
    _tableView.tableFooterView = _footerView;
    
    for (UIView *view in _footerView.imageBackView.subviews) {
        view.hidden = YES;
    }
    
    for (int i = 0; i < 2; i ++) {
        
        UIView *backView = [_footerView.imageBackView viewWithTag:i + 1000];
        UIImageView *imageView = [backView.subviews firstObject];
        UIButton *deleteBtn = [backView.subviews lastObject];
        
        if (i <= _imgArray.count) {
            backView.hidden = NO;
            deleteBtn.hidden = backView.hidden;
            if (i == _imgArray.count) {
                deleteBtn.hidden = YES;
            }
        }
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        YWWeakSelf;
        [[tapGesture rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            NSInteger index = x.view.superview.tag - 1000;
            if (index == _imgArray.count) {
                [weakSelf addPictureImage];
            } else {
                CircleImageView *circleView = [[CircleImageView alloc] init];
                
                [circleView setImageArray:_imgArray andIndex:index];
            }
            
        }];
        [imageView addGestureRecognizer:tapGesture];
        
        [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]  subscribeNext:^(__kindof UIControl * _Nullable x) {
            NSInteger index = x.superview.tag - 1000;
            
            if (index < 3) {
                UIView *backView = [weakSelf.footerView.imageBackView viewWithTag:i + 1001];
                backView.hidden = YES;
            }
//            else {
//                UIView *backView = [weakSelf.footerView.imageBackView viewWithTag:i + 1004];
//                UIImageView *imageView = [backView.subviews firstObject];
//                UIButton *deleteBtn = [backView.subviews lastObject];
//                imageView.image = [UIImage imageNamed:@"picture_add"];
//                deleteBtn.hidden = YES;
//            }
            
            [weakSelf.imgArray removeObjectAtIndex:index];
            [weakSelf.imgUrlArray replaceObjectAtIndex:index withObject:@"0"];
            [weakSelf updateImageView];
        }];
    }
}

- (void)updateImageView {
    for (int i = 0; i < _imgArray.count + 1; i ++) {

        UIView *backView = [_footerView.imageBackView viewWithTag:i + 1000];
        UIImageView *imageView = [backView.subviews firstObject];
        UIButton *deleteBtn = [backView.subviews lastObject];
        
        if (i < 2) {
            backView.hidden = NO;
            deleteBtn.hidden = backView.hidden;
        }

        if (i < _imgArray.count) {
            imageView.image = _imgArray[i];
        }
        if (i == _imgArray.count) {
            deleteBtn.hidden = YES;
            imageView.image = [UIImage imageNamed:@"picture_add"];
        }
    }
//    UIView *backView = [_footerView.imageBackView viewWithTag:1000];
//    UIImageView *imageView = [backView.subviews firstObject];
//    UIButton *deleteBtn = [backView.subviews lastObject];
//    if (_imgArray.count == 0) {
//
//        deleteBtn.hidden = YES;
//        imageView.image = [UIImage imageNamed:@"picture_add"];
//    } else {
//        imageView.image = [_imgArray firstObject];
//        deleteBtn.hidden = NO;
//    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"线下支付";
    
    _imgArray = [NSMutableArray array];
    _inputArray = [NSMutableArray array];
    _imgUrlArray = [NSMutableArray arrayWithObjects:@"0", @"0", nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(uploadPayInfo)];
    self.navigationItem.rightBarButtonItem.tintColor = kBlackTextColor;
    
    if (_orderNum && _isPay) {
        self.titleArray = [NSArray arrayWithObjects:@"订单号", @"待支付金额", @"收款人", @"开户行", @"账号", @"汇款人姓名", @"汇款人账户", nil];
        NSString *payString = [NSString stringWithFormat:@"¥ %.2f", _payPrice];
        [self.inputArray addObjectsFromArray:[NSArray arrayWithObjects:_orderNum, payString, @"北京食讯帮食品发展有限公司", @"中国光大银行股份有限公司北京清华园支行", @"35360188000020130", @"", @"", nil]];
    } else {
        self.titleArray = [NSArray arrayWithObjects:@"收款人", @"开户行", @"账号", @"汇款人姓名", @"汇款人手机号", nil];
        [self.inputArray addObjectsFromArray:[NSArray arrayWithObjects:@"北京食讯帮食品发展有限公司", @"中国光大银行股份有限公司北京清华园支行", @"35360188000020130", @"", @"", nil]];
    }
    
    [self createTableView];
}

- (void)uploadPayInfo {
    
    [self.tableView endEditing:YES];
    
//    for (NSString *string in _inputArray) {
//        if (string.length == 0) {
//            [SVProgressHUD showErrorWithStatus:@"信息未输入完全无法提交，请补全！"];
//            return;
//        }
//    }
    
    if (!_orderNum && !_isPay) {
        if ([_inputArray[3] length] == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入汇款人姓名"];
            return;
        }
        if ([_inputArray[4] length] == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入汇款人手机号"];
            return;
        }
        if (![ASHValidate isMobileNumber:_inputArray[4]]) {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
            return;
        }
        
        NSString *name = _inputArray[3];
        NSString *phone = _inputArray[4];
        self.completePay(name, phone);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([_inputArray[5] length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入汇款人姓名"];
        return;
    }
    if ([_inputArray[6] length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入汇款人账户"];
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_orderNum forKey:@"orderNo"];
    
    NSMutableArray *imageUrlArr = [NSMutableArray array];
    for (NSString *string in _imgUrlArray) {
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
        [dict setValue:[imageUrlArr componentsJoinedByString:@","] forKey:@"files"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请上传汇款图片"];
        return;
    }
    
    NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dict setValue:userID forKey:@"userId"];
    
    [dict setValue:_inputArray[5] forKey:@"remitterName"];
    [dict setValue:_inputArray[6] forKey:@"remitterAccount"];
    [dict setValue:_inputArray[2] forKey:@"payeeName"];
    [dict setValue:_inputArray[3] forKey:@"payeeAccount"];
    [dict setValue:_inputArray[4] forKey:@"payeeAccountDepositBank"];
    [dict setValue:@(_payPrice) forKey:@"remittanceAmount"];
 
    //TODO                //订单不存在或该订单不存在线下支付信息

    [HttpTools Post:kAppendUrl(YWOfflinePaymentString) parameters:dict success:^(id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"提交成功，请等待审核"];
        [self completeOffLinePay];
    } failure:^(NSError *error) {
        NSLog(@"111");
    }];
}

- (void)completeOffLinePay {
//    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
//    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
//    [parameter setValue:userID forKey:@"userId"];
//    [parameter setValue:_orderID forKey:@"orderId"];
//    [parameter setValue:@"1" forKey:@"operation"];
//
//    [SVProgressHUD show];
//    [HttpTools Post:kAppendUrl(YWOrderCancleString) parameters:parameter success:^(id responseObject) {
//        [SVProgressHUD dismiss];
        PayCompleteViewController *completeVC = [[PayCompleteViewController alloc] init];
        completeVC.orderID = _orderID;
        completeVC.orderNum = _orderNum;
        completeVC.orderPrice = _payPrice;
        completeVC.isPaySuccess = YES;
        [self.navigationController pushViewController:completeVC animated:YES];
        
//    } failure:^(NSError *error) {
//        NSLog(@"111");
//    }];
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InputTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InputTextTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.titleLab.text = _titleArray[indexPath.row];
    
    if ([_titleArray[indexPath.row] containsString:@"汇款人姓名"] || [_titleArray[indexPath.row] containsString:@"汇款人手机号"] || [_titleArray[indexPath.row] containsString:@"汇款人账户"]) {
        cell.inputTextField.hidden = NO;
        cell.inputLab.hidden = YES;
        cell.inputTextField.placeholder = [NSString stringWithFormat:@"请输入%@", _titleArray[indexPath.row]];
        
        cell.inputTextField.delegate = self;
        cell.inputTextField.tag = indexPath.row + 1000;
        
        if ([_inputArray[indexPath.row] length] > 0) {
            cell.inputTextField.text = _inputArray[indexPath.row];
        }
    } else {
        cell.inputTextField.hidden = YES;
        cell.inputLab.hidden = NO;
        cell.inputLab.text = _inputArray[indexPath.row];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark textFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSInteger index = textField.tag - 1000;
    if ([_titleArray[index] containsString:@"汇款人手机号"]) {
        if (![ASHValidate isMobileNumber:textField.text]) {
            [SVProgressHUD showErrorWithStatus:@"请输入正确手机号"];
            textField.text = @"";
            return;
        }
    }
    
    [_inputArray replaceObjectAtIndex:index withObject:textField.text];
}

//添加图片
- (void)addPictureImage {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
        //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始，
        //..现在拍出来一张照片分辨率很大，如果你直接放到内存里就很容易收到内存警告(Received memory warning)，通常的处理方法是拍完照压缩并缩放
        UIImage * compressDImage = [originImage compressedImage];
        NSData * data = UIImageJPEGRepresentation(compressDImage, 1.0);
        //将二进制数据生成UIImage
        scaleImage = [UIImage imageWithData:data];
    }
    
    [_imgArray addObject:scaleImage];
    [self updateImageView];
    
    [self uploadImage:scaleImage atIndex:[_imgArray indexOfObject:scaleImage]];
    
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

- (void)uploadImage:(UIImage *)image atIndex:(NSInteger)index {
    
    [SVProgressHUD showWithStatus:@"图片正在上传中"];
    [HttpTools UpLoadWithImage:image url:kAppendUrl(YWFileUploadString) filename:nil name:@"file" parameters:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        
    } success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSString *urlstr = [[responseObject objectForKey:@"resultData"] firstObject];
        [_imgUrlArray replaceObjectAtIndex:index withObject:urlstr];
    } failure:^(NSError *error) {
        [_imgArray removeObjectAtIndex:index];
        [self updateImageView];
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
