//
//  HomeViewHotCell.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/28.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "HomeViewHotCell.h"

@implementation HomeViewHotCell

- (void)setDataWithDic:(NSDictionary *)dic {
    NSString *picUrl = nil;
    NSNumber *price = nil;
    NSString *oldPrice = nil;

    NSNumber *salesCount = nil;
    
    NSArray *detailArr = [dic objectForKey:@"goodsSpecificationDetails"];
    if (detailArr.count) {
        NSArray *picArr = [[detailArr firstObject] objectForKey:@"goodsDisplayPictures"];
        if (picArr.count) {
            picUrl = kAppendUrl([[picArr firstObject] objectForKey:@"picUrl"]);
        }
        price = [[detailArr firstObject] objectForKey:@"price"];
        salesCount = [[detailArr firstObject] objectForKey:@"salesCount"];
        oldPrice = [[detailArr firstObject] objectForKey:@"oldPrice"];

    }
    
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:kDefaultImage];
    _goodsNameLab.text = [dic objectForKey:@"name"];
    if (price) {
        _priceLab.text = [NSString stringWithFormat:@"¥%@", price];
    }
    if (salesCount) {
        oldPrice = [NSString stringWithFormat:@"%@",oldPrice];
        if (IsStrEmpty(oldPrice)) {
            _oldPriceLab.attributedText = nil;
        }else{
            NSMutableAttributedString *newPrice = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@",oldPrice]];
            [newPrice addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, newPrice.length)];
            _oldPriceLab.attributedText = newPrice;
        }
     }
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
 
}



@end
