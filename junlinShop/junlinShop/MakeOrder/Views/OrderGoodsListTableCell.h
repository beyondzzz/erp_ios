//
//  OrderGoodsListTableCell.h
//  junlinShop
//
//  Created by jianxuan on 2018/2/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderGoodsListTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *specLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;


@end
