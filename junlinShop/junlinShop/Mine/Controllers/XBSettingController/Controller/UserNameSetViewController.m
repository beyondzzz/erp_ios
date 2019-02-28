//
//  UserNameSetViewController.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/29.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "UserNameSetViewController.h"

@interface UserNameSetViewController () <UITextFieldDelegate>

@property (nonatomic) BOOL hasEdited;

@end

@implementation UserNameSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"用户名设置";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(complete)];
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    
    //如果想要设置title的话也可以在这里设置,就是给btn设置title
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backItemDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    // Do any additional setup after loading the view from its nib.
}

- (void)backItemDidClick {
    [_userNameField resignFirstResponder];
    if (_hasEdited) {
        [YWAlertView showNotice:@"您有编辑操作未保存，确认返回吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)complete {
    if (_userNameField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入用户名"];
        return;
    } else if (_userNameField.text.length < 2 || _userNameField.text.length > 20) {
        [SVProgressHUD showErrorWithStatus:@"用户名长度在2-20个字符之间"];
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
    [dict setValue:_userNameField.text forKey:@"name"];
    
    [SVProgressHUD show];
    [HttpTools Post:kAppendUrl(YWUpdateUserNameString) parameters:dict success:^(id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        
        YWWeakSelf;
        self.completeChangeUserName(weakSelf.userNameField.text);
        
        NSMutableDictionary *userInfo = [[YWUserDefaults objectForKey:@"UserInfo"] mutableCopy];
        [userInfo setValue:_userNameField.text forKey:@"userName"];
        [YWUserDefaults setValue:userInfo forKey:@"UserInfo"];
        [YWUserDefaults synchronize];
        
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 1) {
        _hasEdited = YES;
    }
    if (textField.text.length < 2 || textField.text.length > 20) {
        [SVProgressHUD showErrorWithStatus:@"用户名长度应在2-20个字符之间"];
        textField.text = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
