//
//  OrderDetailFooterView.h
//  meirongApp
//
//  Created by jianxuan on 2017/12/6.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailFooterView : UIView

@property (weak, nonatomic) IBOutlet UILabel *orderNumLab;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *payTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *payTypeLab;
@property (weak, nonatomic) IBOutlet UILabel *invoiceInfoLab;

@end
