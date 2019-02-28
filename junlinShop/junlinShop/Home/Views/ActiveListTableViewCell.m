//
//  ActiveListTableViewCell.m
//  junlinShop
//
//  Created by 叶旺 on 2018/3/25.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ActiveListTableViewCell.h"

@implementation ActiveListTableViewCell

- (void)setDataWithDic:(NSDictionary *)dic {
    _timeLab.text = [ASHString jsonDateToString:[dic objectForKey:@"getTime"] withFormat:@"MM月dd HH:mm:ss"];
    
    NSDictionary *infoDic = [dic objectForKey:@"activityInformation"];
    _titleLab.text = [NSString stringWithFormat:@"【%@】", [infoDic objectForKey:@"name"]];
    
    if ([infoDic objectForKey:@"messagePicUrl"]) {
        [_noticeImageView sd_setImageWithURL:[NSURL URLWithString:kAppendUrl([infoDic objectForKey:@"messagePicUrl"])] placeholderImage:kDefaultImage];
    }
//    _subTitleLab.text = [NSString stringWithFormat:@"最新状态：%@", [dic objectForKey:@"orderStateDetail"]];
    
    _detailLab.text = [NSString stringWithFormat:@"%@", [infoDic objectForKey:@"introduction"]];
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
