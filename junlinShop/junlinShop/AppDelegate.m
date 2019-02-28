//
//  AppDelegate.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/18.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "AppDelegate.h"
#import "YWBaseNavigationController.h"
#import "YWBaseTabBarController.h"
#import "ADsShowViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <AlipaySDK/AlipaySDK.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

#define UMKEY @"5ab1ec9fa40fa34c1b0001fa"

@interface AppDelegate ()<WXApiDelegate>

@property (nonatomic, strong) NSString *downUrl;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
 
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    YWBaseTabBarController *tabBarController = [[YWBaseTabBarController alloc] init];
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    [WXApi registerApp:@"wx037454184aee70e9"];
    
    [self registerUMKey];
    
    if (AutoUpdate) {
        [self versionUpdateWithAppStore];
    }
    
     return YES;
}

- (void)versionUpdateWithAppStore {
    NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString:AppUpdateURL] encoding:NSUTF8StringEncoding error:nil];
    if (![string containsString:@"\"version\":"]) {
        return;
    }
    if (string != nil && string.length > 0) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *appVersion = [string substringFromIndex:[string rangeOfString:@"\"version\":"].location + 10];
        appVersion = [[appVersion substringToIndex:[appVersion rangeOfString:@","].location] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSString *ver1 = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSString *ver2 = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSLog(@"%@ %@ %@ %@", appVersion, version, ver1, ver2);
        if ([ver1 integerValue] < [ver2 integerValue]) {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"发现新的版本,是否更新" delegate:self cancelButtonTitle:@"取消下载" otherButtonTitles:@"前往下载", nil];
            [alter show];
            alter.tag = 1100;
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 1101) {
        NSURL *url = [NSURL URLWithString:_downUrl];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    }
    if (buttonIndex == 1 && alertView.tag == 1100) {
        NSString *url = @"https://itunes.apple.com/us/app/cure/id1391668256?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
            
        }];
    }
    
}

- (void)registerUMKey{
    
    //    setPlaform是要注册的平台
    [ShareSDK registerActivePlatforms:@[
                                        @(SSDKPlatformTypeWechat),
                                        @(SSDKPlatformTypeQQ),
                                        ]
                             onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             default:
                 break;
         }
     }
                      onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx037454184aee70e9"
                                       appSecret:@"cbdab39fdc019dac230045a25e745ae1"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"1106832603"
                                      appKey:@"CbazsF9rTXHZoBGx"
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
    
    
}

// 支持所有iOS系统回调
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    [WXApi handleOpenURL:url delegate:self];
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }
    NSLog(@"application:openURL:sourceApplication:annotation:");
    //    [self application:application handleOpenURL:url];
    return  YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"application:handleOpenURL:");
    //    [self application:application openURL:url sourceApplication:nil annotation:nil];
    return  YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    [WXApi handleOpenURL:url delegate:self];
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [YWNoteCenter postNotificationName:@"kAliPayComplete" object:nil];
            
            NSLog(@"result = %@",resultDic);
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            
            NSString *result = resultDic[@"result"];
            NSString *userId = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 15 && [subResult hasPrefix:@"alipay_open_id="]) {
                        userId = [subResult substringFromIndex:15];
                        break;
                    }
                }
            }
            if (userId) {
                [YWNoteCenter postNotificationName:@"kAlipayLoginComplete" object:@{@"userId":userId}];
            }
            NSLog(@"授权结果 authCode = %@", userId?:@"");
        }];
    }
    
    return  YES;
}

- (void)onReq:(BaseReq *)req
{
    NSLog(@"--->%s wxapi onreq:%@",__func__,req);
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp *response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                [YWNoteCenter postNotificationName:kWeChatPaySuccessNotification object:nil];
                NSLog(@"支付成功");
                break;
            default:
                [YWNoteCenter postNotificationName:kWeChatPayFailedNotification object:nil];
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
    NSLog(@"--->%s wxapi onresp:%@",__func__,resp);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"junlinShop"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
