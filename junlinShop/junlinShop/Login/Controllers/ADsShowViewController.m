//
//  ADsShowViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/4/12.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ADsShowViewController.h"
#import "AppDelegate.h"
#import "YWBaseTabBarController.h"

@interface ADsShowViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *adsImageView;

@end

@implementation ADsShowViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@(0) forKey:@"type"];
    [HttpTools Get:kAppendUrl(YWHomeAdsString) parameters:dic success:^(id responseObject) {
        
        NSDictionary *dic = [[responseObject objectForKey:@"resultData"] firstObject];
        NSString *imageUrl = [dic objectForKey:@"picUrl"];
        if (imageUrl) {
            [self.adsImageView sd_setImageWithURL:[NSURL URLWithString:kAppendUrl(imageUrl)] placeholderImage:[UIImage imageNamed:@"launch_Image"]];
            
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0/*延迟执行时间*/ * NSEC_PER_SEC));
            
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                YWBaseTabBarController *tabBarController = [[YWBaseTabBarController alloc] init];
                appDelegate.window.rootViewController = tabBarController;
                
            });
        } else {
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            YWBaseTabBarController *tabBarController = [[YWBaseTabBarController alloc] init];
            appDelegate.window.rootViewController = tabBarController;
            
        }
            
    } failure:^(NSError *error) {
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        YWBaseTabBarController *tabBarController = [[YWBaseTabBarController alloc] init];
        appDelegate.window.rootViewController = tabBarController;
        
    }];
    
    
    // Do any additional setup after loading the view from its nib.
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
