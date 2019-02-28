//
//  SelectOrderTableViewCell.h
//  junlinShop
//
//  Created by jianxuan on 2017/12/7.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectOrderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *stlyeLab;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLab;
@property (weak, nonatomic) IBOutlet UILabel *OrderMoneyLab;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLab;

- (void)setDataWithDic:(NSDictionary *)dic;

@end
