//
//  YWAlertView.h
//  junlinShop
//
//  Created by 叶旺 on 2017/11/24.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    YWAlertTypeNormal = 0,
    YWAlertTypeShowPayTips,
    YWAlertTypeShowCouponTips,
    YWAlertTypeShowInvoiceTips
} YWAlertViewType;

@interface YWAlertView : UIView

+ (void)showNotice:(NSString *)noticeStr WithType:(YWAlertViewType)alertType clickSureBtn:(void(^)(UIButton *btn))sureBlock;

@end
