//
//  InvoiceNormalTableCell.h
//  junlinShop
//
//  Created by 叶旺 on 2018/3/18.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvoiceNormalTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *unitNameLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *companyName;
@property (weak, nonatomic) IBOutlet UILabel *numberTitle;

@property (nonatomic, copy) void (^refreshTable)();

- (void)setDataWithDic:(NSDictionary *)dic;

@end
