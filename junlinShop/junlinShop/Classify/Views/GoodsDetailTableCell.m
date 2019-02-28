//
//  GoodsDetailTableCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/1/24.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "GoodsDetailTableCell.h"

@implementation GoodsDetailTableCell

- (void)setUIHiddenAtIndex:(NSInteger)index {
    if (index == 0) {
        _activeLab.hidden = NO;
        _detailLab.hidden = YES;
        _leftLabConstraint.constant = 8;
        _locationImageView.hidden = YES;
        _rightImageView.hidden = YES;
        _tipsLab.hidden = YES;
        _leftLab.text = @"促销";
        
    } else if (index == 1) {
        _activeLab.hidden = YES;
        _detailLab.hidden = NO;
        _leftLabConstraint.constant = 8;
        _locationImageView.hidden = YES;
        _rightImageView.hidden = NO;
        _tipsLab.hidden = YES;
        _leftLab.text = @"已选";
    } else {
        _activeLab.hidden = YES;
        _detailLab.hidden = NO;
        _leftLabConstraint.constant = 30;
        _locationImageView.hidden = NO;
        _rightImageView.hidden = NO;
        _tipsLab.hidden = NO;
        _leftLab.text = @"送至";
    }
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
