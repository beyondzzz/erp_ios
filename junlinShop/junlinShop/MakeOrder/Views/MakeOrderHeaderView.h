//
//  MakeOrderHeaderView.h
//  junlinShop
//
//  Created by jianxuan on 2017/12/11.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MakeOrderHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIView *tipsBackView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressTopConstaint;

@property (weak, nonatomic) IBOutlet UIView *addressBackView;
@property (weak, nonatomic) IBOutlet UILabel *addressNameLab;
@property (weak, nonatomic) IBOutlet UILabel *addressPhoneLab;
@property (weak, nonatomic) IBOutlet UILabel *morenLab;
@property (weak, nonatomic) IBOutlet UILabel *addressLab;

@end
