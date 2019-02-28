//
//  YWBaseNavigationController.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "YWBaseNavigationController.h"

@interface YWBaseNavigationController ()

@end

@implementation YWBaseNavigationController

+ (void)initialize
{
    // 1.取出设置主题的对象
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[YWBaseNavigationController class]]];
    
    // 2.修改导航条标题颜色大小
    [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kBlackTextColor,NSForegroundColorAttributeName,[UIFont fontWithName:@"Arial-BoldMT" size:FntSNav],NSFontAttributeName, nil]];
    
    // 3.修改导航条背景图片
    
    [navBar setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(kIphoneWidth, KNavBarHeight) andColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    
    // 4.自定义返回按钮
//    UIImage *backButtonImage = [[UIImage imageNamed:@"nav_back_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//
//    UIImage *backBtnImgHighLight = [[UIImage imageNamed:@"nav_back_h"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBtnImgHighLight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.topViewController;
    return [topVC preferredStatusBarStyle];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
        
        //如果想要设置title的话也可以在这里设置,就是给btn设置title
        [btn sizeToFit];
        [btn addTarget:self action:@selector(backItemDidClick) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    [super pushViewController:viewController animated:YES];
}

//实现返回按钮点击之后能出栈,也就是能返回的功能
-(void)backItemDidClick {
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 

@end
