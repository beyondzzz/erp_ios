//
//  HomeViewHotCell.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/28.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewHotCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLab;
@property (weak, nonatomic) IBOutlet UILabel *saleCountLab;
@property (weak, nonatomic) IBOutlet UIButton *qiangBtn;

- (void)setDataWithDic:(NSDictionary *)dic;

@end
