//
//  ShowNoticeStringController.h
//  junlinShop
//
//  Created by 叶旺 on 2018/5/21.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseViewController.h"

typedef enum {
    YWNoticeStringNormal = 0,
    YWNoticeStringAptitude,
    YWNoticeStringInvoiceTips
} YWNoticeStringType;

@interface ShowNoticeStringController : BaseViewController

@property (nonatomic) YWNoticeStringType noticeType;

@end
