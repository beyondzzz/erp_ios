//
//  UIView+LoadingView.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/21.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RefreshBlock)(void);
@interface UIView (LoadingView)

@property (nonatomic, strong) UIView *backView;

- (void)startLoadingWithY:(CGFloat)y Height:(CGFloat)height;

- (void)stopLoading;

- (void)showNoDataWithString:(NSString *)string;

- (void)showErrorWithRefreshBlock:(RefreshBlock)block;

@end
