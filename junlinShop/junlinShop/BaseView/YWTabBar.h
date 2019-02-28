//
//  YWTabBar.h
//  junlinShop
//
//  Created by 叶旺 on 2017/11/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YWTabBar;
@protocol YWTabbarDelegate <NSObject>
@optional
- (void)tabBar:(YWTabBar *)tabBar didSelectedButtonFrom:(long)fromBtnTag to:(long)toBtnTag;
@end

@interface YWTabBar : UIView

- (void)addTabBarButtonWithTabBarItem:(UITabBarItem *)tabBarItem;
@property(nonatomic, weak)id <YWTabbarDelegate>delegate;
@property(nonatomic, strong)NSMutableArray *tabbarBtnArray;

@end
