//
//  ActiveSelectView.h
//  junlinShop
//
//  Created by 叶旺 on 2018/3/31.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveSelectView : UIView

+ (instancetype)initWithActiveArray:(NSArray *)activeArray isShow:(BOOL)isShow;

@property (nonatomic, copy) void (^completeSelectActive)(NSDictionary *activeDic);

@end
