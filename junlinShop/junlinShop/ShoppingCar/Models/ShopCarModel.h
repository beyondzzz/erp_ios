//
//  ShopCarModel.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/22.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopCarModel : NSObject

@property (nonatomic, strong) NSDictionary *dataDic;
@property (nonatomic, strong) NSDictionary *skuSelectedDic;

@property (nonatomic) BOOL isSelect;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) BOOL isYuShou;
@property (nonatomic) BOOL isShiXiao;
@property (nonatomic) BOOL isWuHuo;
@property (nonatomic, strong) NSNumber *yuShouActiveId;

@property (nonatomic) NSInteger selectNumber;
@property (nonatomic, strong) NSString *specStr;
@property (nonatomic, strong) NSString *goodsImageUrl;
@property (nonatomic, strong) NSNumber *price;


/**
 
“goodsDetails”：购物车中每个商品的商品详情信息。
“goodsDetails”下的“goodsSpecificationDetails”：该商品包含的价格最低的商品规格详情信息。
“goodsSpecificationDetails”下的"gxcGoodsState"：该商品此规格的状态(0:预售，1：现货)。
“goodsSpecificationDetails”下的"gxcGoodsStock"：该商品此规格当前的库存。
“goodsSpecificationDetails”下的"goodsDisplayPictures"：该商品此规格的所有展示图。
“goodsSpecificationDetails”下的"goodsActivitys"：该商品此规格所参加的所有活动信息。
“goodsDetails”下的“goodsActivitys”：该商品所参与的活动。
“goodsActivitys”下的” activityInformation”：活动的详细信息。
 */
@end
