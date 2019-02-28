//
//  AddressLisTableViewCell.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/28.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressLisTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIButton *setMorenBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;


@end
