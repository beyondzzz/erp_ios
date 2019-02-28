//
//  OrderListTableViewCell.m
//  meirongApp
//
//  Created by jianxuan on 2017/11/28.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "OrderListViewCell.h"

@implementation OrderListViewCell

- (void)setDataWithDic:(NSDictionary *)dic {
    NSString *imgUrl = kAppendUrl([dic objectForKey:@"goodsCoverUrl"]);
    [_orderImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:kDefaultImage];
    _nameLab.text = [dic objectForKey:@"goodsName"];
     NSString *price = [dic objectForKey:@"goodsOriginalPrice"];
   
    _priceLab.text = [NSString stringWithFormat:@"¥%.2f", [price floatValue]];
    _specLab.text = [dic objectForKey:@"goodsSpecificationName"];
   
    
    _countLab.text = [NSString stringWithFormat:@"x%@", [dic objectForKey:@"goodsQuantity"]];
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
