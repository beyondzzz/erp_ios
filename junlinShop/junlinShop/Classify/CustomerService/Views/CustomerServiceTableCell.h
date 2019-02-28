//
//  CustomerServiceTableCell.h
//  junlinShop
//
//  Created by jianxuan on 2018/3/6.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerServiceTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *orderImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *specLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UILabel *totlePriceLab;

- (void)setDataWithDic:(NSDictionary *)dic;

@end
