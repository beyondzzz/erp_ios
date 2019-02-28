//
//  GoodsListModel.h
//  junlinShop
//
//  Created by jianxuan on 2018/1/23.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseModel.h"
#import "GoodsSpecModel.h"

@interface GoodsListModel : BaseModel

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSNumber *classificationId;
@property (nonatomic, strong) NSNumber *saleCount;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, strong) NSString *introdution;
@property (nonatomic, strong) NSString *recom;
@property (nonatomic, strong) NSString *recomTime;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) NSString *classification;
@property (nonatomic, strong) NSArray *goodsSpecificationDetails;
@property (nonatomic, strong) NSString *goodsEvaluations;
@property (nonatomic, strong) NSString *goodsActivitys;

@end
