//
//  OrderOperationManager.h
//  junlinShop
//
//  Created by jianxuan on 2018/2/27.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderOperationManager : NSObject

- (void)orderOperationWithType:(NSString *)type andDic:(NSDictionary *)dic success:(void (^)(id responseObject))success
                       failure:(void (^)(NSError *error))failure;



@end
