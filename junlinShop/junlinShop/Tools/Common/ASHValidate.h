//
//  ASHValidate.h
//  CR-HepB-MHD
//
//  Created by peter.ye on 2016/11/7.
//  Copyright © 2016年 peter.ye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASHValidate : NSObject

//手机号
+ (BOOL)isMobileNumber:(NSString *)mobileNum;
//邮箱
+ (BOOL)validateEmail:(NSString *)email;
//身份证
+ (BOOL)validateIdentityCard: (NSString *)identityCard;
//空字符串
+ (BOOL)isBlankString:(id)string;

@end
