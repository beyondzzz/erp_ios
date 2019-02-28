//
//  HomeViewSecendCell.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/21.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewSecendCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLab;

- (void)setDataWithDic:(NSDictionary *)dic;

@end
