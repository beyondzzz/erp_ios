//
//  YWAlertView.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/24.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "YWAlertView.h"

@interface YWAlertView () <UIGestureRecognizerDelegate>

@property (nonatomic, copy) void (^clickSureBlock)(UIButton *);
@property (nonatomic, copy) NSString *noticeStr;
@property (nonatomic) YWAlertViewType alertType;

@end

@implementation YWAlertView

+ (void)showNotice:(NSString *)noticeStr WithType:(YWAlertViewType)alertType clickSureBtn:(void(^)(UIButton *btn))sureBlock {
    YWAlertView *alertView = [[YWAlertView alloc] init];
    alertView.noticeStr = noticeStr;
    alertView.alertType = alertType;
    alertView.clickSureBlock = [sureBlock copy];
    [YWWindow addSubview:alertView];
}

- (instancetype)init {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [kBlackTextColor colorWithAlphaComponent:0.5];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_alertType != YWAlertTypeNormal) {
        
        YWWeakSelf;
        if (self.gestureRecognizers.count == 0) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
            tapGesture.delegate = self;
            [self addGestureRecognizer:tapGesture];
            [[tapGesture rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
                [weakSelf removeFromSuperview];
            }];
        }
        
    }
    
    CGFloat alertWidth = 0;
    CGFloat alertHeight = 0;
    if (_alertType == YWAlertTypeNormal) {
        alertWidth = kIphoneWidth - 100;
        alertHeight = [ASHString LabHeightWithString:_noticeStr font:[UIFont systemFontOfSize:18] andRectWithSize:CGSizeMake(alertWidth - 70, kIphoneHeight - 160)] + 60;
        
        if (alertHeight < 130) {
            alertHeight = 130;
        }
    } else if (_alertType == YWAlertTypeShowPayTips) {
        alertWidth = kIphoneWidth - 30;
        alertHeight = 330;
    } else {
        alertWidth = kIphoneWidth - 30;
        alertHeight = 330;
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake((kIphoneWidth - alertWidth) / 2, (kIphoneHeight - alertHeight - 40) / 2, alertWidth, alertHeight)];
    backView.backgroundColor = kBackViewColor;
    [backView setRadius:10.f];
    [self addSubview:backView];
    
    UIView *firstLine = [[UIView alloc] init];
    firstLine.backgroundColor = kGrayLineColor;
    [backView addSubview:firstLine];
    
    YWWeakSelf;
    if (_alertType == YWAlertTypeNormal) {
        [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backView.mas_centerX);
            make.top.equalTo(backView.mas_bottom).offset(-50);
            make.right.equalTo(backView.mas_right);
            make.height.equalTo(@0.5);
        }];
        
        UILabel *noticeLab = [[UILabel alloc] init];
        noticeLab.font = [UIFont systemFontOfSize:18];
        noticeLab.textColor = kBlackTextColor;
        noticeLab.numberOfLines = 3;
        noticeLab.text = _noticeStr;
        [backView addSubview:noticeLab];
        noticeLab.textAlignment = NSTextAlignmentCenter;
        [noticeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backView.mas_top);
            make.bottom.equalTo(firstLine.mas_top);
            make.left.equalTo(backView.mas_left).offset(35);
            make.centerX.equalTo(backView.mas_centerX);
        }];
        
        UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [quitBtn setTitle:@"取消" forState:UIControlStateNormal];
        [quitBtn setTitleColor:kBlackTextColor forState:UIControlStateNormal];
        [quitBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(200, 50) andColor:kBackViewColor] forState:UIControlStateNormal];
        [backView addSubview:quitBtn];
        [quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(firstLine.mas_bottom);
            make.bottom.equalTo(backView.mas_bottom);
            make.left.equalTo(backView.mas_left);
            make.width.equalTo(@(CGRectGetWidth(backView.frame) / 2));
        }];
        [[quitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [weakSelf removeFromSuperview];
        }];
        
        UIButton *requireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [requireBtn setTitle:@"确定" forState:UIControlStateNormal];
        [requireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [requireBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(200, 50) andColor:kBackGreenColor] forState:UIControlStateNormal];
        [backView addSubview:requireBtn];
        [requireBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(firstLine.mas_bottom);
            make.bottom.equalTo(backView.mas_bottom);
            make.right.equalTo(backView.mas_right);
            make.width.equalTo(@(CGRectGetWidth(backView.frame) / 2));
        }];
        
        
        [[requireBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            weakSelf.clickSureBlock((UIButton *)x);
            [weakSelf removeFromSuperview];
        }];
        
    } else {
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.font = [UIFont boldSystemFontOfSize:20];
        titleLab.textColor = kBlackTextColor;
        titleLab.textAlignment = NSTextAlignmentCenter;
        if (_alertType == YWAlertTypeShowPayTips) {
            titleLab.text = @"支付方式说明";
        } else if (_alertType ==  YWAlertTypeShowInvoiceTips) {
            titleLab.text = @"开票须知";
        } else if (_alertType ==  YWAlertTypeShowCouponTips) {
            titleLab.text = @"优惠券使用说明";
        }
        
        [backView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backView.mas_top).offset(20);
            make.left.equalTo(backView.mas_left).offset(35);
            make.centerX.equalTo(backView.mas_centerX);
            make.height.equalTo(@25);
        }];
        
        
        [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backView.mas_centerX);
            make.top.equalTo(backView.mas_top).offset(55);
            make.right.equalTo(backView.mas_right);
            make.height.equalTo(@0.5);
        }];
        
        UIButton *requireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [requireBtn setTitle:@"知道了" forState:UIControlStateNormal];
        [requireBtn setTitleColor:kBackGreenColor forState:UIControlStateNormal];
        [requireBtn setBorder:kBackGreenColor width:1 radius:5.f];
        [backView addSubview:requireBtn];
        [requireBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(backView.mas_bottom).offset(-15);
            make.centerX.equalTo(backView.mas_centerX);
            make.width.equalTo(@120);
            make.height.equalTo(@40);
        }];
        [[requireBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            weakSelf.clickSureBlock((UIButton *)x);
            [weakSelf removeFromSuperview];
        }];
        
        if (_alertType == YWAlertTypeShowPayTips) {
            NSMutableAttributedString *attributeStr01 = [[NSMutableAttributedString alloc] initWithString:@"1、在线支付：\n订单金额小于5万元可直接进行在线支付，可选择微信、支付宝及银联支付；"];
            UILabel *noticeLab01 = [[UILabel alloc] init];
            noticeLab01.font = [UIFont systemFontOfSize:16];
            noticeLab01.numberOfLines = 0;
            noticeLab01.textColor = kBlackTextColor;
            noticeLab01.attributedText = attributeStr01;
            [backView addSubview:noticeLab01];
            [noticeLab01 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(firstLine.mas_bottom).offset(15);
                make.left.equalTo(backView.mas_left).offset(32);
                make.centerX.equalTo(backView.mas_centerX);
                make.height.equalTo(@95);
            }];
            
            NSMutableAttributedString *attributeStr02 = [[NSMutableAttributedString alloc] initWithString:@"2、线下支付：\n订单金额为5万元及以上的订单，需进行线下支付；"];
            UILabel *noticeLab02 = [[UILabel alloc] init];
            noticeLab02.font = [UIFont systemFontOfSize:16];
            noticeLab02.numberOfLines = 0;
            noticeLab02.textColor = kBlackTextColor;
            noticeLab02.attributedText = attributeStr02;
            [backView addSubview:noticeLab02];
            [noticeLab02 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(noticeLab01.mas_bottom);
                make.left.equalTo(backView.mas_left).offset(32);
                make.centerX.equalTo(backView.mas_centerX);
                make.height.equalTo(@95);
            }];
            
        } else if (_alertType ==  YWAlertTypeShowInvoiceTips || _alertType ==  YWAlertTypeShowCouponTips) {
            NSMutableAttributedString *attributeStr01 = [[NSMutableAttributedString alloc] initWithString:@"内容待定"];
            UILabel *noticeLab01 = [[UILabel alloc] init];
            noticeLab01.font = [UIFont systemFontOfSize:16];
            noticeLab01.numberOfLines = 0;
            noticeLab01.textColor = kBlackTextColor;
            noticeLab01.attributedText = attributeStr01;
            [backView addSubview:noticeLab01];
            [noticeLab01 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(firstLine.mas_bottom).offset(15);
                make.left.equalTo(backView.mas_left).offset(32);
                make.centerX.equalTo(backView.mas_centerX);
                make.height.equalTo(@95);
            }];
            
//            NSMutableAttributedString *attributeStr02 = [[NSMutableAttributedString alloc] initWithString:@"2、线下支付：\n订单金额为5万元及以上的订单，需进行线下支付；"];
//            UILabel *noticeLab02 = [[UILabel alloc] init];
//            noticeLab02.font = [UIFont systemFontOfSize:16];
//            noticeLab02.numberOfLines = 0;
//            noticeLab02.textColor = kBlackTextColor;
//            noticeLab02.attributedText = attributeStr02;
//            [backView addSubview:noticeLab02];
//            [noticeLab02 mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(noticeLab01.mas_bottom);
//                make.left.equalTo(backView.mas_left).offset(32);
//                make.centerX.equalTo(backView.mas_centerX);
//                make.height.equalTo(@95);
//            }];
        }
        
        
    }
}

#pragma mark 点击冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIView"]) {
        return NO;
    }
    return  YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
