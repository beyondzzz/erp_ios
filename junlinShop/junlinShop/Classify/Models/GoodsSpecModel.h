//
//  GoodsSpecModel.h
//  junlinShop
//
//  Created by jianxuan on 2018/1/23.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseModel.h"

@interface GoodsSpecModel : BaseModel

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSNumber *saleId;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *goodsId;
@property (nonatomic, strong) NSNumber *salesCount;
@property (nonatomic, strong) NSNumber *state;
//@property (nonatomic, strong) NSNumber *salesCount;
@property (nonatomic, strong) NSString *specifications;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *onShelvesTime;
@property (nonatomic, strong) NSString *offShelvesTime;
@property (nonatomic, strong) NSString *operatorIdentifier;
@property (nonatomic, strong) NSString *operatorTime;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *goodsDetails;
@property (nonatomic, strong) NSString *participateActivities;
@property (nonatomic, strong) NSString *participateActivitieList;
@property (nonatomic, strong) NSString *gxcGoodsState;
@property (nonatomic, strong) NSString *gxcGoodsStock;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *goodsActivitys;
@property (nonatomic, strong) NSArray *goodsDisplayPictures;


@end
