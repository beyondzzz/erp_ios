//
//  OrderAddressStatusTableCell.m
//  junlinShop
//
//  Created by 叶旺 on 2018/2/13.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "OrderAddressStatusTableCell.h"

@implementation OrderAddressStatusTableCell

- (void)setDataWithDic:(NSDictionary *)dic {
    self.titleLab.text = [dic objectForKey:@"orderStateDetail"];
    self.timeLab.text = [ASHString jsonDateToString:[dic objectForKey:@"addTime"] withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self.statusView setRadius:10.f];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
