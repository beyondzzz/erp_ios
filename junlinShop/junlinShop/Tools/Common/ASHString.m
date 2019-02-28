//
//  ASHString.m
//  ASHBgxnsq
//
//  Created by 徐 颖 on 16/6/10.
//  Copyright © 2016年 wangjun. All rights reserved.
//

#import "ASHString.h"

@implementation ASHString
+(NSDate *)NSStringToDate:(NSString *)dateString
{
//    NSLog(@"date:%@",dateString);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}

+(NSDate *)NSStringToDate:(NSString *)dateString withFormat:(NSString *)formatestr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatestr];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}
+(NSString *)NSDateToString:(NSDate *)dateFromString withFormat:(NSString *)formatestr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatestr];
    NSString *strDate = [dateFormatter stringFromDate:dateFromString];
    NSLog(@"%@",strDate);
    return strDate;
}

+(NSString *)jsonDateToString:(NSNumber *)dateNum withFormat:(NSString *)formatestr {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dateNum longLongValue] / 1000.0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatestr];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+ (CGFloat)LabHeightWithString:(NSString *)string font:(UIFont *)font andRectWithSize:(CGSize)size {
    CGRect contectLabRect = [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil];
    return contectLabRect.size.height;
}

+ (CGFloat)LabHeightWithString:(NSString *)string fontSize:(CGFloat)fontSize andRectWithSize:(CGSize)size {
    CGRect contectLabRect = [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil];
    return contectLabRect.size.height;
}

+ (CGFloat)LabWidthWithString:(NSString *)string font:(UIFont *)font andRectWithSize:(CGSize)size {
    CGRect contectLabRect = [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :font} context:nil];
    return contectLabRect.size.width;
}

+ (CGFloat)LabWidthWithString:(NSString *)string fontSize:(CGFloat)fontSize andRectWithSize:(CGSize)size {
    CGRect contectLabRect = [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil];
    return contectLabRect.size.width;
}

+ (NSString *)trasforconditionToJsonString:(id)object {
    NSData *dicjsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dicjsonText = [[NSString alloc] initWithData:dicjsonData encoding:NSUTF8StringEncoding];
    NSString *bstring = [dicjsonText stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *nstring =  [bstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //    NSString *endstring = [nstring stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
    return nstring;
}

+ (id)trasforconditionFromJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers | NSJSONReadingAllowFragments
                                                  error:nil];
    
    return object;
}

+(CGRect)rectInSize:(CGSize)size withFontSize:(CGFloat)font byString:(NSString *)string {
    CGRect rect = [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:font]} context:nil];
    return rect;
}

+ (NSString *)getUUIDString {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    return [uuid lowercaseString];
}

@end
