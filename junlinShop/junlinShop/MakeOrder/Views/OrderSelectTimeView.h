//
//  OrderSelectTimeView.h
//  junlinShop
//
//  Created by jianxuan on 2018/2/7.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderSelectTimeView : UIView

- (instancetype)initWithEndTime:(NSNumber *)endTime;

@property (nonatomic, strong) NSNumber *endDateNum;
@property (nonatomic, strong) NSArray *dateArray;
@property (nonatomic, copy) void (^selectedDateStr)(NSString *dateStr);

@end
