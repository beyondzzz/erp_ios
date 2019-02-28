//
//  OrderDetailHeaderView.h
//  meirongApp
//
//  Created by jianxuan on 2017/12/3.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailHeaderView : UIView

@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UILabel *status02Lab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *statusAllBtn;
@property (weak, nonatomic) IBOutlet UILabel *addressNameLab;
@property (weak, nonatomic) IBOutlet UILabel *addPhoneLab;
@property (weak, nonatomic) IBOutlet UILabel *addressLab;
@property (weak, nonatomic) IBOutlet UILabel *noticeLab;

@end
