//
//  PayCompleteViewController.h
//  junlinShop
//
//  Created by jianxuan on 2018/2/26.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseViewController.h"

@interface PayCompleteViewController : BaseViewController

@property (nonatomic) BOOL isPaySuccess;
@property (nonatomic, strong) NSNumber *orderID;
@property (nonatomic) CGFloat orderPrice;
@property (nonatomic, strong) NSString *orderNum;

@end
