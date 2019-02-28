//
//  YWBaseTabBarController.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "YWBaseTabBarController.h"
#import "YWBaseNavigationController.h"
#import "YWTabBarButton.h"
#import "HomeViewController.h"
#import "ClassifyViewController.h"
#import "ShopCarViewController.h"
#import "MineViewController.h"

@interface YWBaseTabBarController ()<YWTabbarDelegate>

@end

@implementation YWBaseTabBarController

+ (void)initialize
{
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       CorTab, NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       CorMain,NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateSelected];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self SetupMainTabBar];
}


- (void)configTabInfoWithController:(UIViewController *)vc
                              title:(NSString *)title
                           norImage:(NSString *)norImageName
                      selectedImage:(NSString *)selectedImageName
{
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = [[UIImage imageNamed:norImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.ywTabBar addTabBarButtonWithTabBarItem:vc.tabBarItem];
    YWBaseNavigationController *nav = [[YWBaseNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }
}

//防止出现重影
-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    for (UIView * view in self.tabBar.subviews) {
        if (![view isKindOfClass:[YWTabBar class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)SetupMainTabBar{
    YWTabBar *tabBar = [[YWTabBar alloc] init];
    tabBar.frame = self.tabBar.bounds;
    tabBar.delegate = self;
    [self.tabBar addSubview:tabBar];
    _ywTabBar = tabBar;
    
    HomeViewController *tabview1=[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    ClassifyViewController *tabview2=[[ClassifyViewController alloc] initWithNibName:@"ClassifyViewController" bundle:nil];
    ShopCarViewController *tabview3=[[ShopCarViewController alloc] initWithNibName:@"ShopCarViewController" bundle:nil];
    MineViewController *tabview4=[[MineViewController alloc] initWithNibName:@"MineViewController" bundle:nil];
    //
    [self configTabInfoWithController:tabview1
                                title:@"首页"
                             norImage:@"Tab1_NorImg"
                        selectedImage:@"Tab1_SelImg"];
    [self configTabInfoWithController:tabview2
                                title:@"分类"
                             norImage:@"Tab2_NorImg"
                        selectedImage:@"Tab2_SelImg"];
    [self configTabInfoWithController:tabview3
                                title:@"购物车"
                             norImage:@"Tab3_NorImg"
                        selectedImage:@"Tab3_SelImg"];
    [self configTabInfoWithController:tabview4
                                title:@"我的"
                             norImage:@"Tab4_NorImg"
                        selectedImage:@"Tab4_SelImg"];
    
}

#pragma mark --------------------mainTabBar delegate
- (void)tabBar:(YWTabBar *)tabBar didSelectedButtonFrom:(long)fromBtnTag to:(long)toBtnTag{
    self.selectedIndex = toBtnTag;
    
    YWTabBarButton *btn1=(YWTabBarButton *)[[self.ywTabBar tabbarBtnArray] objectAtIndex:toBtnTag];
    self.navigationItem.title=btn1.tabBarItem.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 

@end
