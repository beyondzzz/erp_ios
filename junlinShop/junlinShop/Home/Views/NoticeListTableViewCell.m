//
//  NoticeListTableViewCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/7.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "NoticeListTableViewCell.h"

@implementation NoticeListTableViewCell

- (void)setDataWithDic:(NSDictionary *)dic {
    _timeLab.text = [ASHString jsonDateToString:[dic objectForKey:@"addTime"] withFormat:@"MM月dd HH:mm:ss"];
    
    NSDictionary *orderDic = [dic objectForKey:@"orderTable"];
    _titleLab.text = [NSString stringWithFormat:@"【%@】", [orderDic objectForKey:@"orderNo"]];;
    
    _subTitleLab.text = [NSString stringWithFormat:@"最新状态：%@", [dic objectForKey:@"orderStateDetail"]];
    
    NSString *timeStr = [ASHString jsonDateToString:[dic objectForKey:@"addTime"] withFormat:@"yyyy-MM-dd HH:mm:ss"];
    _detailLab.text = [NSString stringWithFormat:@"状态更新时间：%@", timeStr];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_backWhiteView setRadius:5.f];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
