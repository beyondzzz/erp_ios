//
//  CustomerServiceTableCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/6.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "CustomerServiceTableCell.h"

@implementation CustomerServiceTableCell

- (void)setDataWithDic:(NSDictionary *)dic {
    NSString *imgUrl = kAppendUrl([dic objectForKey:@"goodsCoverUrl"]);
    [_orderImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:kDefaultImage];
    _nameLab.text = [dic objectForKey:@"goodsName"];
    _priceLab.text = [NSString stringWithFormat:@"价格：¥%@", [dic objectForKey:@"goodsOriginalPrice"]];
    _specLab.text = [dic objectForKey:@"goodsSpecificationName"];
    _countLab.text = [NSString stringWithFormat:@"数量：x%@", [dic objectForKey:@"goodsQuantity"]];
    
    _totlePriceLab.text = [NSString stringWithFormat:@"¥%@", [dic objectForKey:@"goodsPaymentPrice"]];
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
