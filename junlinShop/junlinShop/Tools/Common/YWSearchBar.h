//
//  YWSearchBar.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/27.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    YWSearchBarStyleWhiteColor = 0,
    YWSearchBarStyleGrayColor
} YWSearchBarStyle;
@interface YWSearchBar : UISearchBar

- (instancetype)initWithFrame:(CGRect)frame andStyle:(YWSearchBarStyle)style;

@end
