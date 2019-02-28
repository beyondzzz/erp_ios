//
//  ASHString.h
//  ASHBgxnsq
//
//  Created by 徐 颖 on 16/6/10.
//  Copyright © 2016年 wangjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASHString : NSObject

+(NSDate *)NSStringToDate:(NSString *)dateString;
+(NSDate *)NSStringToDate:(NSString *)dateString withFormat:(NSString *)formatestr;
+(NSString *)NSDateToString:(NSDate *)dateFromString withFormat:(NSString *)formatestr;
+(NSString *)jsonDateToString:(NSNumber *)dateNum withFormat:(NSString *)formatestr;

+ (CGFloat)LabHeightWithString:(NSString *)string font:(UIFont *)font andRectWithSize:(CGSize)size;
+ (CGFloat)LabWidthWithString:(NSString *)string font:(UIFont *)font andRectWithSize:(CGSize)size;
+ (CGFloat)LabHeightWithString:(NSString *)string fontSize:(CGFloat)fontSize andRectWithSize:(CGSize)size;
+ (CGFloat)LabWidthWithString:(NSString *)string fontSize:(CGFloat)fontSize andRectWithSize:(CGSize)size;

//转Json字符串
+ (NSString *)trasforconditionToJsonString:(id)object;
+ (id)trasforconditionFromJsonString:(NSString *)jsonString;

+(CGRect)rectInSize:(CGSize)size withFontSize:(CGFloat)font byString:(NSString *)string;

+ (NSString *)getUUIDString;

@end
