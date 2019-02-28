//
//  OrderListTableViewCell.h
//  meirongApp
//
//  Created by jianxuan on 2017/11/28.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *orderImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *specLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *countLab;

- (void)setDataWithDic:(NSDictionary *)dic;

@end
