//
//  OrderOperationManager.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/27.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "OrderOperationManager.h"

@implementation OrderOperationManager

- (void)orderOperationWithType:(NSString *)type andDic:(NSDictionary *)dic success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSString *urlStr = @"";
    if ([type isEqualToString:@"删除订单"]) {
        
    } else if ([type isEqualToString:@"删除订单"]) {
        
    }
    
    [HttpTools Post:kAppendUrl(urlStr) parameters:dic success:^(id responseObject) {
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
