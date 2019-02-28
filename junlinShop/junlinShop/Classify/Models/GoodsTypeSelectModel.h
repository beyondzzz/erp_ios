//
//  GoodsTypeSelectModel.h
//  junlinShop
//
//  Created by jianxuan on 2018/1/23.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsTypeSelectModel : NSObject

@property (nonatomic, strong) NSString *sortType;
@property (nonatomic, strong) NSString *priceSort;
@property (nonatomic, strong) NSString *searchName;
@property (nonatomic, strong) NSString *isHasGoods;
@property (nonatomic, strong) NSString *minPrice;
@property (nonatomic, strong) NSString *maxPrice;
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) NSString *classificationId;
/*
 sortType：页面list排序(1:综合排序，2：销量排序，3：价格排序，4：热门分类)，默认传1。(int)
 priceSort：根据价格排序时 是倒序还是正序（asc：正序，desc：倒序）默认为""。(String)
 searchName：页面头部的搜索栏的值(如果没值则传""),默认传""。(String)
 isHasGoods：是否仅查看有货("true":是，"false"：否),默认传true。(String)
 minPrice：价格区间的最低价(不设置的话传0)，默认传0。(Double)
 maxPrice：价格区间的最高价(不设置的话传0)，默认传0。(Double)
 brandName：品牌名称。(String) 全部品牌传 all，若干品牌时，品牌名称用 , 号隔开 例如： &brandName=品牌一,品牌二  （all要去掉）
 classificationId：一级分类id(若需获取全部新品上架传  0 )。(int)
 */

@end
