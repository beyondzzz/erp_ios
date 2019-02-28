//
//  UIView+LoadingView.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/21.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "UIView+LoadingView.h"
#import <objc/runtime.h>

@implementation UIView (LoadingView)

- (UIView *)backView {
    UIView *_backView = objc_getAssociatedObject(self, @selector(backView));
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.frame = CGRectMake(0, 0, kIphoneWidth, CGRectGetHeight(self.frame));
        _backView.backgroundColor = kBackViewColor;
        objc_setAssociatedObject(self, @selector(backView), _backView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [self addSubview:_backView];

    return _backView;
}

- (void)setBackView:(UIView *)backView {
    objc_setAssociatedObject(self, @selector(backView), backView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)startLoadingWithY:(CGFloat)y Height:(CGFloat)height {
    [self creatLoadingViewWithY:y Height:height];
}

- (void)stopLoading {
    [self.backView removeFromSuperview];
}

- (UIView *)creatLoadingViewWithY:(CGFloat)y Height:(CGFloat)height {
    if (height > 0) {
        self.backView.frame = CGRectMake(0, y, kIphoneWidth, height);
    }
    
    for (UIView *view in self.backView.subviews) {
        [view removeFromSuperview];
    }
    
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake((kIphoneWidth - 110) / 2, CGRectGetHeight(self.backView.frame) / 2 - 24, 110, 24)];
    loadingView.backgroundColor = [UIColor clearColor];

    [self.backView addSubview:loadingView];
    
    UIImageView *loadingImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    loadingImageV.image = [UIImage imageNamed:@"load_icon"];
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
    animation.duration  = 2.0;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT;
    [loadingImageV.layer addAnimation:animation forKey:nil];
    [loadingView addSubview:loadingImageV];
    
    UILabel *textLab = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, 78, 24)];
    textLab.font = [UIFont systemFontOfSize:16];
    textLab.text = @"加载中......";
    textLab.textColor = kBlackTextColor;
    [loadingView addSubview:textLab];
    
    return loadingView;
}

- (void)showNoDataWithString:(NSString *)string {
    
    for (UIView *view in self.backView.subviews) {
        [view removeFromSuperview];
    }
    
    UILabel *textLab = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetHeight(self.backView.frame) / 2 - 24, kIphoneWidth - 100, 24)];
    textLab.font = [UIFont systemFontOfSize:16];
    textLab.text = string;
    textLab.textAlignment = NSTextAlignmentCenter;
    textLab.textColor = kBlackTextColor;
    [self.backView addSubview:textLab];
}

- (void)showErrorWithRefreshBlock:(RefreshBlock)block {
    
    for (UIView *view in self.backView.subviews) {
        [view removeFromSuperview];
    }
    
    UILabel *textLab = [[UILabel alloc] initWithFrame:CGRectMake(kIphoneWidth / 2 - 40, CGRectGetHeight(self.backView.frame) / 2 - 36 - 10, 80, 24)];
    textLab.font = [UIFont systemFontOfSize:15];
    textLab.text = @"网络异常";
    textLab.textAlignment = NSTextAlignmentCenter;
    textLab.textColor = kBlackTextColor;
    [self.backView addSubview:textLab];
    
    UIImageView *errorImageV = [[UIImageView alloc] initWithFrame:CGRectMake(kIphoneWidth / 2 - 90, CGRectGetHeight(self.backView.frame) / 2 - 42 - 10, 36, 36)];
    errorImageV.image = [UIImage imageNamed:@"search_noData"];
    errorImageV.backgroundColor = [UIColor clearColor];
    [self.backView addSubview:errorImageV];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBorder:kBackRedColor width:1 radius:4.f];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.frame = CGRectMake(kIphoneWidth / 2 - 45, CGRectGetMaxY(textLab.frame) + 25, 90, 30);
    [button setTitle:@"刷新页面" forState:UIControlStateNormal];
    [button setTitleColor:kBackRedColor forState:UIControlStateNormal];
    
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        block();
    }];
    [self.backView addSubview:button];
}


@end
