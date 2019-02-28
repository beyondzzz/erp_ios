//
//  ComputeOrderAmountManager.m
//  junlinShop
//
//  Created by 叶旺 on 2018/4/1.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ComputeOrderAmountManager.h"

@implementation ComputeOrderAmountManager

+ (CGFloat)computeOrderAmountWithGoodsArray:(NSArray *)goodsArr byActiveDic:(NSDictionary *)activeDic andCouponDic:(NSDictionary *)couponDic
{
    CGFloat totlePrice = 0;
    
    
    if (activeDic) {
        for (NSDictionary *dic in goodsArr) {
            if ([[dic objectForKey:@"goodsSpecificationDetailsId"] isEqual:[activeDic objectForKey:@"goodsId"]]) {
                CGFloat activePrice = [self computActiveGoodsPriceWithDic:dic andActiveDic:[activeDic objectForKey:@"activityInformation"]];
                totlePrice += activePrice;
            } else {
                CGFloat price = [[dic objectForKey:@"goodsOriginalPrice"] floatValue];
                NSInteger count = [[dic objectForKey:@"goodsQuantity"] integerValue];
                totlePrice += (price * count);
            }
        }
    } else {
        for (NSDictionary *dic in goodsArr) {
            CGFloat price = [[dic objectForKey:@"goodsOriginalPrice"] floatValue];
            NSInteger count = [[dic objectForKey:@"goodsQuantity"] integerValue];
            totlePrice += (price * count);
        }
    }
    
    if (couponDic) {
        CGFloat youhuiPrice = [[[couponDic objectForKey:@"couponInformation"] objectForKey:@"price"] floatValue];
        CGFloat useLimit = [[[couponDic objectForKey:@"couponInformation"] objectForKey:@"useLimit"] floatValue];
        if (totlePrice >= useLimit) {
            totlePrice -= youhuiPrice;
        }
    }
    
    return totlePrice;
}

+ (CGFloat)computActiveGoodsPriceWithDic:(NSDictionary *)goodsDic andActiveDic:(NSDictionary *)activeDic {
    CGFloat activePrice = 0;
    CGFloat price = [[goodsDic objectForKey:@"goodsOriginalPrice"] floatValue];
    NSInteger count = [[goodsDic objectForKey:@"goodsQuantity"] integerValue];
    
    switch ([[activeDic objectForKey:@"activityType"] intValue]) {
        case 0: {
//            _activeTagLab.text = @"折扣";
            CGFloat zheKou = [[activeDic objectForKey:@"discount"] floatValue];
            NSInteger maxNum = [[activeDic objectForKey:@"maxNum"] integerValue];
            
            if (maxNum >= count) {
                activePrice = (price * zheKou) * count;
            } else {
                activePrice = (price * zheKou) * maxNum + price * (count - maxNum);
            }
        }
            break;
        case 1: {
//            _activeTagLab.text = @"团购";
            CGFloat actPrice = [[activeDic objectForKey:@"discount"] floatValue];
            NSInteger maxNum = [[activeDic objectForKey:@"maxNum"] integerValue];
            
            if (maxNum >= count) {
                activePrice = actPrice * count;
            } else {
                activePrice = actPrice * maxNum + price * (count - maxNum);
            }
        }
            break;
        case 2: {
//            _activeTagLab.text = @"秒杀";
            CGFloat actPrice = [[activeDic objectForKey:@"discount"] floatValue];
            NSInteger maxNum = [[activeDic objectForKey:@"maxNum"] integerValue];
            if (maxNum >= count) {
                activePrice = actPrice * count;
            } else {
                activePrice = actPrice * maxNum + price * (count - maxNum);
            }
        }
            break;
        case 3: {
//            _activeTagLab.text = @"立减";
            CGFloat actPrice = [[activeDic objectForKey:@"discount"] floatValue];
            NSInteger maxNum = [[activeDic objectForKey:@"maxNum"] integerValue];
            if (maxNum >= count) {
                activePrice = (price - actPrice) * count;
            } else {
                activePrice = (price - actPrice) * maxNum + price * (count - maxNum);
            }
            activePrice = price * count - actPrice;
        }
            break;
        case 4: {
//            _activeTagLab.text = @"满减";
            CGFloat manPrice = [[activeDic objectForKey:@"price"] floatValue];
            CGFloat actPrice = [[activeDic objectForKey:@"discount"] floatValue];
            CGFloat totlePrice = price * count;
            if (totlePrice >= manPrice) {
                activePrice = totlePrice - actPrice;
            } else {
                activePrice = totlePrice;
            }
        }
            break;
        default:
            break;
    }
    
    if (activePrice < 0) {
        activePrice = 0;
    }
    return activePrice;
}

@end
