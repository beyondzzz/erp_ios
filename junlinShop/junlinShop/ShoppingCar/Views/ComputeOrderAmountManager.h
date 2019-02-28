//
//  ComputeOrderAmountManager.h
//  junlinShop
//
//  Created by 叶旺 on 2018/4/1.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComputeOrderAmountManager : NSObject

+ (CGFloat)computeOrderAmountWithGoodsArray:(NSArray *)goodsArr byActiveDic:(NSDictionary *)activeDic andCouponDic:(NSDictionary *)couponDic;

+ (CGFloat)computActiveGoodsPriceWithDic:(NSDictionary *)goodsDic andActiveDic:(NSDictionary *)activeDic;

@end
