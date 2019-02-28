//
//  AddNormalInvoiceView.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/9.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "AddNormalInvoiceView.h"

@interface AddNormalInvoiceView ()

@property (nonatomic, strong) NSNumber *unitID;

@end

@implementation AddNormalInvoiceView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_nameField setRadius:5.f];
    [_numField setRadius:5.f];
    self.backgroundColor = [kBlackTextColor colorWithAlphaComponent:0.4];

}

- (void)initData {
    _nameField.text = @"";
    _numField.text = @"";
    _unitID = nil;
    [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [YWWindow addSubview:self];
}

- (void)initDataWithDic:(NSDictionary *)unitDic {
    
    _nameField.text = [unitDic objectForKey:@"unitName"];
    if ([unitDic objectForKey:@"taxpayerIdentificationNumber"]) {
        _numField.text = [unitDic objectForKey:@"taxpayerIdentificationNumber"];
    } else {
        _numField.text = @"";
    }
    _unitID = [unitDic objectForKey:@"id"];
    
    [_addBtn setTitle:@"修改" forState:UIControlStateNormal];
    [YWWindow addSubview:self];
}

- (IBAction)clickAddButton:(UIButton *)sender {
    
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
    if ([sender.currentTitle isEqualToString:@"修改"]) {
        [dic setValue:_unitID forKey:@"id"];
        
        [HttpTools Post:kAppendUrl(YWUpdateInvoiceUnitString) parameters:dic success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            self.completeBlock();
            [self removeFromSuperview];
        } failure:^(NSError *error) {
            
        }];
    } else {
        [HttpTools Post:kAppendUrl(YWAddInvoiceUnitString) parameters:dic success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"添加成功"];
            self.completeBlock();
            [self removeFromSuperview];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (IBAction)clickCancelButton:(UIButton *)sender {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
