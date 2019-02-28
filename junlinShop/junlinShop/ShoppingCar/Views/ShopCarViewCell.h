//
//  ShopCarViewCell.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/22.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopCarModel.h"
#import "TQAmountTextField.h"

@interface ShopCarViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *activeBackView;
@property (weak, nonatomic) IBOutlet UILabel *activeTagLab;
@property (weak, nonatomic) IBOutlet UILabel *activeDetailLab;
@property (weak, nonatomic) IBOutlet UIButton *activeBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsDetailLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UIView *specBackView;
@property (weak, nonatomic) IBOutlet UIImageView *specImageView;
@property (weak, nonatomic) IBOutlet UILabel *specLab;
@property (weak, nonatomic) IBOutlet UIImageView *saleOutImageView;
@property (weak, nonatomic) IBOutlet UILabel *saleCountLab;
@property (weak, nonatomic) IBOutlet TQAmountTextField *AmountTextField;

@property (nonatomic, copy) void (^clickSelectBtn)(BOOL isSelected);

- (void)setDataWithModel:(ShopCarModel *)model completeBlock:(void (^)(BOOL isReloadData))completeBlock;

@end
