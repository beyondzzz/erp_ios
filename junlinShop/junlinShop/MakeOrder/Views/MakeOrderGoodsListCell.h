//
//  MakeOrderGoodsListCell.h
//  junlinShop
//
//  Created by jianxuan on 2018/2/7.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQAmountTextField.h"

@interface MakeOrderGoodsListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLab;
@property (weak, nonatomic) IBOutlet UILabel *specLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet TQAmountTextField *AmountTextField;

- (void)setDataWithDic:(NSDictionary *)dic;

@end
