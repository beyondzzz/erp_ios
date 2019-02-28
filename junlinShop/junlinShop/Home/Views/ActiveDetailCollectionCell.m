//
//  ActiveDetailCollectionCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/14.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ActiveDetailCollectionCell.h"

@implementation ActiveDetailCollectionCell

- (void)setDataWithDic:(NSDictionary *)dic {
    NSString *picUrl = nil;
    NSNumber *price = nil;
    NSArray *detailArr = [dic objectForKey:@"goodsSpecificationDetails"];
    if (detailArr.count) {
        NSArray *picArr = [[detailArr firstObject] objectForKey:@"goodsDisplayPictures"];
        if (picArr.count) {
            picUrl = kAppendUrl([[picArr firstObject] objectForKey:@"picUrl"]);
        }
        price = [[detailArr firstObject] objectForKey:@"price"];
    }
    
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:kDefaultImage];
    _goodsNameLab.text = [dic objectForKey:@"name"];
    
    if (price) {
        _priceLab.text = [NSString stringWithFormat:@"¥ %.2f", [price floatValue]];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
