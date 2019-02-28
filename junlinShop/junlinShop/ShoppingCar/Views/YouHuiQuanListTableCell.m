//
//  YouHuiQuanListTableCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "YouHuiQuanListTableCell.h"

@implementation YouHuiQuanListTableCell

- (void)setDataWithDic:(NSDictionary *)dict {
    _specLabCenterConstraint.constant = 0;
    
    NSDictionary *infoDic = [dict objectForKey:@"couponInformation"];
    if (![ASHValidate isBlankString:[dict objectForKey:@"useInstruction"]]) {
        _titleLab.text = [NSString stringWithFormat:@"%@(%@)", [infoDic objectForKey:@"name"], [dict objectForKey:@"useInstruction"]];
    } else {
        _titleLab.text = [infoDic objectForKey:@"name"];
    }
    
    NSString *beginTime = [ASHString jsonDateToString:[infoDic objectForKey:@"beginValidityTime"] withFormat:@"yyyy-MM-dd"];
    NSString *endTime = [ASHString jsonDateToString:[infoDic objectForKey:@"endValidityTime"] withFormat:@"yyyy-MM-dd"];
    _timeLab.text = [NSString stringWithFormat:@"%@~%@", beginTime, endTime];
    
    _countLab.text = [NSString stringWithFormat:@"%.2f", [[infoDic objectForKey:@"price"] floatValue]];
    _specLab.text = [NSString stringWithFormat:@"满%@元可用", [infoDic objectForKey:@"useLimit"]];
    
    [_statusLab setBorder:[UIColor redColor] width:1 radius:5.f];
    _statusLab.transform = CGAffineTransformIdentity;
    _statusLab.transform = CGAffineTransformRotate(_statusLab.transform, 60 / 360.0);
    
    NSString *statusStr = nil;
    if ([[dict objectForKey:@"status"] integerValue] == 1) {
        statusStr = @"已使用";
    } else if ([[dict objectForKey:@"status"] integerValue] == 2) {
        statusStr = @"已过期";
    } else if ([[dict objectForKey:@"status"] integerValue] == 3) {
        statusStr = @"已失效";
    }
    if (statusStr) {
        _statusLab.text = statusStr;
        _statusLab.hidden = NO;
    } else {
        _statusLab.hidden = YES;
    }
    

}

- (void)setCanGetYouHuiQuanDataWithDic:(NSDictionary *)dict {
    _statusLab.hidden = YES;
    _specLabCenterConstraint.constant = -25;
    _getBtn.hidden = NO;
    
    _titleLab.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
    
    NSString *beginTime = [ASHString jsonDateToString:[dict objectForKey:@"beginValidityTime"] withFormat:@"yyyy-MM-dd"];
    NSString *endTime = [ASHString jsonDateToString:[dict objectForKey:@"endValidityTime"] withFormat:@"yyyy-MM-dd"];
    _timeLab.text = [NSString stringWithFormat:@"%@-%@", beginTime, endTime];
    _countLab.text = [NSString stringWithFormat:@"%.2f", [[dict objectForKey:@"price"] floatValue]];

    _specLab.text = [NSString stringWithFormat:@"满%@元可用", [dict objectForKey:@"useLimit"]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _getBtn.hidden = YES;
    [_getBtn setBorder:kBackGreenColor width:1 radius:5.f];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
