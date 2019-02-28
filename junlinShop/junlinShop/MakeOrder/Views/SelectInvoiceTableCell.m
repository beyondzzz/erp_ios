//
//  SelectInvoiceTableCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/9.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "SelectInvoiceTableCell.h"

@implementation SelectInvoiceTableCell

- (void)setDataWithDic:(NSDictionary *)dic {
    _nameLab.text = [dic objectForKey:@"unitName"];
    if ([dic objectForKey:@"taxpayerIdentificationNumber"]) {
        _numLab.text = [NSString stringWithFormat:@"纳税人识别号：%@", [dic objectForKey:@"taxpayerIdentificationNumber"]];
    } else {
        _numLab.text = @"纳税人识别号：";
    }
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
