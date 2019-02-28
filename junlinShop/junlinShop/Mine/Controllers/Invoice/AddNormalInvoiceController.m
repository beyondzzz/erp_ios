//
//  AddNormalInvoiceController.m
//  junlinShop
//
//  Created by 叶旺 on 2018/5/28.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "AddNormalInvoiceController.h"

@interface AddNormalInvoiceController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *numField;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (nonatomic) BOOL hasEdited;

@end

@implementation AddNormalInvoiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isEditing) {
        self.navigationItem.title = @"修改公司信息";
        
        _nameField.text = [_normalDic objectForKey:@"unitName"];
        if ([_normalDic objectForKey:@"taxpayerIdentificationNumber"]) {
            _numField.text = [_normalDic objectForKey:@"taxpayerIdentificationNumber"];
        } else {
            _numField.text = @"";
        }
        
    } else {
        self.navigationItem.title = @"新增公司信息";
    }
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    
    //如果想要设置title的话也可以在这里设置,就是给btn设置title
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backItemDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    // Do any additional setup after loading the view from its nib.
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

- (void)resignAllFisrtResponder {
    [_nameField resignFirstResponder];
    [_numField resignFirstResponder];
}

- (IBAction)clickSaveButton:(UIButton *)sender {
    [self resignAllFisrtResponder];

    if (_nameField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入单位名称"];
        return;
    }
    if (_numField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入纳税人识别号"];
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
    [dic setValue:userID forKey:@"userId"];
    [dic setValue:_nameField.text forKey:@"unitName"];
    [dic setValue:_numField.text forKey:@"taxpayerIdentificationNumber"];
    
    [SVProgressHUD show];
    if (_isEditing) {
        [dic setValue:[_normalDic objectForKey:@"id"] forKey:@"id"];
        
        [HttpTools Post:kAppendUrl(YWUpdateInvoiceUnitString) parameters:dic success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *error) {
            
        }];
    } else {
        [HttpTools Post:kAppendUrl(YWAddInvoiceUnitString) parameters:dic success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"添加成功"];
            
            [self.navigationController popViewControllerAnimated:YES];

        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        _hasEdited = YES;
    }
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
