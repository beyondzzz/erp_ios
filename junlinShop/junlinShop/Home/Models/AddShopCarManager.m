//
//  AddShopCarManager.m
//  junlinShop
//
//  Created by 叶旺 on 2018/7/12.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "AddShopCarManager.h"

@implementation AddShopCarManager

+ (void)addGoodsToShopCarWithGoodsDic:(NSDictionary *)goodsDic orGoodsSkuDic:(NSDictionary *)skuDic andBuyCount:(NSInteger)count WithCouponId:(NSNumber *)couponId {
    
    NSArray *detailArr = [goodsDic objectForKey:@"goodsSpecificationDetails"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[YWUserDefaults objectForKey:@"UserID"] forKey:@"userId"];
    
    if (skuDic == nil) {
        skuDic = [detailArr firstObject];
    }
    [dict setValue:[skuDic objectForKey:@"id"] forKey:@"goodsSpecificationDetailsId"];
    
    [dict setValue:[goodsDic objectForKey:@"id"] forKey:@"goodsDetailsId"];
    [dict setValue:@(count) forKey:@"goodsNum"];
    
    if ([[skuDic objectForKey:@"gxcGoodsState"] integerValue] == 1) {
        
        if ([[goodsDic objectForKey:@"goodsActivitys"] count] == 1) {
            
            NSDictionary *actDic = [[goodsDic objectForKey:@"goodsActivitys"] firstObject];
            [dict setValue:[actDic objectForKey:@"id"] forKey:@"activityId"];
            [dict setValue:[[actDic objectForKey:@"activityInformation"] objectForKey:@"name"] forKey:@"activityName"];
            
            [HttpTools Post:kAppendUrl(YWAddShopCarString) parameters:dict success:^(id responseObject) {
                [SVProgressHUD showSuccessWithStatus:@"添加成功！"];
            } failure:^(NSError *error) {
                
                NSLog(@"添加失败");
                
            }];
            
        } else {
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:[goodsDic objectForKey:@"id"] forKey:@"goodsDetailsId"];
            if (couponId) {
                [dic setValue:couponId forKey:@"couponId"];
            } else {
                [dic setValue:@"0" forKey:@"couponId"];
            }
            
            [HttpTools Get:kAppendUrl(@"activityInformation/getPreSellActivityInformationByGoodsDetailsId") parameters:dic success:^(id responseObject) {
                
                NSDictionary *actDic = [responseObject objectForKey:@"resultData"];
                [dict setValue:[actDic objectForKey:@"id"] forKey:@"activityId"];
                [dict setValue:[actDic objectForKey:@"name"] forKey:@"activityName"];
                
                [HttpTools Post:kAppendUrl(YWAddShopCarString) parameters:dict success:^(id responseObject) {
                    
                    [SVProgressHUD showSuccessWithStatus:@"添加成功！"];
                    
                } failure:^(NSError *error) {
                    
                    NSLog(@"添加失败");
                    
                }];
                
                
            } failure:^(NSError *error) {
                
                NSLog(@"添加失败");
                
            }];
            
            
        }
        
    } else {
        
        if (([[goodsDic objectForKey:@"zeroStock"] integerValue] - count) < 0) {
            
            NSString *string = [NSString stringWithFormat:@"%@", [skuDic objectForKey:@"gxcGoodsStock"]];
            if (![ASHValidate isBlankString:string]) {
                NSInteger goodsCount = [string integerValue];
                if (goodsCount <= 0) {
                    [SVProgressHUD showErrorWithStatus:@"库存不足，无法加入购物车"];
                    return;
                }
            }
        }
        
        [dict setValue:@"0" forKey:@"activityId"];
        [dict setValue:@"" forKey:@"activityName"];
        
        [HttpTools Post:kAppendUrl(YWAddShopCarString) parameters:dict success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"添加成功！"];
        } failure:^(NSError *error) {
            NSLog(@"添加失败");
        }];
        
    }
}

@end
