//
//  AddShopCarManager.h
//  junlinShop
//
//  Created by 叶旺 on 2018/7/12.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddShopCarManager : NSObject

+ (void)addGoodsToShopCarWithGoodsDic:(NSDictionary *)goodsDic orGoodsSkuDic:(NSDictionary *)skuDic andBuyCount:(NSInteger)count WithCouponId:(NSNumber *)couponId;

@end
