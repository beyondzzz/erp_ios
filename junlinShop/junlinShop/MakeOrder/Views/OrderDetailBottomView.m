//
//  OrderDetailBottomView.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "OrderDetailBottomView.h"

@implementation OrderDetailBottomView

- (void)awakeFromNib {
    [_rightBtn setBorder:kBackGreenColor width:1 radius:4.f];
    [_leftBtn setBorder:kGrayTextColor width:1 radius:4.f];
    [_centerBtn setBorder:kGrayTextColor width:1 radius:4.f];
    [_deleteBtn setBorder:kGrayTextColor width:1 radius:4.f];
    
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
