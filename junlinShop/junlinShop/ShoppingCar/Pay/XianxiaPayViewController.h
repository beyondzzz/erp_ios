//
//  XianxiaPayViewController.h
//  junlinShop
//
//  Created by jianxuan on 2018/2/26.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseViewController.h"

@interface XianxiaPayViewController : BaseViewController

@property (nonatomic, assign) CGFloat payPrice;
@property (nonatomic, strong) NSString *orderNum;
@property (nonatomic, strong) NSNumber *orderID;
@property (nonatomic) BOOL isPay;

@property (nonatomic, copy) void (^completePay)(NSString *payerName, NSString *payerTel);

@end
