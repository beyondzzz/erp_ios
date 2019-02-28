//
//  ASHValidate.m
//  CR-HepB-MHD
//
//  Created by peter.ye on 2016/11/7.
//  Copyright © 2016年 peter.ye. All rights reserved.
//

#import "ASHValidate.h"

@implementation ASHValidate

+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    //手机号以13,14,15,17,18开头，八个 \d 数字字符
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"1[34578]([0-9]){9}"];
    return [phoneTest evaluateWithObject:mobileNum];
}


//邮箱
+ (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
//身份证号
+ (BOOL)validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

//判断字符串是否为空字符的方法
+ (BOOL)isBlankString:(id)string {
    NSString * str = (NSString*)string;
    if ([str isEqualToString:@"(null)"] || [str isEqualToString:@"<null>"]) {
        return YES;
    }
    if (str == nil || str == NULL) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
