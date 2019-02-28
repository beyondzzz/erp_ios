//
//  YWCountdownView.h
//  meirongApp
//
//  Created by 叶旺 on 2017/12/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YWCountdownView;
@protocol YWCountdownViewDelegate <NSObject>

- (void)countdownViewTimeCountToZero:(YWCountdownView *)countdownView;

@end

@interface YWCountdownView : UIView

@property (nonatomic, weak) id<YWCountdownViewDelegate> delegate;
@property (nonatomic, strong) UIColor *textColor;

- (void)setToEndTime:(NSTimeInterval)time;

- (void)setStartTimeWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

@end
