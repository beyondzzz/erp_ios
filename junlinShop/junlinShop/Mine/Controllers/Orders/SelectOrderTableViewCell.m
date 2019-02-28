//
//  SelectOrderTableViewCell.m
//  junlinShop
//
//  Created by jianxuan on 2017/12/7.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "SelectOrderTableViewCell.h"

@implementation SelectOrderTableViewCell

- (void)setDataWithDic:(NSDictionary *)dic {
    _orderNumLab.text = [NSString stringWithFormat:@"订单号：%@", [dic objectForKey:@""]];
    _OrderMoneyLab.text = [NSString stringWithFormat:@"订单金额：%@", [dic objectForKey:@""]];
    _orderTimeLab.text = [NSString stringWithFormat:@"下单时间：%@", [dic objectForKey:@""]];
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
