//
//  GoodsListTableViewCell.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "GoodsListTableViewCell.h"

@implementation GoodsListTableViewCell

- (void)setDataWithDic:(NSDictionary *)dic {
    NSString *picUrl = nil;
    NSString *specStr = nil;
    NSString *price = nil;
    NSString *oldPrice = nil;

    NSArray *detailArr = [dic objectForKey:@"goodsSpecificationDetails"];
    if (detailArr.count) {
        NSArray *picArr = [[detailArr firstObject] objectForKey:@"goodsDisplayPictures"];
        if (picArr.count) {
            picUrl = kAppendUrl([[picArr firstObject] objectForKey:@"picUrl"]);
        }
        specStr = [[detailArr firstObject] objectForKey:@"specifications"];
        price = [[detailArr firstObject] objectForKey:@"price"];
        oldPrice = [[detailArr firstObject] objectForKey:@"oldPrice"];

    }
    
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:kDefaultImage];
    _goodsDesLab.text = [dic objectForKey:@"name"];
    _goodsSpecLab.text = specStr;
    _countLab.text = [NSString stringWithFormat:@"已售%@", [dic objectForKey:@"saleCount"]];

    if (price) {
        _priceLabel.text = [NSString stringWithFormat:@"¥ %.2f", [price floatValue]];
    }
    
    
    oldPrice = [NSString stringWithFormat:@"%@",oldPrice];
    if (IsStrEmpty(oldPrice)) {
        _oldPriceLabel.attributedText = nil;
    }else{
        NSMutableAttributedString *newPrice = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@",oldPrice]];
        [newPrice addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, newPrice.length)];
        _oldPriceLabel.attributedText = newPrice;
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
