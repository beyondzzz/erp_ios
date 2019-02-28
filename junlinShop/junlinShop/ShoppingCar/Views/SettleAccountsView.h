//
//  SettleAccountsView.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/22.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettleAccountsView : UIView

@property (nonatomic, strong) UIButton *accountsBtn;
@property (nonatomic, strong) UILabel *totlePriceLab;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic) CGFloat carriage;

+ (instancetype)initWithButtonTitle:(NSString *)title hasTabBar:(BOOL)hasTabBar;

@end
