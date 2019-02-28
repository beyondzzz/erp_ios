//
//  BaseHeader.h
//  junlinShop
//
//  Created by 叶旺 on 2017/11/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#ifndef BaseHeader_h
#define BaseHeader_h

// 基类
#import "UISetting.h"
#import "Api.h"
#import "ASHString.h"
#import "ASHValidate.h"
#import "UIView+ALWAdd.h"
#import "UIImage+YWExtension.h"
#import "UIButton+YWExtension.h"
#import "UIButton+badge.h"
#import "UIView+LoadingView.h"
#import "YWAlertView.h"
#import "UIView+Frame.h"
#import "CacheManager.h"

//..  第三方库
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "Masonry.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <SDWebImageManager.h>
#import "UIImageView+WebCache.h"
//网络
#import "HttpTools.h"

#pragma mark - 通知
#define  kWechatPaySu @"kWechatPayComplete"
//微信支付

//微信支付成功
#define kWeChatPaySuccessNotification @"WeChatPaysuccessNotification"
//微信支付失败
#define kWeChatPayFailedNotification @"WeChatPayFailedNotification"

//支付宝
#define kAlipayAuthSuccessNotification @"AlipayAuthSuccessNotification"
#define kAlipayPaySuccessNotification @"AlipayPaySuccessNotification"
#define kAlipayPayFailedNotification @"AlipayPayFailedNotification"
#define kAlipayPayCancelNotification @"AlipayPayCancelNotification"


//分类筛选
#define SelectIndexArray @"SelectIndexArray"
//品牌筛选
#define SelectBrandArray @"SelectBrandArray"

//最低价筛选
#define SelectMinPrice @"SelectMinPrice"

//最高价筛选
#define SelectMaxPrice @"SelectMaxPrice"



//ios系统相关
#define kSystemVersion ([[[UIDevice currentDevice] systemVersion] doubleValue])
#define isIOS11 [[[UIDevice currentDevice] systemVersion] floatValue] >=11.0f

#define iphone5x_4_0 ([UIScreen mainScreen].bounds.size.height==568.0f)
#define iphone6_4_7 ([UIScreen mainScreen].bounds.size.height==667.0f)
#define iphone6Plus_5_5 ([UIScreen mainScreen].bounds.size.height==736.0f || [UIScreen mainScreen].bounds.size.height==414.0f)
#define iphoneX ([UIScreen mainScreen].bounds.size.height==812.0f)


#define kRGBColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define kBackGrayColor kRGBColor(245, 245, 245, 1)
#define kBackRedColor kRGBColor(254, 128, 128, 1)
#define kBackGreenColor kRGBColor(85, 174, 61, 1)
#define kBackYellowColor kRGBColor(236, 133, 67, 1)
#define kBackViewColor [UIColor whiteColor]
#define kGrayTextColor kRGBColor(153, 153, 153, 1)
#define kRedTextColor [UIColor redColor]
#define kBlueTextColor kRGBColor(30, 120, 249, 1)
#define kBlackTextColor kRGBColor(51, 51, 51, 1)
#define kGrayLineColor kRGBColor(221, 221, 221, 1)

#define kDefaultImage [UIImage imageNamed:@"placeHolderImage"]

#define kIphoneWidth [UIScreen mainScreen].bounds.size.width
#define kIphoneHeight [UIScreen mainScreen].bounds.size.height
#define SafeAreaTopHeight (kIphoneHeight == 812.0 ? 88 : 64)
#define SafeAreaBottomHeight (kIphoneHeight == 812.0 ? 34 : 0)


#define adjustsScrollViewInsets(scrollView)\
do {\
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
if ([scrollView respondsToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
NSMethodSignature *signature = [UIScrollView instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
NSInteger argument = 2;\
invocation.target = scrollView;\
invocation.selector = @selector(setContentInsetAdjustmentBehavior:);\
[invocation setArgument:&argument atIndex:2];\
[invocation retainArguments];\
[invocation invoke];\
}\
_Pragma("clang diagnostic pop")\
} while (0)

/**
 *  弱引用
 */
#define YWWeakSelf __weak typeof(self) weakSelf = self

#define YWNoteCenter [NSNotificationCenter defaultCenter]
#define YWUserDefaults [NSUserDefaults standardUserDefaults]

#define YWWindow [[[UIApplication sharedApplication] delegate] window]


#pragma mark - 适配




//当前设备的版本
#define     kCurrentFloatDevice     [[[UIDevice currentDevice]systemVersion]floatValue]


//屏幕高度
#define Main_Screen_Height [UIScreen mainScreen].bounds.size.height
//屏幕宽度
#define Main_Screen_Width [UIScreen mainScreen].bounds.size.width

//间距
#define kMargin 10


//比例
#define screenX 667*[UIScreen mainScreen].bounds.size.width
#define screenY 667*[UIScreen mainScreen].bounds.size.height



//iphoneX适配相关-开始
#define isIphoneX [UIApplication sharedApplication].statusBarFrame.size.height > 20 ? YES : NO
#define NavHeight [UIApplication sharedApplication].statusBarFrame.size.height + 44
#define tabbatHeight self.tabBarController.tabBar.height
//iphoneX适配相关-结束



//工具栏高度
#define Height_ToolView   44
//底部工具栏高度
#define Bottom_ToolHeight  50



#define iOS11 @available(iOS 11.0, *)

#define isIPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? [[UIScreen mainScreen] currentMode].size.height==2436 : NO)

#define iPhoneX  [UIDeviceType iPhoneXDevice]

#define Height_NavContentBar 44.0f
//状态栏高度
#define Height_StatusBar iPhoneX  ? 44.0f : 20.0f
//导航栏高度
#define Height_NavBar iPhoneX  ? 88.0f : 64.0f


//底部Tabbar 高度
#define Height_TabBar iPhoneX ? 83.0f : 49.0f



//底部Tabbar在iPhoneX上增加高度
#define Height_TabBar_Add  isIPhoneX ? 34.0 : 0.0
/// iPhone X 顶部刘海高度
#define Height_LiuHai  30.0


#define kMargin   10


#define meaaageOffsetY  isIPhoneX ? 140 : 130


#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
//注意：请直接获取系统的tabbar高度，若没有用系统tabbar，建议判断屏幕高度；
//之前判断状态栏高度的方法不妥，如果正在通话状态栏会变高，导致判断异常，下面只是一个例子，请勿直接使用！
#define kTabBarHeight kAppDelegate.mainTabBar.tabBar.frame.size.height
#define kTopHeight (kStatusBarHeight + kNavBarHeight)


//不同屏幕尺寸字体适配
#define kScreenWidthRatio  (UIScreen.mainScreen.bounds.size.width / 375.0)
#define kScreenHeightRatio (UIScreen.mainScreen.bounds.size.height / 667.0)
#define AdaptedWidth(x)  ceilf((x) * kScreenWidthRatio)
#define AdaptedHeight(x) ceilf((x) * kScreenHeightRatio)
#define AdaptedFontSize(R)     [UIFont systemFontOfSize:AdaptedWidth(R)]


#define kScaleW(value) value*Main_Screen_Width/375
#define kScaleH(value) value*Main_Screen_Height/667.0





#pragma mark - Log

#ifdef DEBUG
#define LLLog(FORMAT, ...) fprintf(stderr,"%s: [行号:%d]  %s\n",__FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define LLFunc() LLLog(@"%s", __func__);

#else
#define LLLog(...)
#define LLFunc(...)

#endif



#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define NSLog(...)
#define debugMethod()
#endif






#define kCurrentThread  LLLog(@"线程%@",[NSThread currentThread]);


//#define LLLog(format, ...) do { \
//fprintf(stderr, " %s\n", \
//        [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], \
//        __LINE__, __func__); \
//(LLLog)((format), ##__VA_ARGS__); \
//fprintf(stderr, "-------\n"); \
//} while (0)


#ifndef __OPTIMIZE__
#else
//这里执行的是release模式下
#endif


#define kGetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]

#define kTICK   NSDate *startTime = [NSDate date];
#define kTOCK   LLLog(@"耗时: %f", -[startTime timeIntervalSinceNow]);




#pragma mark - 颜色
#define kThemeColor  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]

//主题蓝色
#define Theme_BlueColor RGBA(41, 154, 230, 1)
//列表背景颜色
#define kTableBackgroundColor RGBA(238, 238, 238, 1)







#define kNavBackGroundColor [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0]
#define kNavTextColor [UIColor blackColor]


#define ButtonBackgroundColor [UIColor commonRedColor]
#define kCommonButtonWhiteColor [UIColor whiteColor]


//alert
#define kYellowColor   RGBA(217, 200, 146, 1.0)
#define kCancelBtnColor RGBA(144, 144, 144, 1.0)
#define kLineColor RGBA(210, 211, 213, 1)
#define kTitleColor RGBA(63, 63, 63, 1)

//电子书
#define kEBookYellowColor RGBA(249, 240, 224, 1)

#define kLightGrayLineColor  RGBA(238, 238, 238, 1.0)

//R G B A 颜色

#define RGBA(r,g,b,a) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:(a)]
//R G B 颜色
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]

#define     kRandomColor            [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1.0]


//#define kColorRGBA(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/255.0    \
//green:((c>>8)&0xFF)/255.0    \
//blue:(c&0xFF)/255.0         \
//alpha:a]
//#define kColorRGBA(c)    [UIColor colorWithRed:((c>>16)&0xFF)/255.0    \
//green:((c>>8)&0xFF)/255.0    \
//blue:(c&0xFF)/255.0         \
//alpha:1.0]
//
//// RGB颜色(16进制)   BR_RGB_HEX(0x464646, 1.0)
//#define BK_RGB_HEX(rgbValue, a) \
//[UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
//green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0 \
//blue:((CGFloat)(rgbValue & 0xFF)) / 255.0 alpha:(a)]


#define COLORHEX(hex)   [UIColor colorFromHex:hex]





#pragma mark - singleton


#define kSINGLETON_INTERFACE + (nonnull instancetype)sharedInstance;
#define kSINGLETON_IMPLEMENTATION(singleton) + (nonnull instancetype)sharedInstance { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
singleton = [[[self class] alloc] init]; \
}); \
return singleton; \
} \
\
+ (nonnull instancetype)allocWithZone:(struct _NSZone *)zone { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
singleton = [super allocWithZone:zone]; \
}); \
return singleton; \
} \
\
- (nonnull id)copyWithZone:(NSZone *)zone { \
return singleton; \
} \





#pragma mark - WeakSelf
#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf typeof(weakSelf) __strong strongSelf = weakSelf;



#define ESWeak(var, weakVar) __weak __typeof(&*var) weakVar = var
#define ESStrong_DoNotCheckNil(weakVar, _var) __typeof(&*weakVar) _var = weakVar
#define ESStrong(weakVar, _var) ESStrong_DoNotCheckNil(weakVar, _var); if (!_var) return;

#define ESWeak_(var) ESWeak(var, weak_##var);
#define ESStrong_(var) ESStrong(weak_##var, _##var);

/** defines a weak `self` named `__weakSelf` */
#define ESWeakSelf      ESWeak(self, __weakSelf);
/** defines a strong `self` named `_self` from `__weakSelf` */
#define ESStrongSelf    ESStrong(__weakSelf, _self);





#pragma mark - nil or NULL 空判断

//空值判断
#define IsNullIsNull(__String) (__String==nil || [__String isEqualToString:@""]|| [__String isEqualToString:@"null"])
#define IsNull(__Text) [__Text isKindOfClass:[NSNull class]]

#define IsEquallString(_Str1,_Str2)  [_Str1 isEqualToString:_Str2]


//是否为空或是[NSNull null]
#define NotNilAndNull(_ref)  (((_ref) != nil) && (![(_ref) isEqual:[NSNull null]]))
#define IsNilOrNull(_ref)   (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]))



//字符串是否为空
#define IsStrEmpty(_ref)    (((_ref) == nil) || (_ref.length == 0)|| (_ref == NULL)|| ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@" "]) ||([(_ref)isEqualToString:@"(null)"])||([(_ref)isEqualToString:@"<null>"]))

//数组是否为空
#define IsArrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))

//是否是空对象
#define LMJIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))


#define IS_VALID_DICTIONARY(dictionary) (dictionary && [dictionary isKindOfClass:[NSDictionary class]])
#define IS_VALID_ARRAY(array) (array && [array isKindOfClass:[NSArray class]] && [(NSArray *)array count])
#define IS_VALID_STRING(string) (string && [string isKindOfClass:[NSString class]] && [string length])




#endif /* BaseHeader_h */
