//
//  CustomerServiceViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "CustomerServiceViewController.h"
#import "CustomerServiceFooterView.h"
#import "CustomerServiceTableCell.h"
#import "UIImage+Compress.h"
#import "CircleImageView.h"

@interface CustomerServiceViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CustomerServiceFooterView *footerView;

@property (nonatomic, strong) NSString *serviceType;
@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, strong) NSMutableArray *imgUrlArray;

@end

@implementation CustomerServiceViewController

- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBackGrayColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"CustomerServiceTableCell" bundle:nil] forCellReuseIdentifier:@"CustomerServiceTableCell"];
        
        [self.view addSubview:_tableView];
        
        [self loadFooterView];
    }
}

- (void)loadFooterView {
    _footerView = [[[NSBundle mainBundle] loadNibNamed:@"CustomerServiceFooterView" owner:nil options:nil] lastObject];
    _footerView.frame = CGRectMake(0, 0, kIphoneWidth, 530);
    _footerView.textView.delegate = self;
    _footerView.nameField.delegate = self;
    _footerView.phoneField.delegate = self;
    
    self.tableView.tableFooterView = _footerView;
    
    if ([_orderDic objectForKey:@"consigneeName"]) {
        _footerView.nameField.text = [_orderDic objectForKey:@"consigneeName"];
    }
    if ([_orderDic objectForKey:@"consigneeTel"]) {
        _footerView.phoneField.text = [_orderDic objectForKey:@"consigneeTel"];
    }
    
    for (UIView *view in _footerView.backImageView.subviews) {
        view.hidden = YES;
    }

    for (int i = 0; i < 5; i ++) {

        UIView *backView = [_footerView.backImageView viewWithTag:i + 1000];
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
            
            if (index == weakSelf.imgArray.count) {
                [weakSelf addPictureImage];
            } else {
                CircleImageView *circleView = [[CircleImageView alloc] init];
                [circleView setImageArray:weakSelf.imgArray andIndex:index];
                
//                if (index < 4) {
                
//                } else {
//                    UIView *backView = [weakSelf.footerView.backImageView viewWithTag:i + 1004];
//                    UIImageView *imageView = [backView.subviews firstObject];
//                    UIButton *deleteBtn = [backView.subviews lastObject];
//                    imageView.image = [UIImage imageNamed:@"picture_add"];
//                    deleteBtn.hidden = YES;
//                }
            }
        }];
        [imageView addGestureRecognizer:tapGesture];

        [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]  subscribeNext:^(__kindof UIControl * _Nullable x) {
            NSInteger index = x.superview.tag - 1000;
            [weakSelf.imgArray removeObjectAtIndex:index];
            [weakSelf.imgUrlArray replaceObjectAtIndex:index withObject:@"0"];
            [weakSelf updateImageView];
            
        }];
    }
    [self addBacKClickTarget];
}

- (void)addBacKClickTarget {
    YWWeakSelf;
    [[_footerView.leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        [weakSelf.footerView.leftBtn setBorder:kBackGreenColor width:1 radius:5.f];
        
        weakSelf.footerView.centerBtn.selected = !x.selected;
        [weakSelf.footerView.centerBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.footerView.rightBtn.selected = !x.selected;
        [weakSelf.footerView.rightBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.serviceType = @"0";
    }];
    
    [[_footerView.centerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        [weakSelf.footerView.centerBtn setBorder:kBackGreenColor width:1 radius:5.f];
        
        weakSelf.footerView.leftBtn.selected = !x.selected;
        [weakSelf.footerView.leftBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.footerView.rightBtn.selected = !x.selected;
        [weakSelf.footerView.rightBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.serviceType = @"1";
    }];
    
    [[_footerView.rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        [weakSelf.footerView.rightBtn setBorder:kBackGreenColor width:1 radius:5.f];
        
        weakSelf.footerView.leftBtn.selected = !x.selected;
        [weakSelf.footerView.leftBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.footerView.centerBtn.selected = !x.selected;
        [weakSelf.footerView.centerBtn setBorder:kBackGrayColor width:1 radius:5.f];
        
        weakSelf.serviceType = @"2";
    }];
}

- (void)updateImageView {
    
    
    for (int i = 0; i < 5; i ++) {
        
        UIView *backView = [_footerView.backImageView viewWithTag:i + 1000];
        UIImageView *imageView = [backView.subviews firstObject];
        UIButton *deleteBtn = [backView.subviews lastObject];
        
        if (i <= _imgArray.count) {
            backView.hidden = NO;
            deleteBtn.hidden = backView.hidden;
            if (i == _imgArray.count) {
                deleteBtn.hidden = YES;
            }
        } else {
            backView.hidden = YES;
        }
        
        if (i < _imgArray.count) {
            imageView.image = _imgArray[i];
        } else if (i == _imgArray.count) {
            deleteBtn.hidden = YES;
            imageView.image = [UIImage imageNamed:@"picture_add"];
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"申请售后";
    _imgArray = [NSMutableArray array];
    _imgUrlArray = [NSMutableArray arrayWithObjects:@"0", @"0", @"0", @"0", @"0", nil];
    [self createTableView];
    
    self.serviceType = @"0";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(uploadCustomerService)];
    self.navigationItem.rightBarButtonItem.tintColor = kBackGreenColor;
    // Do any additional setup after loading the view from its nib.
}

- (void)uploadCustomerService {
    if (_footerView.textView.text.length == 0 || [_footerView.textView.text isEqualToString:@"请详细描述问题，500字以内"]) {
        [SVProgressHUD showErrorWithStatus:@"请输入问题描述"];
        return;
    }
    
    if (_footerView.nameField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入姓名"];
        return;
    } else if (_footerView.nameField.text.length < 2 || _footerView.nameField.text.length > 5) {
        [SVProgressHUD showErrorWithStatus:@"姓名长度为2-5个字符"];
        return;
    }
    
    if (_footerView.phoneField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号"];
        return;
    } else if (![ASHValidate isMobileNumber:_footerView.phoneField.text]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确手机号"];
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
    
    NSMutableArray *compeleteURL = [NSMutableArray array];
    for (NSString *string in _imgUrlArray) {
        if (![string isEqualToString:@"0"]) {
            [compeleteURL addObject:string];
        }
    }
    [dict setValue:[compeleteURL componentsJoinedByString:@","] forKey:@"files"];
    [dict setValue:_footerView.textView.text forKey:@"problemDescription"];
    [dict setValue:_serviceType forKey:@"serviceType"];
    [dict setValue:_footerView.nameField.text forKey:@"name"];
    [dict setValue:_footerView.phoneField.text forKey:@"phone"];
    [dict setValue:[_orderDic objectForKey:@"id"] forKey:@"orderId"];
    
    [SVProgressHUD show];
    [HttpTools Post:kAppendUrl(YWSetCustomerString) parameters:dict success:^(id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"提交成功，我们会尽快给您回复"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark TextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _footerView.placeHoulderLab.hidden = YES;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length >= 500) {
        [SVProgressHUD showErrorWithStatus:@"最多输入500个字符"];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 500) {
        [SVProgressHUD showErrorWithStatus:@"最多输入500个字符"];
        [textView endEditing:YES];
    } else {
        if (textView.text.length == 0) {
            _footerView.placeHoulderLab.hidden = NO;
        } else if (textView.text.length > 0) {
            _footerView.placeHoulderLab.hidden = YES;
        }
        _footerView.countLab.text = [NSString stringWithFormat:@"%ld/500", textView.text.length];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView.text.length > 500) {
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length > 500) {
        return;
    }
    if (textView.text.length == 0) {
        _footerView.placeHoulderLab.hidden = NO;
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

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_orderDic objectForKey:@"orderDetails"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerServiceTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomerServiceTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *array = [_orderDic objectForKey:@"orderDetails"];
    [cell setDataWithDic:array[indexPath.row]];
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
