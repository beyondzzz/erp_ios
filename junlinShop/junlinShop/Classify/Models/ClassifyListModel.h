//
//  ClassifyListModel.h
//  junlinShop
//
//  Created by jianxuan on 2018/1/22.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseModel.h"

@interface ClassifyListModel : BaseModel

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSNumber *parentId;
@property (nonatomic, strong) NSNumber *sort;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *picUrl;
@property (nonatomic, strong) NSString *operatorIdentifier;
@property (nonatomic, strong) NSNumber *operatorTime;
@property (nonatomic, strong) NSString *parentName;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSArray *twoClassifications;
@property (nonatomic, strong) NSString *goodsDetails;

@end
