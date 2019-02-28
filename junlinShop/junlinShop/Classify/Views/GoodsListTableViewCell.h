//
//  GoodsListTableViewCell.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsDesLab;
@property (weak, nonatomic) IBOutlet UILabel *goodsSpecLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UIButton *addCarBtn;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

 
- (void)setDataWithDic:(NSDictionary *)dic;

@end
