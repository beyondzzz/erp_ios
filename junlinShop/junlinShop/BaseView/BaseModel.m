//
//  BaseModel.m
//  junlinShop
//
//  Created by jianxuan on 2018/1/22.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"ID": @"id"};
}

@end
