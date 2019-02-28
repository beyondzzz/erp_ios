//
//  SelectInvoiceTableCell.h
//  junlinShop
//
//  Created by jianxuan on 2018/3/9.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectInvoiceTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UILabel *registAddressLa;
@property (weak, nonatomic) IBOutlet UILabel *registMobileLab;
@property (weak, nonatomic) IBOutlet UILabel *bankLab;
@property (weak, nonatomic) IBOutlet UILabel *bankNumLab;

- (void)setDataWithDic:(NSDictionary *)dic;

@end
