//
//  AddressEditViewController.m
//  meirongApp
//
//  Created by jianxuan on 2017/12/1.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "AddressEditViewController.h"
#import "SelectAddressViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "BLAreaPickerView.h"
#import "YWAlertView.h"

@interface AddressEditViewController () <UITextFieldDelegate, UITextViewDelegate, CNContactPickerDelegate, BLPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextView *detailAddressField;


@property (weak, nonatomic) IBOutlet UIButton *morenBtn;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLab;
@property (weak, nonatomic) IBOutlet UIButton *openTongXunLuBtn;

@property (strong, nonatomic) BLAreaPickerView *locateView;
@property (nonatomic) BOOL hasEdited;

@end

@implementation AddressEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _titleStr;
    _hasEdited = NO;
    
    if (_model) {
        _nameTextField.text = _model.consigneeName;
        _phoneTextField.text = _model.consigneeTel;
        _addressField.text = _model.region;
        _detailAddressField.text = _model.detailedAddress;
        _placeHolderLab.hidden = YES;
        
        if ([_model.isCommonlyUsed integerValue] == 1) {
            _morenBtn.selected = YES;
        }
        
        
    } else {
        _model = [[AddressModel alloc] init];
    }
    
    [_openTongXunLuBtn setRadius:5.f];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(doSave)];
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    
    //如果想要设置title的话也可以在这里设置,就是给btn设置title
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backItemDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    // Do any additional setup after loading the view from its nib.
}

- (void)resignAllFisrtResponder {
    [_nameTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [_addressField resignFirstResponder];
    [_detailAddressField resignFirstResponder];
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

- (void)doSave {
    
    [self resignAllFisrtResponder];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
    
    if (_model.consigneeName.length > 0 && _model.consigneeName.length < 11) {
        [dict setValue:_model.consigneeName forKey:@"consigneeName"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"收货人姓名1-10个字之间"];
        return;
    }
    
   
    if ([ASHValidate isMobileNumber:_model.consigneeTel] ) {
        [dict setValue:_model.consigneeTel forKey:@"consigneeTel"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    
    if (_model.region) {
        [dict setValue:_model.region forKey:@"region"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请选择地区"];
        return;
    }
    
    if (_model.isCommonlyUsed) {
        [dict setValue:_model.isCommonlyUsed forKey:@"isCommonlyUsed"];
    } else {
        [dict setValue:@"0" forKey:@"isCommonlyUsed"];
    }
    if (_model.detailedAddress.length > 0 && _model.detailedAddress.length < 31) {
        [dict setValue:_model.detailedAddress forKey:@"detailedAddress"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"详细地址应为1-30个字之间"];
        return;
    }
    
    
    [dict setValue:_model.provinceCode forKey:@"provinceCode"];
    if (_model.cityCode) {
        [dict setValue:_model.cityCode forKey:@"cityCode"];
    } else {
        [dict setValue:@"0" forKey:@"cityCode"];
    }
    
    [dict setValue:_model.countyCode forKey:@"countyCode"];
    [dict setValue:_model.ringCode forKey:@"ringCode"];
    
    if (_model.ID) {
        [dict setValue:_model.ID forKey:@"id"];
        [HttpTools Post:kAppendUrl(YWAddressUpdateString) parameters:dict success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    } else {
        [HttpTools Post:kAppendUrl(YWAddressAddString) parameters:dict success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"成功增加地址"];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

- (IBAction)addPhoneNum:(UIButton *)sender {
    [self resignAllFisrtResponder];
    [self requestAuthorizationForAddressBook];
}

- (IBAction)clickMoRenBtn:(UIButton *)sender {
    [self resignAllFisrtResponder];
    sender.selected = !sender.selected;
    _hasEdited = YES;
    if (sender.selected) {
        _model.isCommonlyUsed = @(1);
    } else {
        _model.isCommonlyUsed = @(0);
    }
}

#pragma mark----- 访问通讯录
- (void)requestAuthorizationForAddressBook
{
    // 获取授权
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (authorizationStatus == CNAuthorizationStatusNotDetermined) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                NSLog(@"-授权成功-");
                // 初始化CNContactPickerViewController
                CNContactPickerViewController *contactPickerViewController = [[CNContactPickerViewController alloc] init];
                // 设置代理
                contactPickerViewController.delegate = self;
                contactPickerViewController.displayedPropertyKeys = [[NSArray alloc]initWithObjects:CNContactPhoneNumbersKey, nil];
                // 显示联系人窗口视图
                [self presentViewController:contactPickerViewController animated:YES completion:nil];
            }else
            {
                NSLog(@"----error===%@",error);
            }
        }];
    }
    else if(authorizationStatus == CNAuthorizationStatusAuthorized){
        CNContactPickerViewController *contactPickerViewController = [[CNContactPickerViewController alloc] init];
        // 设置代理
        contactPickerViewController.delegate = self;
        contactPickerViewController.displayedPropertyKeys = [[NSArray alloc]initWithObjects:CNContactPhoneNumbersKey, nil];
        // 显示联系人窗口视图
        [self presentViewController:contactPickerViewController animated:YES completion:nil];
    }
}

#pragma mark----选中一个联系人的属性
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    NSString *phone = [contactProperty.value stringValue];
    if (phone == nil)
    {
        phone = @"";
    }
    NSString *phoneStr = [NSString stringWithString:phone];
    NSLog(@"phoneStr=%@",phoneStr);
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    _phoneTextField.text = phoneStr;
}


#pragma mark BLAreaPickerViewDelegate
- (void)bl_selectedAddressIDWithProvince:(NSString *)provinceTitle city:(NSString *)cityTitle area:(NSString *)areaTitle {
    
    if ([provinceTitle isEqualToString:@"110000"] || [provinceTitle isEqualToString:@"120000"] || [provinceTitle isEqualToString:@"310000"] || [provinceTitle isEqualToString:@"500000"]) {
        self.model.cityCode = @"0";
    }
    self.model.provinceCode = provinceTitle;
    
    if ([provinceTitle isEqualToString:@"110000"]) {
        self.model.ringCode = areaTitle;
        self.model.countyCode = cityTitle;
    } else {
        self.model.ringCode = @"-1";
        self.model.countyCode = areaTitle;
    }
    self.hasEdited = YES;
}

- (void)bl_selectedAreaResultWithProvince:(NSString *)provinceTitle city:(NSString *)cityTitle area:(NSString *)areaTitle {
    _addressField.text = [NSString stringWithFormat:@"%@%@%@", provinceTitle, cityTitle, areaTitle];
    self.model.region = _addressField.text;
}


#pragma mark - UITextView

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _placeHolderLab.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        _placeHolderLab.hidden = NO;
        _hasEdited = NO;
    } else {
        _hasEdited = YES;
    }
    
    
    _model.detailedAddress = textView.text;
    
}
#pragma mark - UITextFieldDelegate

 - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _addressField) {
        
        if (!_locateView) {
            _locateView = [[BLAreaPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
            _locateView.pickViewDelegate = self;
        }
        if (![self.view.subviews containsObject:_locateView]) {
            [_locateView bl_show];
        }
        
        [self resignAllFisrtResponder];
        
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        _hasEdited = YES;
    }
    
    if (textField == _nameTextField) {
             _model.consigneeName = textField.text;
        
    }
    
    
    if (textField == _phoneTextField) {
       
            _model.consigneeTel = textField.text;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
