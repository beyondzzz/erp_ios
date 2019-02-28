//
//  CustomerServiceFooterView.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "CustomerServiceFooterView.h"

@implementation CustomerServiceFooterView

- (void)awakeFromNib {
    [_leftBtn setBorder:kBackGreenColor width:1 radius:5.f];
    [_centerBtn setBorder:kGrayTextColor width:1 radius:5.f];
    [_rightBtn setBorder:kGrayTextColor width:1 radius:5.f];
    [super awakeFromNib];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
