//
//  InvoiceNormalTableCell.m
//  junlinShop
//
//  Created by 叶旺 on 2018/3/18.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "InvoiceNormalTableCell.h"
#import "YWAlertView.h"

@implementation InvoiceNormalTableCell

- (void)setDataWithDic:(NSDictionary *)dic {
    if ([dic objectForKey:@"nodata"]) {
        _numLab.text = @"没有公司";
        _unitNameLab.text = @"";
        _deleteBtn.hidden = YES;
        _editBtn.hidden = YES;
        _numberTitle.hidden = YES;
        _companyName.hidden = YES;
        return;
    }else{
        _deleteBtn.hidden = NO;
        _editBtn.hidden = NO;
        _numberTitle.hidden = NO;
        _companyName.hidden = NO;
    }
    
    
    
    
    
    _unitNameLab.text = [dic objectForKey:@"unitName"];
    _numLab.text = [dic objectForKey:@"taxpayerIdentificationNumber"];
    
    [[[_deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        [YWAlertView showNotice:@"确认删除吗？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            
            NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:userID forKey:@"userId"];
            [dict setValue:[dic objectForKey:@"id"] forKey:@"id"];
            
            [HttpTools Post:kAppendUrl(YWDeleteInvoiceUnitString) parameters:dict success:^(id responseObject) {
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                self.refreshTable();
            } failure:^(NSError *error) {
                
            }];
            
        }];
        
    }];
    
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
