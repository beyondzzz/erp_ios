//
//  MakeOrderGoodsListCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/7.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "MakeOrderGoodsListCell.h"

@implementation MakeOrderGoodsListCell

- (void)setDataWithDic:(NSDictionary *)dic {
    _goodsNameLab.text = [dic objectForKey:@"goodsName"];
    _specLab.text = [dic objectForKey:@"goodsSpecificationName"];
    NSString *str =  [dic objectForKey:@"goodsOriginalPrice"];
    
    _priceLab.text = [NSString stringWithFormat:@"¥ %.2f", [str floatValue]];
    
    NSString *picUrl = kAppendUrl([dic objectForKey:@"goodsCoverUrl"]);
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:kDefaultImage];
    
    [_AmountTextField setBorder:kGrayLineColor width:1.f radius:5.f];
    _AmountTextField.buyMinNumber = 1;
    _AmountTextField.TQTextFiled.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"goodsQuantity"]];
    _AmountTextField.stepLength = 1;
    
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
