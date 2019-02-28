//
//  SelectPaymentViewController.h
//  junlinShop
//
//  Created by jianxuan on 2018/2/26.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseViewController.h"

@interface SelectPaymentViewController : BaseViewController

@property (nonatomic, assign) CGFloat payPrice;
@property (nonatomic, strong) NSString *orderNum;
@property (nonatomic, strong) NSNumber *orderID;
@property (nonatomic, strong) NSString *tipStr;

@end
