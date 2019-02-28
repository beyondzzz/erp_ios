//
//  AddInvoicceInfoController.m
//  junlinShop
//
//  Created by jianxuan on 2017/12/7.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "AddInvoicceInfoController.h"
#import "SecondStepTableCell.h"
#import "UIImage+Compress.h"
#import "ShowNoticeStringController.h"
#import "CircleImageView.h"

@interface AddInvoicceInfoController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

//@property (nonatomic, assign) NSInteger step;

@property (weak, nonatomic) IBOutlet UIView *progressBackView;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIView *lastStepBackView;

@property (weak, nonatomic) IBOutlet UIView *firstStepBackView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *zengpiaoNumField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *bankNameField;
@property (weak, nonatomic) IBOutlet UITextField *bankNumField;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;

@property (nonatomic, strong) UITableView *secondStepBackView;
@property (nonatomic, strong) NSArray *secondStepArray;

@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (nonatomic, assign) NSInteger addStep;
@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, strong) NSMutableArray *imgUrlArray;
@property (nonatomic, strong) NSIndexPath *indexP;
@property (nonatomic) BOOL hasEdited;

@end

@implementation AddInvoicceInfoController

- (void)createTableView {
    if (!_secondStepBackView) {
        _secondStepBackView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_backView.frame), CGRectGetHeight(_backView.frame)) style:UITableViewStylePlain];
        _secondStepBackView.delegate = self;
        _secondStepBackView.dataSource = self;
        _secondStepBackView.backgroundColor = kBackGrayColor;
        _secondStepBackView.showsVerticalScrollIndicator = NO;
        _secondStepBackView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self createTableHeaderView];
        
        [_secondStepBackView registerNib:[UINib nibWithNibName:@"SecondStepTableCell" bundle:nil] forCellReuseIdentifier:@"SecondStepTableCell"];
        [self.backView addSubview:_secondStepBackView];
    }
}

- (void)createTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kIphoneWidth - 30, 40)];
    tipLab.font = [UIFont systemFontOfSize:12];
    tipLab.numberOfLines = 2;
    tipLab.textColor = kGrayTextColor;
    tipLab.text = @"注：资质扫描需加盖公章。仅支持jpg、jpeg、png、bmp格式，单张不超过5M。";
    [headerView addSubview:tipLab];
    
    _secondStepBackView.tableHeaderView = headerView;
}
- (IBAction)showAptitudeRequireNotice:(UIButton *)sender {
    ShowNoticeStringController *noticeVC = [[ShowNoticeStringController alloc] init];
    noticeVC.noticeType = YWNoticeStringAptitude;
    [self.navigationController pushViewController:noticeVC animated:YES];
}

- (void)uploadAptitudeData {
    
    if ([[_imgUrlArray firstObject] length] == 1) {
        [SVProgressHUD showErrorWithStatus:@"未上传营业执照副本：请上传营业执照副本"];
        return;
    }
    _addStep ++;
    
    if (_isEdit) {
        
        NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:userID forKey:@"userId"];
        [dict setValue:[self.aptitudeDic objectForKey:@"id"] forKey:@"id"];
        [dict setValue:[_imgUrlArray firstObject] forKey:@"files"];
        [dict setValue:self.nameField.text forKey:@"unitName"];
        [dict setValue:self.zengpiaoNumField.text forKey:@"taxpayerIdentificationNumber"];
        [dict setValue:self.addressField.text forKey:@"registeredAddress"];
        [dict setValue:self.phoneField.text forKey:@"registeredTel"];
        [dict setValue:self.bankNameField.text forKey:@"depositBank"];
        [dict setValue:self.bankNumField.text forKey:@"bankAccount"];
        
        [SVProgressHUD show];
        [HttpTools Post:kAppendUrl(YWUpdateInvoiceAptitudeString) parameters:dict success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            if (_addStep == 2) {
                [_sureBtn setTitle:@"返回" forState:UIControlStateNormal];
                _firstStepBackView.hidden = YES;
                _secondStepBackView.hidden = YES;
                _lastStepBackView.hidden = NO;
            }
            
        } failure:^(NSError *error) {
            
        }];
        
        return;
    }
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [_aptitudeDic setValue:userID forKey:@"userId"];
    NSMutableArray *compeleteURL = [NSMutableArray array];
    for (NSString *string in _imgUrlArray) {
        if (![string isEqualToString:@"0"]) {
            if (compeleteURL.count == 0) {
                [compeleteURL addObject:string];
            }
        }
    }
    [_aptitudeDic setValue:[_imgUrlArray firstObject] forKey:@"files"];
    
    [HttpTools Post:kAppendUrl(YWCheckInvoiceAptitudeString) parameters:_aptitudeDic success:^(id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"提交成功，请等待审核"];
        if (_addStep == 2) {
            [_sureBtn setTitle:@"返回" forState:UIControlStateNormal];
            _firstStepBackView.hidden = YES;
            _secondStepBackView.hidden = YES;
            _lastStepBackView.hidden = NO;
        }
        
    } failure:^(NSError *error) {
        _addStep --;
    }];
}

- (void)setAptitudeData {
    _nameField.text = [_aptitudeDic objectForKey:@"unitName"];
    _zengpiaoNumField.text = [_aptitudeDic objectForKey:@"taxpayerIdentificationNumber"];
    _addressField.text = [_aptitudeDic objectForKey:@"registeredAddress"];
    _phoneField.text = [_aptitudeDic objectForKey:@"registeredTel"];
    _bankNameField.text = [_aptitudeDic objectForKey:@"depositBank"];
    _bankNumField.text = [_aptitudeDic objectForKey:@"bankAccount"];
    [_imgUrlArray replaceObjectAtIndex:0 withObject:[self.aptitudeDic objectForKey:@"businessLicenseUrl"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"增加增票资质";
    _secondStepArray = [NSArray arrayWithObjects:@"请上传资质文件", nil];
    //    _secondStepArray = [NSArray arrayWithObjects:@"请上传营业执照副本", @"请上传税务登记证（地址与营业执照一致）", @"请上传一般纳税人证明", @"请上传开户许可证", @"请上传开票资料",nil];
    _imgArray = [NSMutableArray array];
    _imgUrlArray = [NSMutableArray array];
    for (NSString *str in _secondStepArray) {
        [_imgArray addObject:@"0"];
        [_imgUrlArray addObject:@"0"];
    }
    
    if (_isEdit) {
        [self setAptitudeData];
    } else {
        _aptitudeDic = [NSMutableDictionary dictionary];
    }
    _addStep = 0;
    [_sureBtn setRadius:5.f];
    _lastStepBackView.hidden = YES;
    
    [self setProgressBackViewWithStatus:_addStep];
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    
    //如果想要设置title的话也可以在这里设置,就是给btn设置title
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backItemDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    // Do any additional setup after loading the view from its nib.
}

- (void)resignAllFisrtResponder {
    [_nameField resignFirstResponder];
    [_zengpiaoNumField resignFirstResponder];
    [_addressField resignFirstResponder];
    [_phoneField resignFirstResponder];
    [_bankNameField resignFirstResponder];
    [_bankNumField resignFirstResponder];
}

- (void)backItemDidClick {
    [self resignAllFisrtResponder];
    if (_hasEdited) {
        [YWAlertView showNotice:@"您有编辑操作未保存，确认返回吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setProgressBackViewWithStatus:(NSInteger)status {
    UILabel *label01 = [_progressBackView viewWithTag:1001];
    UILabel *label02 = [_progressBackView viewWithTag:1002];
    UILabel *label03 = [_progressBackView viewWithTag:1003];
    
    label01.textColor = [UIColor darkGrayColor];
    label02.textColor = [UIColor darkGrayColor];
    label03.textColor = [UIColor darkGrayColor];
    
    UIView *tagview01 = [_progressBackView viewWithTag:1101];
    UIView *tagview02 = [_progressBackView viewWithTag:1102];
    UIView *tagview03 = [_progressBackView viewWithTag:1103];
    
    [tagview01 setBorder:[UIColor lightGrayColor] width:3 radius:9.f];
    tagview01.backgroundColor = [UIColor lightGrayColor];
    [tagview02 setBorder:[UIColor lightGrayColor] width:3 radius:9.f];
    tagview02.backgroundColor = [UIColor lightGrayColor];
    [tagview03 setBorder:[UIColor lightGrayColor] width:3 radius:9.f];
    tagview03.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *statusLabel = [_progressBackView viewWithTag:(1001 + status)];
    UILabel *statusView = [_progressBackView viewWithTag:(1101 + status)];
    statusLabel.textColor = kBackGreenColor;
    statusView.backgroundColor = kBackGreenColor;
}

- (IBAction)clickAgreeRequireBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)clickSureButton:(UIButton *)sender {
    if (_addStep == 0) {
        if (_nameField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入单位名称"];
            return;
        }
        if (_zengpiaoNumField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入纳税人识别号"];
            return;
        }
        if (_addressField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入单位注册地址"];
            return;
        }
        if (_phoneField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入单位注册电话"];
            return;
        }
        if (_bankNameField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入单位开户银行"];
            return;
        }
        if (_bankNumField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入单位银行账号"];
            return;
        }
        if (!_agreeBtn.selected) {
            [SVProgressHUD showErrorWithStatus:@"未同意《增票资质确认书》"];
            return;
        }
        
        _addStep ++;
        [self setProgressBackViewWithStatus:_addStep];
        _firstStepBackView.hidden = YES;
        [self createTableView];
    } else if (_addStep == 1) {
        
        [self uploadAptitudeData];
        [self setProgressBackViewWithStatus:_addStep];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark textFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        _hasEdited = YES;
    }
    if (textField == _nameField) {
        [_aptitudeDic setValue:textField.text forKey:@"unitName"];
    }
    if (textField == _zengpiaoNumField) {
        [_aptitudeDic setValue:textField.text forKey:@"taxpayerIdentificationNumber"];
    }
    if (textField == _addressField) {
        [_aptitudeDic setValue:textField.text forKey:@"registeredAddress"];
    }
    if (textField == _phoneField) {
        [_aptitudeDic setValue:textField.text forKey:@"registeredTel"];
    }
    if (textField == _bankNameField) {
        [_aptitudeDic setValue:textField.text forKey:@"depositBank"];
    }
    if (textField == _bankNumField) {
        [_aptitudeDic setValue:textField.text forKey:@"bankAccount"];
    }
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _secondStepArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SecondStepTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SecondStepTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.titleLab.text = _secondStepArray[indexPath.row];
    
    
    UIImage *imgUrl = _imgArray[indexPath.row];
    if ([imgUrl isKindOfClass:[UIImage class]]) {
        cell.deleteBtn.hidden = NO;
        cell.uploadImageView.image = imgUrl;
    } else {
        
        if ([[_imgUrlArray firstObject] length] > 1) {
            cell.deleteBtn.hidden = NO;
            NSString *urlStr = [_imgUrlArray firstObject];
            [cell.uploadImageView sd_setImageWithURL:[NSURL URLWithString:kAppendUrl(urlStr)] placeholderImage:kDefaultImage];
        } else {
        
            cell.deleteBtn.hidden = YES;
            cell.uploadImageView.image = [UIImage imageNamed:@"picture_add"];
        }
    }
    
    YWWeakSelf;
    [[[cell.deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [weakSelf.imgArray replaceObjectAtIndex:indexPath.row withObject:@"0"];
        [weakSelf.imgUrlArray replaceObjectAtIndex:indexPath.row withObject:@"0"];
        [weakSelf.secondStepBackView reloadData];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _indexP = indexPath;
    UIImage *imgUrl = _imgArray[indexPath.row];
    if ([imgUrl isKindOfClass:[UIImage class]]) {
        CircleImageView *circleView = [[CircleImageView alloc] init];
        [circleView setImageArray:_imgArray andIndex:0];
    } else {
        [self addPictureImage];
    }
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
        //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始，哈哈
        //..现在拍出来一张照片分辨率很大，如果你直接放到内存里就很容易收到内存警告(Received memory warning)，通常的处理方法是拍完照压缩并缩放
        UIImage * compressDImage = [originImage compressedImage];
        NSData * data = UIImageJPEGRepresentation(compressDImage, 0.8);
        //将二进制数据生成UIImage
        scaleImage = [UIImage imageWithData:data];
    }
    
    [_imgArray replaceObjectAtIndex:_indexP.row withObject:scaleImage];
    [self.secondStepBackView reloadData];
    
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
        [_imgArray replaceObjectAtIndex:index withObject:@"0"];
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
