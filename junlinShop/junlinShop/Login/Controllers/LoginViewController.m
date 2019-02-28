//
//  LoginViewController.m
//  simple
//
//  Created by jianxuan on 2017/11/20.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "LoginViewController.h"
#import "MTimerButton.h"
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthInfo.h"
#import "APRSASigner.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet MTimerButton *codeButton;
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *otherLoginView;
@property (nonatomic, copy) NSString *messageCode;
@property (nonatomic, copy) NSString *loginType;
@property (nonatomic, copy) NSString *otherUserName;

@property (nonatomic, assign) BOOL isBinding;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _loginType = @"0";
    _isBinding = NO;
    
    if (_isBinding) {
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:@"提示：未注册的手机号，登录时将自动注册，注册代表您已同意《注册协议》"];
        [attribute addAttribute:NSForegroundColorAttributeName value:kBackYellowColor range:NSMakeRange(28, 6)];
        _tipsLab.attributedText = attribute;
    } else {
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:@"提示：未注册食讯帮账号的手机号，登录时将自动注册食讯帮账号，且代表您已同意《注册协议》"];
        [attribute addAttribute:NSForegroundColorAttributeName value:kBackYellowColor range:NSMakeRange(35, 6)];
        _tipsLab.attributedText = attribute;
    }
    
    [_loginBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(kIphoneWidth - 50, 45) andColor:kGrayTextColor] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(kIphoneWidth - 50, 45) andColor:kBackYellowColor] forState:UIControlStateSelected];
    [_loginBtn setRadius:22.5f];
    _loginBtn.selected = NO;
    _loginBtn.userInteractionEnabled = NO;
    
    [_codeButton setBorder:kBackYellowColor width:1 radius:5.f];
    [_codeButton setTitleColor:kBackYellowColor forState:UIControlStateNormal];
    
    _tipsLab.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZhuCeProtocol)];
    [_tipsLab addGestureRecognizer:tapGesture];
    
    if (_isBinding) {
        _otherLoginView.hidden = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳过" style:UIBarButtonItemStyleDone target:self action:@selector(jumpOver)];
    } else {
        _otherLoginView.hidden = NO;
    }
    
    [YWNoteCenter addObserver:self selector:@selector(AlipayLoginComplete:) name:@"kAlipayLoginComplete" object:nil];

}

#pragma mark 点击事件处理
- (void)jumpOver {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)showZhuCeProtocol {
    NSLog(@"showZhuCeProtocol");
}

- (IBAction)clickBackButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickContactBtn:(UIButton *)sender {
    NSString *str = @"telprompt://4006865856";
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    
}

- (IBAction)doLogin:(UIButton *)sender {
    [SVProgressHUD show];
    
    if (!_isBinding) {
        _loginType = @"0";
    }
    
    if (self.phoneTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号"];
        return;
    } else if (![ASHValidate isMobileNumber:self.phoneTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"请输入真实的手机号"];
        return;
    }
    if (_messageCode == nil) {
        [SVProgressHUD showErrorWithStatus:@"请先获取验证码"];
        return;
    }
    if (self.codeTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        return;
    } else if (![_messageCode isEqualToString:self.codeTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"验证码输入错误"];
        return;
    }
    
    if (_isBinding) {
        [self bindingWithPhoneNum:_phoneTextField.text];
    } else {
        [self loginWithUserName:_phoneTextField.text];
    }
}

- (IBAction)getCode:(MTimerButton *)sender forEvent:(UIEvent *)event {
    UITouch *touch = [event.allTouches anyObject];
    if (touch.tapCount == 1) {
        if (self.phoneTextField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入手机号"];
            return;
        } else if (![ASHValidate isMobileNumber:self.phoneTextField.text]) {
            [SVProgressHUD showErrorWithStatus:@"请输入真实的手机号"];
            return;
        }
        [sender countDownWithNum:60];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        [dict setValue:self.phoneTextField.text forKey:@"mobile"];
//        NSLog(@"请求参数：%@",dict);
        [HttpTools Get:kAppendUrl(YWMessageCodeString) parameters:dict success:^(id responseObject) {
            NSDictionary *dic = [(NSDictionary *)responseObject objectForKey:@"resultData"];
            _messageCode = [dic objectForKey:@"MessageCode"];
            NSLog(@"%@", dic);
        } failure:^(NSError *error) {
            NSLog(@"失败：%@",error);
        }];
    }
}

//微信登录
- (IBAction)doWeixinLogin:(UIButton *)sender {
    
    _loginType = @"1";
    if ([ShareSDK hasAuthorized:SSDKPlatformTypeWechat]) {
        
        [ShareSDK getUserInfo:SSDKPlatformTypeWechat
               onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
         {
             if (state == SSDKResponseStateSuccess)
             {
                 
                 NSLog(@"uid=%@",user.uid);
                 NSLog(@"%@",user.credential);
                 NSLog(@"token=%@",user.credential.token);
                 NSLog(@"nickname=%@",user.nickname);
                 
                 _otherUserName = user.uid;
                 [self loginWithUserName:user.uid];
             }
             
             else
             {
                 NSLog(@"%@",error);
             }
             
         }];
        
    } else {
        [ShareSDK authorize:SSDKPlatformTypeWechat
                   settings:nil
             onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                 switch (state) {
                     case SSDKResponseStateSuccess:
                     {
                         NSLog(@"授权 成功");
                         _otherUserName = user.uid;
                         [self loginWithUserName:user.uid];
                         break;
                     }
                     case SSDKResponseStateFail:
                     {
                         NSLog(@"%@",error);
                         
                         break;
                     }
                         break;
                     case SSDKResponseStateCancel:
                     {
                         NSLog(@"取消授权");
                         break;
                     }
                     default:
                         break;
                 }
             }];
    }
}

//QQ登录
- (IBAction)doQQLogin:(UIButton *)sender {
    /**
     设置QQ授权登录
     
     @param platformType 平台
     @param result 授权成功
     @param error 授权失败
     */
    _loginType = @"2";
    
    if ([ShareSDK hasAuthorized:SSDKPlatformTypeQQ]) {
        
        [ShareSDK getUserInfo:SSDKPlatformTypeQQ
               onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
         {
             if (state == SSDKResponseStateSuccess)
             {
                 
                 NSLog(@"uid=%@",user.uid);
                 NSLog(@"%@",user.credential);
                 NSLog(@"token=%@",user.credential.token);
                 NSLog(@"nickname=%@",user.nickname);
                 _otherUserName = user.uid;
                 [self loginWithUserName:user.uid];
             }
             
             else
             {
                 NSLog(@"%@",error);
             }
             
         }];
        
    } else {
        [ShareSDK authorize:SSDKPlatformTypeQQ
                   settings:nil
             onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                 switch (state) {
                     case SSDKResponseStateSuccess:
                     {
                         NSLog(@"授权 成功");
                         _otherUserName = user.uid;
                         [self loginWithUserName:user.uid];
                         break;
                     }
                     case SSDKResponseStateFail:
                     {
                         NSLog(@"%@",error);
                         
                         break;
                     }
                         break;
                     case SSDKResponseStateCancel:
                     {
                         NSLog(@"取消授权");
                         break;
                     }
                     default:
                         break;
                 }
             }];
    }
}

//支付宝登录
- (IBAction)doZhiFuBaoLogin:(UIButton *)sender {
//    [[AlipaySDK defaultService] auth_V2WithInfo:@"2018020702155294" fromScheme:@"AlipayJunLinFood" callback:^(NSDictionary *resultDic) {
//        NSLog(@"");
//    }];
    _loginType = @"3";
//    [self doAPAuth];
    [HttpTools Get:kAppendUrl(YWAliPayAuthString) parameters:nil success:^(id responseObject) {
        
        NSString *authInfo = [responseObject objectForKey:@"resultData"];
        [[AlipaySDK defaultService] auth_V2WithInfo:authInfo
                 fromScheme:@"AlipayJunLinFood"
                   callback:^(NSDictionary *resultDic) {
                       NSLog(@"result = %@",resultDic);
                       // 解析 auth code
                       NSString *result = resultDic[@"result"];
                       NSString *userId = nil;
                       if (result.length>0) {
                           NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                           for (NSString *subResult in resultArr) {
                               if (subResult.length > 15 && [subResult hasPrefix:@"alipay_open_id="]) {
                                   userId = [subResult substringFromIndex:15];
                                   break;
                               }
                           }
                       }
                       if (userId) {
                           _otherUserName = userId;
                           [self loginWithUserName:userId];
                       }
                   }];
    
        
    } failure:^(NSError *error) {
        NSLog(@"11");
    }];
}


- (void)AlipayLoginComplete:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    _otherUserName = [dic objectForKey:@"userId"];
    [self loginWithUserName:[dic objectForKey:@"userId"]];
}

- (void)bindingWithPhoneNum:(NSString *)phoneNum {
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setValue:_loginType forKey:@"type"];
    [dict setValue:phoneNum forKey:@"phone"];
    [dict setValue:_otherUserName forKey:@"account"];
    
    NSLog(@"请求参数：%@",dict);
    [HttpTools Post:kAppendUrl(YWBindPhoneString) parameters:dict success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSDictionary *dic = [(NSDictionary *)responseObject objectForKey:@"resultData"];
        
        [YWUserDefaults setValue:[dic objectForKey:@"userId"] forKey:@"UserID"];
        [YWUserDefaults setValue:dic forKey:@"UserInfo"];
        [self.navigationController popViewControllerAnimated:YES];
        
        NSLog(@"%@", dic);
    } failure:^(NSError *error) {
        NSLog(@"失败：%@",error);
    }];
}

- (void)loginWithUserName:(NSString *)userName {
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setValue:_loginType forKey:@"type"];
    [dict setValue:userName forKey:@"account"];
    NSLog(@"请求参数：%@",dict);
    
    [HttpTools Post:kAppendUrl(YWLoginString) parameters:dict success:^(id responseObject) {
       
        [SVProgressHUD dismiss];
        NSDictionary *dic = [(NSDictionary *)responseObject objectForKey:@"resultData"];
        
        BOOL flag = [[dic objectForKey:@"flag"] boolValue];
        
        if (flag) {
            [YWUserDefaults setValue:[dic objectForKey:@"userId"] forKey:@"UserID"];
            [YWUserDefaults setValue:dic forKey:@"UserInfo"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            
            [SVProgressHUD showSuccessWithStatus:@"登录成功，请输入手机号码进行绑定"];
            _isBinding = YES;
            [self setBinDingUI];
            
        }
        
        
        NSLog(@"%@", dic);
    } failure:^(NSError *error) {
        NSLog(@"失败：%@",error);
    }];
        
}
    
    

- (void)setBinDingUI {
    [_loginBtn setTitle:@"绑定手机号" forState:UIControlStateNormal];
    _otherLoginView.hidden = YES;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_phoneTextField.text.length > 0 && _codeTextField.text.length > 0) {
        _loginBtn.selected = YES;
        _loginBtn.userInteractionEnabled = YES;
    } else {
        _loginBtn.selected = NO;
        _loginBtn.userInteractionEnabled = NO;
    }
}

- (void)dealloc {
    [YWNoteCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
