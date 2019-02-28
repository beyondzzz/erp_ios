//
//  YWTabBar.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "YWTabBar.h"
#import "YWTabBarButton.h"

@interface YWTabBar ()
@property(nonatomic, weak)YWTabBarButton *selectedButton;

@end

@implementation YWTabBar

- (NSMutableArray *)tabbarBtnArray{
    if (!_tabbarBtnArray) {
        _tabbarBtnArray = [NSMutableArray array];
    }
    return  _tabbarBtnArray;
}

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [YWNoteCenter addObserver:self selector:@selector(goToHomeController) name:@"goToHomeController" object:nil];
    }
    
    return self;
}

- (void)goToHomeController {
    [self ClickTabBarButton:self.tabbarBtnArray[0]];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat btnY = 3;
    CGFloat btnW = self.frame.size.width/(self.subviews.count);
    CGFloat btnH = self.frame.size.height;
    
    for (int nIndex = 0; nIndex < self.tabbarBtnArray.count; nIndex++) {
        CGFloat btnX = btnW * nIndex + (btnW - btnH) / 2;
        YWTabBarButton *tabBarBtn = self.tabbarBtnArray[nIndex];
        //        if (nIndex > 1) {
        //            btnX += btnW;
        //        }
        tabBarBtn.frame = CGRectMake(btnX, btnY, btnH, btnH - 6);
        tabBarBtn.tag = nIndex;
    }
}

- (void)addTabBarButtonWithTabBarItem:(UITabBarItem *)tabBarItem {
    YWTabBarButton *tabBarBtn = [[YWTabBarButton alloc] init];
    
    tabBarBtn.tabBarItem = tabBarItem;
    [tabBarBtn addTarget:self action:@selector(ClickTabBarButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:tabBarBtn];
    [self.tabbarBtnArray addObject:tabBarBtn];
    
    //default selected first one
    if (self.tabbarBtnArray.count == 1) {
        [self ClickTabBarButton:tabBarBtn];
    }
}

- (void)ClickTabBarButton:(YWTabBarButton *)tabBarBtn{
    
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectedButtonFrom:to:)]) {
        [self.delegate tabBar:self didSelectedButtonFrom:self.selectedButton.tag to:tabBarBtn.tag];
    }
    self.selectedButton.selected = NO;
    tabBarBtn.selected = YES;
    self.selectedButton = tabBarBtn;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
