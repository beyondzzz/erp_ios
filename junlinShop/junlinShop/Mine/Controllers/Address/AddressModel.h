//
//  AddressModel.h
//  meirongApp
//
//  Created by jianxuan on 2017/12/1.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "BaseModel.h"

@interface AddressModel : BaseModel

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *consigneeName;
@property (nonatomic, strong) NSString *consigneeTel;

@property (nonatomic, strong) NSNumber *isCommonlyUsed;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *detailedAddress;
@property (nonatomic, strong) NSString *provinceCode;
@property (nonatomic, strong) NSString *cityCode;
@property (nonatomic, strong) NSString *countyCode;
@property (nonatomic, strong) NSString *ringCode;
@property (nonatomic, strong) NSString *operatorTime;

@end
