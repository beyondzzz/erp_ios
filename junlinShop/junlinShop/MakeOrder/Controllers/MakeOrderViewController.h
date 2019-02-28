//
//  MakeOrderViewController.h
//  junlinShop
//
//  Created by 叶旺 on 2017/12/5.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "BaseViewController.h"
#import "AddressModel.h"

@interface MakeOrderViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *goodsArray;
@property (nonatomic) BOOL isFromShopCar;
@property (nonatomic, strong) NSNumber *yuShouActiveId;
@property (nonatomic, strong) NSString *orderPrice;
@property (nonatomic, strong) AddressModel *addressModel;

@end
