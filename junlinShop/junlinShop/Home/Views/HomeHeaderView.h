//
//  HomeHeaderView.h
//  junlinShop
//
//  Created by 叶旺 on 2017/11/28.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIView *topCycleBackView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIView *qiangGouBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qiangGouHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomBackView;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIView *presellBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *presellBackViewHeightConstant;

@property (weak, nonatomic) IBOutlet UIView *timeBackView;

@end
